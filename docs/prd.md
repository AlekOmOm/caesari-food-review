# Caesari Food Reviews

## vision

- simple singular source of truth for Caesari food reviews

## user stories

- as a Caesari employee, i want to add a review
  - easily and quickly
     - by CLI (mkcli)
     - by web interface
     - by slack command
- as a Caesari employee, i want to view reviews
- as a Caesari employee, i want to view reviews by dish
- as a Caesari employee, i want to view reviews by lunchbox
- as a Caesari employee, i want to view reviews by sub-categories of dish and lunchbox

## features

- add a review
- categorize review as dish (ordered) or lunchbox (self-brought)
- view reviews
- view reviews by dish
- view reviews by lunchbox
- view reviews by caesari fridge edible

### MVP extension

1) Lunchbox category

## tech stack

### current state

- static HTML site hosted on Vercel
- reviews generated at build time; new reviews require repository commit
- no on-site form to add review

### current limitations

- cannot add reviews directly through the website due to static hosting constraints
- each new review requires a code change and redeployment
- lunchbox category not yet fully implemented in data model

### (possible) future state

- migrate to a hosting solution that supports serverless functions or a backend (e.g. Vercel Edge Functions, Supabase, etc.)
- provide authenticated form to submit reviews directly on site
- store reviews in a persistent database for real-time retrieval
- fully support lunchbox category alongside dishes