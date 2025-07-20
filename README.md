# Caesari Food Reviews - Phase 1

A collaborative food review platform for the Caesari team.

## Features Implemented (Phase 1)

- ✅ User selection modal with localStorage persistence
- ✅ Browse reviews with responsive card layout
- ✅ Add new reviews via modal form
- ✅ Filter by category (All/Dish/Lunchbox)
- ✅ Filter by rating (All/High Rated/Recent)
- ✅ Filter by reviewer
- ✅ Real-time statistics display
- ✅ Switch user functionality
- ✅ Mobile-responsive design

## Getting Started

### Local Development

1. Clone the repository
2. Open `index.html` in your browser
3. Select a user from the modal on first visit
4. Start browsing and adding reviews!

### Project Structure

```
food-review/
├── index.html          # Main application
├── style.css           # Application styles
├── app.js              # Basic app entry (minimal)
├── reviews.js          # Sample review data
├── lib/
│   ├── api.js          # Mock API functions (will become real in Phase 2)
│   ├── users.json      # User registry
│   └── build_reviews.js # Build script for review data
├── docs/               # Project documentation
└── guide/              # User guides
```

## Architecture

### Current (Phase 1)
- Static HTML/CSS/JavaScript
- In-memory data storage
- localStorage for user persistence
- Mock API layer for easy transition to Phase 2

### Coming (Phase 2)
- AWS Lambda + API Gateway backend
- DynamoDB for persistent storage
- Real API endpoints

## User Flow

1. **First Visit**: User selection modal appears
2. **Browse Reviews**: View reviews filtered by category, rating, or reviewer
3. **Add Review**: Click "Add Review" button to open form modal
4. **Switch User**: Click "Switch User" to change active user

## Technical Notes

- No build process required - runs directly in browser
- ES6+ features used (async/await, fetch API)
- CSS Grid and Flexbox for responsive layouts
- Mock API layer simulates future AWS integration

## Next Steps (Phase 2)

- Implement AWS Lambda backend
- Replace mock API with real HTTP calls
- Add DynamoDB persistence
- Deploy to production environment 