# Cloudflare Browser Rendering API

> Sources:
> - Crawl endpoint: https://developers.cloudflare.com/browser-rendering/rest-api/crawl-endpoint/
> - Limits: https://developers.cloudflare.com/browser-rendering/limits/#crawl-endpoint-limits

## Endpoints

**Start crawl (async)**
```
POST https://api.cloudflare.com/client/v4/accounts/{account_id}/browser-rendering/crawl
```

**Poll job status**
```
GET https://api.cloudflare.com/client/v4/accounts/{account_id}/browser-rendering/crawl/{job_id}
```

## Auth Header

```
Authorization: Bearer {CLOUDFLARE_API_TOKEN}
```

## Request Body (POST)

```json
{
  "url": "https://example.com",
  "limit": 50,
  "depth": 3,
  "formats": ["markdown"]
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `url` | string | required | Seed URL to start crawling from |
| `limit` | integer | 10 | Max pages to crawl (max 100,000) |
| `depth` | number | — | Max link depth from starting URL |
| `formats` | array | `["html"]` | Response format: `["markdown"]`, `["html"]`, or `["json"]` |
| `render` | boolean | true | Whether to execute JavaScript |
| `source` | string | — | URL discovery: `all`, `sitemaps`, or `links` |

> **Note:** `maxDepth` and `responseFormat` are **not** valid — use `depth` and `formats` instead.

## Job Status Response

```json
{
  "success": true,
  "result": {
    "id": "job-uuid",
    "status": "completed",
    "total": 50,
    "finished": 29,
    "skipped": 3,
    "browserSecondsUsed": 12.4,
    "records": [
      {
        "url": "https://example.com/page",
        "status": "completed",
        "metadata": {
          "status": 200,
          "title": "Page Title",
          "url": "https://example.com/page",
          "lastModified": ""
        },
        "markdown": "# Page Title\n\nContent here...",
        "html": "<!DOCTYPE html>..."
      }
    ]
  }
}
```

**Status values**: `running`, `completed`, `cancelled_due_to_limits`, `cancelled_due_to_timeout`, `cancelled_by_user`, `disallowed`, `errored`

> **Note:** Pages are in `result.records` (not `pages`). Content key depends on `formats`: `record.markdown` or `record.html`.

## API Token Permissions

Create token at `dash.cloudflare.com → My Profile → API Tokens`:
- Zone: Browser Rendering → Edit
- Or use "Create Additional Tokens" template

## Rate Limits

> Source: https://developers.cloudflare.com/browser-rendering/limits/#crawl-endpoint-limits

### Workers Free Plan
| Limit | Value |
|---|---|
| Crawl jobs per day | **5** |
| Max pages per crawl | 100 |
| REST API requests | 6/min (1 every 10s) |
| Browser time per day | 10 minutes |
| Concurrent browsers | 3 |

### Workers Paid Plan
| Limit | Value |
|---|---|
| Crawl jobs per day | Unlimited (pricing-based) |
| Max pages per crawl | 100,000 |
| REST API requests | 600/min (10/s) |
| Concurrent browsers | 30 |

> **Important:** Rate limits use a fixed per-second fill rate (not burst). A `429` on job creation usually means the **5 jobs/day** limit was hit — resets at midnight UTC.

> **Tip:** Use `render: false` for static sites — avoids consuming browser time quota. During beta, render-enabled crawls consume browser quota while `render: false` does not.

## Troubleshooting

**SSL errors (Python)**
- The script retries with `--no-verify` automatically
- Or use curl: `curl -k ...`

**401 Unauthorized**
- Check `CLOUDFLARE_API_TOKEN` is valid and has Browser Rendering permission

**403 Forbidden**
- Check `CLOUDFLARE_ACCOUNT_ID` is correct (from dash.cloudflare.com URL)

**Job stuck in "running"**
- Some sites block crawlers — try with a different `--depth`
- Large sites may take several minutes
