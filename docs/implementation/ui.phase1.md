# Phase 1 – UI Skeleton PRD

## Objective
Deliver the frontend skeleton that runs entirely in the browser, powered by static assets and fake in-memory data, so that the team can validate UX early and iterate before wiring the backend.

## Deliverables
- Single-page app built with Svelte 5 + Skeleton UI, deployed to a Vercel preview URL.
- Static `users.json` (≈15 colleagues) bundled with the build.
- Stub `api` module that returns hard-coded reviews and accepts new ones in memory.

## Core user flows
1. **Select user**
   - First visit → modal lists colleagues (name + generic avatar).
   - Choice stored under `localStorage.userId`.
   - “Switch user” button in header resets storage and re-opens modal.

2. **Browse reviews**
   - On load, call `api.listReviews()` to get array of fake reviews.
   - Render responsive cards sorted by newest first.

3. **Add review**
   - Floating “＋” button opens modal form (place, dish / lunchbox, rating 1-5, optional comment).
   - On submit, push review into in-memory array, close modal, optimistic update list.

4. **Top category toggle reviews**
   - Top toggle group with three options: **All**, **Dish**, **Lunchbox**.
   - Autocomplete search adapts to the selected type (shows relevant items or all when "All" is active).
   - Filtering happens instantly in the client.

5. **Categories for filtering reviews**
Categories block renders dynamic groups fetched from `review.category`:
  - Wrapper: `<div id="categories" class="categories">` (grid layout).
  - Each category section:
    - `<div class="category">` container with subtle card styling.
    - Header: `<h2 class="category-title">{Category Name}</h2>`.
    - Reviews grid: `<div class="reviews-grid">` using CSS grid to lay out cards.
    - Each **ReviewCard** structure:
      - `.review-header` flex row → `.review-place` + `.review-rating`.
      - `.review-dish` (italic), `.review-reviewer`, `.review-date`.
      - `.review-notes` paragraph.
  - Categories appear after the filter bar; visibility is controlled via JS (`display: none` until data loads).

## Screens & components
- `AppLayout` (top bar with logo + switch-user)
- `UserSelectModal`
- `ReviewList`
- `ReviewCard`
- `FilterBar`
- `AddReviewButton`
- `AddReviewModal`

## Non-functional requirements
- Time-to-interactive ≤ 100 ms on a cold Vercel edge visit.
- Mobile viewport 375 px fully functional; desktop scales up gracefully.
- Lighthouse performance ≥ 90.
- `+layout.svelte`: Global wrapper containing the header.
- `+page.svelte`: Main page component that orchestrates the filters and the list.
- `Header.svelte`: Top bar with title and "Switch User" button.
- `UserSelectModal.svelte`: Modal for first-time user selection.
- `FilterBar.svelte`: Contains the "All/Dish/Lunchbox" toggle and the autocomplete search.
- `Toggle.svelte`: The reusable toggle component.
- `ReviewList.svelte`: Manages fetching and rendering of `ReviewCard` components.
- `ReviewCard.svelte`: Displays a single review.
- `AddReviewButton.svelte`: The floating action button.
- `AddReviewModal.svelte`: The form for submitting a new review.

## Tech decisions
- Routing: `/` shows list; `/add` optional deep link to add modal.
- State: Svelte stores (`src/lib/stores.ts`) for managing user, reviews, and filters.
- Styling: Skeleton UI default theme; no custom CSS yet.
- API: A fake `api.js` module in `src/lib/` will provide in-memory data.
- Icons: Tabler Icons via CDN.

## Out of scope for phase 1
- Real API integration.
- Authentication beyond the choose-then-trust modal.
- Persistent storage; page refresh resets reviews list.

## Acceptance criteria
- All four core flows complete without errors in Chrome latest.
- `npm run check` passes (type-check + lint + tests).
- All components in `src/routes` and `src/lib` are implemented as described in `docs/page-structure.md`.
- PR reviewed and approved by at least one teammate.

## Timeline (7-day sprint)
| Day | Focus |
| --- | --- |
| 1 | Scaffold project, commit Skeleton UI, push to Vercel |
| 2 | Implement `UserSelectModal` + localStorage persistence |
| 3 | Build `ReviewList` with hard-coded data |
| 4 | Implement `AddReviewModal` and optimistic update |
| 5 | Add `FilterBar`, finish responsive tweaks |
| 6 | Manual QA, bug fixes, polish interactions |
| 7 | Tag v0.1, deploy preview, gather feedback |
