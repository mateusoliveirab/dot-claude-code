# Cloudflare Browser Rendering API

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
  "maxDepth": 3,
  "allowExternalLinks": false,
  "onlyMainContent": true,
  "responseFormat": "markdown"
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `url` | string | required | Seed URL to start crawling from |
| `limit` | integer | 20 | Max pages to crawl |
| `maxDepth` | integer | 3 | Max link depth from seed |
| `allowExternalLinks` | boolean | false | Follow links to other domains |
| `onlyMainContent` | boolean | true | Strip nav/footer/ads |
| `responseFormat` | string | "markdown" | `"markdown"` or `"html"` |

## Job Status Response

```json
{
  "success": true,
  "result": {
    "id": "job-uuid",
    "status": "complete",
    "crawled": 29,
    "total": 50,
    "pages": [
      {
        "url": "https://example.com/page",
        "markdown": "# Page Title\n\nContent here..."
      }
    ]
  }
}
```

**Status values**: `pending`, `running`, `complete`, `failed`

## API Token Permissions

Create token at `dash.cloudflare.com → My Profile → API Tokens`:
- Zone: Browser Rendering → Edit
- Or use "Create Additional Tokens" template

## Rate Limits

- Rate limits apply per account (check Cloudflare dashboard for current limits)
- Max pages per crawl job depends on your plan
- Async jobs expire — poll promptly after starting

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
