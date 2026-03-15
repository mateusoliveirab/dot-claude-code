#!/usr/bin/env python3
"""Cloudflare Browser Rendering /crawl helper for the cf-crawl skill."""

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

CF_BASE = "https://api.cloudflare.com/client/v4/accounts/{account_id}/browser-rendering"
POLL_INTERVAL = 5  # seconds


def get_credentials():
    account_id = os.environ.get("CLOUDFLARE_ACCOUNT_ID", "").strip()
    api_token = os.environ.get("CLOUDFLARE_API_TOKEN", "").strip()
    return account_id, api_token


def check_env():
    account_id, api_token = get_credentials()
    missing = []
    if not account_id:
        missing.append("CLOUDFLARE_ACCOUNT_ID")
    if not api_token:
        missing.append("CLOUDFLARE_API_TOKEN")
    if missing:
        print(f"MISSING: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)
    print("OK: credentials found")


def api_request(method, url, token, data=None, verify_ssl=True):
    """Make an API request using urllib (stdlib only)."""
    body = json.dumps(data).encode() if data else None
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    req = urllib.request.Request(url, data=body, headers=headers, method=method)

    try:
        if not verify_ssl:
            import ssl
            ctx = ssl.create_default_context()
            ctx.check_hostname = False
            ctx.verify_mode = ssl.CERT_NONE
            with urllib.request.urlopen(req, context=ctx) as resp:
                return json.loads(resp.read())
        else:
            with urllib.request.urlopen(req) as resp:
                return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"HTTP {e.code}: {body}", file=sys.stderr)
        sys.exit(1)


def slugify(url_str):
    """Convert a URL to a filesystem-safe slug."""
    # Remove scheme and clean up
    slug = re.sub(r"https?://", "", url_str)
    slug = re.sub(r"[^\w\-/]", "-", slug)
    slug = re.sub(r"/+", "/", slug).strip("/")
    slug = re.sub(r"-+", "-", slug)
    # Use last path component, fallback to full slug
    parts = slug.split("/")
    name = parts[-1] if parts[-1] else (parts[-2] if len(parts) > 1 else slug)
    return name[:80] or "index"


def save_page(page, output_dir, seen_slugs):
    """Save a single page as a markdown file."""
    url = page.get("url", "")
    content = page.get("content", page.get("markdown", "")).strip()
    crawled_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    slug = slugify(url)
    # Deduplicate slugs
    final_slug = slug
    counter = 1
    while final_slug in seen_slugs:
        final_slug = f"{slug}-{counter}"
        counter += 1
    seen_slugs.add(final_slug)

    filepath = output_dir / f"{final_slug}.md"
    frontmatter = f"---\nurl: {url}\ncrawled_at: {crawled_at}\n---\n\n"
    filepath.write_text(frontmatter + content, encoding="utf-8")
    return filepath


def run_crawl(url, limit, depth, output_dir_str, no_verify=False):
    account_id, api_token = get_credentials()
    if not account_id or not api_token:
        print("ERROR: missing credentials — run: python crawl.py check-env", file=sys.stderr)
        sys.exit(1)

    output_dir = Path(output_dir_str)
    output_dir.mkdir(parents=True, exist_ok=True)

    endpoint = CF_BASE.format(account_id=account_id) + "/crawl"
    payload = {
        "url": url,
        "limit": limit,
        "depth": depth,
        "formats": ["markdown"],
    }

    print(f"Starting crawl: {url} (limit={limit}, depth={depth})")

    # Start job
    verify = not no_verify
    result = api_request("POST", endpoint, api_token, data=payload, verify_ssl=verify)

    # Cloudflare may return results directly or a job ID
    if isinstance(result, dict) and result.get("success") is False:
        errors = result.get("errors", [])
        print(f"API error: {errors}", file=sys.stderr)
        sys.exit(1)

    # Handle direct results (sync response)
    pages = None
    if isinstance(result, dict):
        inner = result.get("result")
        if isinstance(inner, list):
            # Sync response with pages list
            pages = inner
        elif isinstance(inner, str):
            # Async job — result is the job ID string
            job_id = inner
            poll_url = CF_BASE.format(account_id=account_id) + f"/crawl/{job_id}"
            print(f"Job started: {job_id}")
            pages = poll_job(poll_url, api_token, verify)
        elif isinstance(inner, dict) and "id" in inner:
            # Async job — result is an object with id
            job_id = inner["id"]
            poll_url = CF_BASE.format(account_id=account_id) + f"/crawl/{job_id}"
            print(f"Job started: {job_id}")
            pages = poll_job(poll_url, api_token, verify)
        elif "id" in result:
            job_id = result["id"]
            poll_url = CF_BASE.format(account_id=account_id) + f"/crawl/{job_id}"
            print(f"Job started: {job_id}")
            pages = poll_job(poll_url, api_token, verify)
    elif isinstance(result, list):
        pages = result

    if pages is None:
        print(f"Unexpected response structure: {json.dumps(result)[:200]}", file=sys.stderr)
        sys.exit(1)

    # Save pages
    seen_slugs = set()
    saved_files = []
    for page in pages:
        filepath = save_page(page, output_dir, seen_slugs)
        saved_files.append(filepath)

    # Summary
    total_size = sum(f.stat().st_size for f in saved_files)
    print(f"\nPages crawled : {len(saved_files)}")
    print(f"Output dir    : {output_dir_str}")
    print(f"Total size    : {total_size // 1024} KB")
    print("\nFiles saved:")
    for f in saved_files:
        print(f"  {f}")


def poll_job(poll_url, api_token, verify_ssl=True):
    """Poll a crawl job until it completes, returning the pages list."""
    while True:
        result = api_request("GET", poll_url, api_token, verify_ssl=verify_ssl)
        data = result.get("result", result)
        status = data.get("status", "")
        finished = data.get("finished", 0)
        total = data.get("total", "?")

        if status in ("complete", "completed", "done"):
            records = data.get("records", data.get("pages", data.get("results", [])))
            print(f"Done. {len(records)} pages crawled.")
            return records
        elif status in ("failed", "error"):
            print(f"Job failed: {data}", file=sys.stderr)
            sys.exit(1)
        else:
            pct = f"{int(finished / total * 100)}%" if isinstance(total, int) and total > 0 else "..."
            print(f"Crawling... {finished}/{total} pages ({pct})")
            time.sleep(POLL_INTERVAL)


def main():
    parser = argparse.ArgumentParser(description="Cloudflare Browser Rendering crawl helper")
    subparsers = parser.add_subparsers(dest="command")

    # check-env subcommand
    subparsers.add_parser("check-env", help="Verify credentials are set")

    # crawl subcommand
    crawl_parser = subparsers.add_parser("crawl", help="Crawl a URL")
    crawl_parser.add_argument("--url", required=True)
    crawl_parser.add_argument("--limit", type=int, default=20)
    crawl_parser.add_argument("--depth", type=int, default=3)
    crawl_parser.add_argument("--output", default="./crawl-output")
    crawl_parser.add_argument("--no-verify", action="store_true", help="Disable SSL verification")

    args = parser.parse_args()

    if args.command == "check-env":
        check_env()
    elif args.command == "crawl":
        run_crawl(args.url, args.limit, args.depth, args.output, no_verify=args.no_verify)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
