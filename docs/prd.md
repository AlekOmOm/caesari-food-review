# Caesari Food Reviews

## vision

- frictionless single source of truth for Caesari lunch & dish reviews
- zero-maintenance, almost zero-cost stack: static UI on Vercel, serverless backend on AWS
- small but delightful product to learn essential AWS services without changing the current workflow

## user stories

- as a Caesari employee, i want to browse all reviews anonymously
- as a Caesari employee, i want to filter reviews by dish
- as a Caesari employee, i want to filter reviews by lunchbox
- as a Caesari employee, i want to add a review in seconds
- as a Caesari employee, i want my name to persist between visits without logging in
- as a Caesari employee, i want to switch user when sharing a device

## features

- add review (place, dish/lunchbox, rating, comment)
- lightweight user registry (15 predefined colleagues) picked once and cached in localStorage
- browse reviews list
- top toggle filter ( **All / Dish / Lunchbox** ) to instantly switch list mode
- filter reviews by dish
- filter reviews by lunchbox
- categorize review as dish (ordered) or lunchbox (self-brought)
- data persisted in DynamoDB and served via REST API

### MVP extension

## tech stack

- Plain HTML, CSS, and JavaScript
- static assets delivered by Vercel edge CDN
- users registry bundled as `users.json` inside the app
- API Gateway (HTTP API) → Lambda (Node 20 ESM) → DynamoDB `reviews` table
- IaC via Serverless Framework, deployed by GitHub Actions

## non-functional requirements

- p95 latency < 1 s end-to-end
- infrastructure cost within AWS free tier at ≤1 k req/mo and ≤300 writes/mo
- user registry modal TTI < 100 ms

## open questions / risks

- upgrade path from "choose-then-trust" to proper auth (e.g., Cognito)
- static user list public exposure; acceptable for internal use, revisit if public launch
- clearing browser storage resets chosen user; acceptable edge case