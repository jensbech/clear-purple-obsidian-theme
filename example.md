# API Integration

## Overview

REST API for managing product catalogue and pricing. Authentication via API key header on all requests.

Base URL: `https://api.example.com/v2`

## Authentication

All requests require the `X-ApiKey` header. Keys are scoped per environment.

```bash
curl -X GET "https://api.example.com/v2/products" \
  -H "X-ApiKey: your-api-key-here" \
  -H "Accept: application/json" | jq
```

## Endpoints

### Products

```http
GET  /products
GET  /products/:id
POST /products
PUT  /products/:id
```

#### Query parameters

| Param | Type | Description |
|---|---|---|
| `status` | string | `active` \| `archived` |
| `limit` | number | Max results (default 20) |
| `offset` | number | Pagination offset |

#### Example response

```json
{
  "data": [
    {
      "id": "prod_1a2b3c",
      "name": "Wireless Headphones Pro",
      "status": "active",
      "price": 2499,
      "currency": "NOK",
      "stock": 142
    }
  ],
  "meta": {
    "total": 84,
    "limit": 20,
    "offset": 0
  }
}
```

### Pricing

##### Notes

- Prices are in minor units (øre/cents)
- VAT is not included unless `include_vat=true` is passed
- Bulk pricing tiers apply automatically above threshold quantities

```python
import httpx

client = httpx.Client(base_url="https://api.example.com/v2")
client.headers["X-ApiKey"] = "your-api-key"

res = client.get("/products", params={"status": "active", "limit": 5})
res.raise_for_status()
print(res.json())
```

## Error Handling

###### Common codes

- `401` — missing or invalid API key
- `404` — resource not found
- `429` — rate limit exceeded (retry after `Retry-After` header)
- `500` — internal error, safe to retry with backoff

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Retry after 30 seconds.",
    "retryAfter": 30
  }
}
```

# Deployment

## Environments

| Env | URL | Notes |
|---|---|---|
| Dev | `https://dev-api.example.com` | Resets nightly |
| Staging | `https://staging-api.example.com` | Mirrors prod data |
| Prod | `https://api.example.com` | Live traffic |

## CI/CD

### Build

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build
      - run: npm run deploy
```

### Rollback

```bash
git revert HEAD --no-edit
git push origin main
```
