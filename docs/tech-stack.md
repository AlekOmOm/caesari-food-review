stack, layer by layer

ui
  └─ plain html, js, css
hosting
  └─ vercel static  – push → build → edge cdn
api gateway
  └─ aws http api  – single route /reviews → lambda
compute
  └─ aws lambda (node 20 esm)  – 1 fn handles GET + POST
data
  └─ dynamodb table reviews(id pk)  – on-demand mode
registry
  └─ users.json  – bundled in spa, cached forever, id saved in localStorage
observability
  └─ cloudwatch logs + metrics (lambda & api gw)
iac / ci
  └─ aws sam or serverless.yml, shipped by github actions


⸻

why each piece
	•	vercel static – zero-config deploy, global cdn, instant rollbacks.
	•	plain html, js, css – no complex build step.
	•	aws http api – cheaper & simpler than rest api; native jwt/CORS; <$0.001 per 1 k calls.
	•	lambda – pay-per-ms, auto-scale to zero; free tier → 1 M req + 400 k GB-s every month forever  ￼ ￼.
	•	dynamodb – zero admin nosql; always-free 25 GB storage + 200 M ops/mo (= 25 RCU/WCU)  ￼.
	•	users.json – only 15 rows; no need for db round-trip or auth server.

cost at your current load (≪1 k req/mo, 300 writes/mo): $0.

⸻

request flow

browser
  ├─ first visit → fetch('/users.json') → modal pick id → save to localStorage
  ├─ list reviews → GET {api}/reviews        ──┐
  └─ new review  → POST {api}/reviews payload ─┴──► api gw → lambda → dynamodb


⸻

lambda sketch (node 20 / esm)

import { DynamoDBClient, PutItemCommand, ScanCommand } from '@aws-sdk/client-dynamodb';
const db  = new DynamoDBClient({});
const tbl = process.env.TABLE;   // 'reviews'

export const handler = async evt => {
  if (evt.httpMethod === 'POST') {
    const r = JSON.parse(evt.body);
    await db.send(new PutItemCommand({
      TableName: tbl,
      Item: {
        id:   { S: crypto.randomUUID() },
        user: { S: r.userId },
        ...['place','dish','rating','comment'].reduce((o,k)=>({...o,[k]:{S:r[k].toString()}}),{}),
        ts:   { S: new Date().toISOString() }
      }
    }));
    return { statusCode: 201, body: '{}' };
  }

  const out = await db.send(new ScanCommand({ TableName: tbl }));
  return { statusCode: 200, body: JSON.stringify(out.Items) };
};

IAM role: dynamodb:PutItem + dynamodb:Scan on that table only.

⸻

svelte helper (src/lib/api.ts)

const base = import.meta.env.PUBLIC_API_URL;

export const listReviews = () =>
  fetch(`${base}/reviews`).then(r => r.json());

export const saveReview = (r) =>
  fetch(`${base}/reviews`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(r)
  });

env PUBLIC_API_URL is set in vercel → available at build & runtime.

⸻

infra bootstrap (serverless.yml minimal)

service: reviews
provider:
  name: aws
  runtime: nodejs20.x
  environment:
    TABLE: reviews
functions:
  api:
    handler: aws/handler.handler
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

npx serverless deploy → outputs the api url; copy it to vercel env.

⸻

getting started checklist
	1.	aws account → create IAM user with adminAccess for bootstrap only.
	2.	create `index.html`, `style.css`, and `app.js`.
	3.	add `users.json` in `static/`.
	4.	implement modal → on page load, read `localStorage.userId` || `null`.
	5.	scaffold lambda + serverless.yml.
	6.	deploy: `sls deploy`.
	7.	set `PUBLIC_API_URL` in vercel dashboard.
	8.	`git push` → vercel build → open your cdn url.

monitor with CloudWatch Logs → filter on `REPORT` lines to see duration / memory.

⸻

next steps / curiosities
	•	switch API Gateway → Lambda URL to save $0.009 per M calls (trade-off: no CORS auto-config).
	•	enable DynamoDB fine-grained access if you add auth later.
	•	use AWS CDK instead of Serverless if you prefer Typescript infra code.
	•	local dev: `docker run -p 8000:8000 amazon/dynamodb-local` + `sam local start-api`.

this gives you a fully serverless, pay-per-use backend, while keeping the ui workflow you already know.