# Roadmap

## phase 0 – bootstrap

- [x] create AWS root user and IAM admin for deployment
- [x] install and configure AWS CLI + Serverless Framework locally
- [x] create GitHub repo (private)

## phase 1 – ui skeleton

- [x] create `index.html`, `style.css`, `colors.css`, `app.js`
- [x] create `lib/` directory with `users.json` and `api.js`
- [x] implement user-select modal (reads from users.json, persists to localStorage)
- [x] stub api module with fake in-memory data for now
- [x] deploy preview to Vercel (static hosting)

## phase 2 – backend

- [ ] scaffold Serverless service `reviews`
- [ ] write Lambda handler (GET + POST)
- [ ] define DynamoDB table `reviews` (PK id)
- [ ] configure HTTP API Gateway routes and CORS
- [ ] deploy to AWS, note API URL

## phase 3 – connect ui ↔ api

- [ ] set `PUBLIC_API_URL` env in Vercel
- [ ] replace fake api with real fetch calls
- [ ] handle optimistic UI update on save review
- [ ] test end-to-end locally (Vercel preview ↔ AWS api)

## phase 4 – ci/cd

- [ ] GitHub Actions workflow: build UI, deploy to Vercel
- [ ] GitHub Actions workflow: deploy Serverless (on infra dir changes)
- [ ] protect main branch with PR checks

## phase 5 – observability & polish

- [ ] enable CloudWatch Logs → explore latency & errors
- [ ] add basic skeuomorphic rating stars in UI
- [ ] graceful error toast on failed save
- [ ] responsive tweaks for mobile viewport

## done / mvp shipped

- [ ] announce to Caesari channel
- [ ] gather feedback for next iteration