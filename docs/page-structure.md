# Page Structure

## Current (Monolithic `index.html`)

- **Header**: Title, subtitle, stats (`totalReviews`, `avgRating`, `totalReviewers`), and a link to add a review.
- **Rating Scale**: Static HTML block explaining the rating system.
- **Filters**: Buttons for "All", "High Rated", "Recent", and a placeholder for reviewer filters.
- **Loading/Error**: Placeholders.
- **Categories**: A single container (`#categories`) where JavaScript injects all review cards, grouped by category titles.
- **Logic**: A large `<script>` block in the HTML file handles everything: data fetching, filtering, rendering, and event handling.

## Desired Structure

```
.
├── index.html      // (Main HTML file)
├── style.css       // (CSS for styling)
├── app.js          // (JavaScript for application logic)
└── lib/
    ├── api.js      // (Handles API calls)
    └── users.json  // (User data)

```
