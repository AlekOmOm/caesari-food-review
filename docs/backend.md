# mental model — “backend” = three managed pieces glued by a tiny config file

## 0 mental model

```
browser  ──►  api-gateway-url                # https https
                   │
                   ▼
            aws api gateway (http api)
                   │ invokes
                   ▼
            aws lambda  (node 20)
                   │ uses sdk
                   ▼
            dynamodb table  reviews
```

⸻

## 1 serverless.yml → infrastructure blueprint

```yaml
service: reviews           # stack name
provider:
  name: aws
  runtime: nodejs20.x
  environment:
    TABLE: reviews         # passed into lambda
functions:
  api:
    handler: lambda.handler
    events:
      - httpApi: 'GET /reviews'
      - httpApi: 'POST /reviews'
resources:
  Resources:
    ReviewsTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: reviews
        BillingMode: PAY_PER_REQUEST
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH

```

what it does when you run serverless deploy:

1. packages lambda.js into a zip, pushes to s3.
2. generates a CloudFormation template merging the zip, the table, and an HTTP API.
3. CloudFormation creates:
   - dynamodb table reviews (on-demand billing).
   - lambda function reviews-dev-api.
   - api gateway http api with two routes → lambda integration.
4. outputs the public api url.

all of this lives in a stack called reviews-dev; tear-down with serverless remove.

⸻

## 2 lambda.js → compute & data logic

```js
import { DynamoDBClient, PutItemCommand, ScanCommand } from '@aws-sdk/client-dynamodb';
import crypto from 'crypto';

const db  = new DynamoDBClient({});
const tbl = process.env.TABLE;

export async function handler (evt) {
  if (evt.httpMethod === 'POST') {
    const r = JSON.parse(evt.body);
    await db.send(new PutItemCommand({
      TableName: tbl,
      Item: {
        id:   { S: crypto.randomUUID() },
        user: { S: r.userId },
        place:{ S: r.place },
        dish: { S: r.dish },
        rating:{ N: r.rating.toString() },
        comment:{ S: r.comment ?? '' },
        ts:   { S: new Date().toISOString() }
      }
    }));
    return { statusCode: 201, body: '{}' };
  }

  const out = await db.send(new ScanCommand({ TableName: tbl }));
  return { statusCode: 200, body: JSON.stringify(out.Items) };
}
```

## runtime path

```
	1.	api gateway receives an https request.
	2.	gateway serialises it as evt and invokes lambda.
	3.	handler decides on GET vs POST.
	4.	uses aws-sdk v3 to scan or putItem in dynamodb.
	5.	returns { statusCode, body }; gateway turns that into the http response.
```

cold start ≈ 200 ms once, then warm invocations ≈ 5–20 ms for such tiny code.

⸻

## 3 api.js in spa → happy wrapper

```js
const base = import.meta.env.PUBLIC_API_URL;

export const listReviews = () =>
  fetch(`${base}/reviews`).then(r => r.json());

export const saveReview = (review) =>
  fetch(`${base}/reviews`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(review)
  });

```

- vite injects PUBLIC_API_URL at build time (set in vercel env panel).
- svelte components call listReviews() or saveReview(); everything else is UI state.
- no aws credentials touch the browser.

⸻

## 4 how scaling & billing work

| piece | scaling logic | free tier | you pay when … |
|-------|---------------|-----------|----------------|
| api gateway | auto-adds concurrent  ↗ routes | 1 M requests/mo | > 1 M req |
| lambda | 1 function = N concurrent copies | 1 M req + 400 k GB-s/mo | > those caps |
| dynamodb | on-demand → instant r/w capacity | 25 GB + 200 M ops/mo | > ops/storage |

your load (≤ 1 k req, 300 writes / mo) stays under every limit → $0.
⸻

## 5 permissions (iam)

```
serverless auto-creates a role:

λ-role
  ├─ dynamodb:PutItem on reviews
  └─ dynamodb:Scan    on reviews

least-privilege; nothing else can touch the table.

```
⸻

## 6 deploy cycle recap

```
git push
│
├─ vercel → build svelte → cdn
│            (reads PUBLIC_API_URL)
│
└─ gh action (optional) → serverless deploy
     → cloudformation update

result: any browser that hits your vercel url talks to aws like a microservice, yet you never manage a server.

that’s the whole backend story — three managed services + two tiny files. tweak the lambda if schema evolves; everything else scales automatically.
```