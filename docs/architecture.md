# Architecture

## overview

Caesari Food Reviews is a serverless, two-tier application:

- **UI** – Plain HTML, CSS, and JavaScript, shipped as static files via Vercel edge CDN.
- **API** – AWS HTTP API Gateway → Lambda (Node 20 ESM) → DynamoDB `reviews` table.

All infra is defined with Serverless Framework and deployed from GitHub Actions.

## main components

| layer | component | runtime | purpose |
|-------|-----------|---------|---------|
| UI | HTML/JS/CSS | browser | render app, call API |
| Static hosting | Vercel CDN | N/A | serve UI files globally |
| Registry | `users.json` | browser | local list of 15 colleagues |
| API Gateway | AWS HTTP API | AWS | terminates HTTPS, routes /reviews |
| Compute | AWS Lambda | Node 20 | handle GET/POST, talk to DB |
| Data | DynamoDB table `reviews` | AWS | store reviews PK=id |
| Observability | CloudWatch | AWS | logs + metrics |
| CI/CD | GitHub Actions → Serverless | N/A | deploy infra + lambda |

## logic sketches for components

### UI (JavaScript)

```pseudo
document.addEventListener('DOMContentLoaded', () => {
  userId = localStorage.userId || null;
  if (!userId) {
    showModal(users.json);
  }
  fetch('/reviews', { method: 'GET' }).then(listReviews);
});

btnSave.addEventListener('click', () => {
  fetch('/reviews', { method: 'POST' });
});
```

### Lambda handler

```pseudo
if method == 'POST':
  putItem({ id: uuid4(), user, place, dish, rating, comment, ts: now })
  return 201
else:
  items = scan()
  return 200 + items
```

### CI/CD

```pseudo
github push → build UI → deploy vercel
github push infra/ → serverless deploy
```
