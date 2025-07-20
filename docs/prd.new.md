goal

persist and fetch food reviews via aws; ui still deployed on vercel.

add lightweight user registry so every review can be attributed to one of the 15 colleagues without touching the backend.

frontend stack now Svelte 5 SPA using a component library (e.g., Skeleton UI); built with Vite, exported to static assets, and served from Vercel’s edge CDN.

⸻

user stories
	•	browse reviews – anonymous visitor fetches list (GET /reviews).
	•	add review – reviewer submits new entry (POST /reviews).
	•   clearly view dishes or lunchboxes	
	•	first-time register – on first visit the app shows a modal with a searchable list of the 15 predefined users; the visitor picks their name.
	•	auto sign-in – thereafter the app restores the last-chosen user id from localStorage (fallback: IP + UA hash) and skips the modal.
	•	switch user – current user name appears in the top-right profile menu; clicking opens the same searchable list to change identity.

⸻

architecture

vercel (svelte-5 static) → api gateway → lambda → dynamodb      # reviews
vercel (svelte-5 static) ─────────────────────────────────────── # users

	•	ui – Svelte 5 SPA compiled by Vite; delivered as static files via Vercel edge CDN.
	•	reviews – HTTP API backed by AWS Lambda → DynamoDB (unchanged).
	•	users – static users.json inside the app bundle (~1 KB, 15 objects).
	•	chosen user id persisted in localStorage:userId – no cookies or server round-trip.

⸻

data contracts

// users.json (static)
[
  { "id": "alice",   "name": "Alice" },
  { "id": "bob",     "name": "Bob"   },
  // … total 15 records …
]

// POST /reviews payload
{
  "place"    : "Reload",
  "dish"     : "Falafel dish",
  "rating"   : 7.5,
  "userId"   : "alice",          // picked from registry
  "comment"  : "crisp + tahini",
  "createdAt": "2025-07-20T10:00:00Z"
}


⸻

non-functional
	•	p95 latency < 1 s end-to-end.
	•	infra cost ≤ AWS free tier at ≤1 k req/mo and ≤300 items/mo.
	•	registry modal TTI < 100 ms (all data in-memory).

⸻

(future not relevant now)
open questions / risks
	1.	auth hardening – current scheme is “choose then trust”; later upgrade path could be Cognito or WorkSpaces SSO.
	2.	user enumeration – static list is exposed; acceptable for internal team but revisit if public launch.
	3.	device reset – clearing storage triggers modal again; acceptable edge case.

⸻

out of scope (v1)
	•	invitations / CRUD users
	•	passwords or OAuth
	•	role-based permissions