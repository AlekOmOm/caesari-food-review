document.addEventListener('DOMContentLoaded', () => {
    class FoodReviewApp {
        constructor() {
            this.reviews = [];
            this.categories = {};
            this.currentFilter = 'all';
            this.currentReviewer = 'all';
            this.currentCategory = 'all';
            this.currentUser = null;
            this.init();
        }

        async init() {
            this.initUser();
            if (!this.currentUser) {
                await this.showUserModal();
            } else {
                try {
                    await this.loadReviews();
                    this.setupEventListeners();
                    this.renderReviews();
                    this.updateStats();
                } catch (error) {
                    console.error('Failed to initialize app:', error);
                    this.showError();
                }
            }
        }

        initUser() {
            const userId = localStorage.getItem('userId');
            if (userId) {
                this.currentUser = { id: userId };
                this.updateUserDisplay();
            }
        }

        async showUserModal() {
            const users = await getUsers();
            const userList = document.getElementById('user-list');
            userList.innerHTML = users.map(user => `<li data-id="${user.id}">${user.name}</li>`).join('');
            
            document.getElementById('userModal').style.display = 'flex';

            userList.addEventListener('click', (e) => {
                if (e.target.tagName === 'LI') {
                    const userId = e.target.dataset.id;
                    const userName = e.target.textContent;
                    this.currentUser = { id: userId, name: userName };
                    localStorage.setItem('userId', userId);
                    localStorage.setItem('userName', userName);
                    document.getElementById('userModal').style.display = 'none';
                    this.updateUserDisplay();
                    this.init();
                }
            });
        }

        updateUserDisplay() {
            if (this.currentUser) {
                const userName = localStorage.getItem('userName');
                document.getElementById('currentUser').textContent = `Hi, ${userName}`;
                const userControls = document.querySelector('.user-controls');
                userControls.style.display = 'flex';
                userControls.style.flexDirection = 'column';
                userControls.style.alignItems = 'center';
                userControls.style.gap = '10px';
            }
        }

        async loadReviews() {
            const rawReviews = await api.listReviews();
            this.reviews = rawReviews.map(r => ({ ...r.review, id: r.id }));
            this.organizeByCategory();
        }

        organizeByCategory() {
            this.categories = {};
            this.reviews.forEach(review => {
                const category = review.category || 'dish';
                if (!this.categories[category]) {
                    this.categories[category] = [];
                }
                this.categories[category].push(review);
            });
        }

        setupEventListeners() {
            document.querySelectorAll('.toggle-btn').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    document.querySelectorAll('.toggle-btn').forEach(b => b.classList.remove('active'));
                    e.target.classList.add('active');
                    this.currentCategory = e.target.dataset.category;
                    this.renderReviews();
                });
            });

            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                    e.target.classList.add('active');
                    this.currentFilter = e.target.dataset.filter;
                    this.renderReviews();
                });
            });
            
            this.setupReviewerFilters();

            document.getElementById('switchUserBtn').addEventListener('click', () => {
                localStorage.removeItem('userId');
                localStorage.removeItem('userName');
                this.currentUser = null;
                document.querySelector('.user-controls').style.display = 'none';
                this.showUserModal();
            });

            document.getElementById('addDishReviewBtn').addEventListener('click', () => {
                document.getElementById('addReviewModal').style.display = 'flex';
                document.getElementById('addReviewForm').reset();
                document.getElementById('reviewCategory').value = 'dish';
                document.getElementById('addReviewModalTitle').textContent = 'Add a Dish Review';
                document.getElementById('reviewDish').placeholder = 'Dish name';
            });

            document.getElementById('addLunchboxReviewBtn').addEventListener('click', () => {
                document.getElementById('addReviewModal').style.display = 'flex';
                document.getElementById('addReviewForm').reset();
                document.getElementById('reviewCategory').value = 'lunchbox';
                document.getElementById('addReviewModalTitle').textContent = 'Add a Lunchbox Review';
                document.getElementById('reviewDish').placeholder = 'Lunchbox contents';
            });

            document.getElementById('addReviewForm').addEventListener('submit', (e) => {
                e.preventDefault();
                this.addReview();
            });

            document.getElementById('cancelAddReview').addEventListener('click', () => {
                document.getElementById('addReviewModal').style.display = 'none';
            });
        }

        async addReview() {
            const newReviewData = {
                place: document.getElementById('reviewPlace').value,
                dish: document.getElementById('reviewDish').value,
                category: document.getElementById('reviewCategory').value,
                rating: parseFloat(document.getElementById('reviewRating').value),
                comment: document.getElementById('reviewComment').value,
                reviewer: this.currentUser.id,
                date: new Date().toISOString().split('T')[0]
            };

            await api.addReview(newReviewData);
            this.reviews = await api.listReviews();
            this.organizeByCategory();
            this.renderReviews();
            this.updateStats();
            this.setupReviewerFilters();

            document.getElementById('addReviewForm').reset();
            document.getElementById('addReviewModal').style.display = 'none';
        }

        setupReviewerFilters() {
            const reviewers = ['all', ...new Set(this.reviews.map(r => r.reviewer))];
            const container = document.getElementById('reviewerFilters');
            
            container.innerHTML = reviewers.map(reviewer => 
                `<button class="reviewer-btn ${reviewer === 'all' ? 'active' : ''}" data-reviewer="${reviewer}">
                    ${reviewer === 'all' ? 'All' : reviewer}
                </button>`
            ).join('');
            
            container.querySelectorAll('.reviewer-btn').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    container.querySelectorAll('.reviewer-btn').forEach(b => b.classList.remove('active'));
                    e.target.classList.add('active');
                    this.currentReviewer = e.target.dataset.reviewer;
                    this.renderReviews();
                });
            });
        }

        filterReviews(reviews) {
            let filtered = reviews;
            
            if (this.currentCategory !== 'all') {
                filtered = filtered.filter(r => r.category === this.currentCategory);
            }
            
            if (this.currentReviewer !== 'all') {
                filtered = filtered.filter(r => r.reviewer === this.currentReviewer);
            }
            
            switch (this.currentFilter) {
                case 'high':
                    return filtered.filter(r => r.rating >= 8);
                case 'recent':
                    return filtered.sort((a, b) => new Date(b.date) - new Date(a.date)).slice(0, 5);
                default:
                    return filtered;
            }
        }

        renderReviews() {
            const container = document.getElementById('categories');
            const loading = document.getElementById('loading');
            
            loading.style.display = 'none';
            container.style.display = 'block';
            container.innerHTML = '';

            Object.entries(this.categories).forEach(([categoryName, reviews]) => {
                const filteredReviews = this.filterReviews(reviews);
                if (filteredReviews.length === 0) return;

                const categoryDiv = document.createElement('div');
                categoryDiv.className = 'category';
                
                const categoryTitle = this.formatCategoryName(categoryName);
                categoryDiv.innerHTML = `
                    <h2 class="category-title">${categoryTitle}</h2>
                    <div class="reviews-grid">
                        ${filteredReviews.map(review => this.renderReviewCard(review)).join('')}
                    </div>
                `;
                
                container.appendChild(categoryDiv);
            });
        }

        renderReviewCard(review) {
            const formattedDate = new Date(review.date).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });

            const comment = review.comment || 'No comment provided';

            return `
                <div class="review-card">
                    <div class="review-header">
                        <div class="review-place">${review.place}</div>
                        <div class="review-rating">${review.rating}/10</div>
                    </div>
                    <div class="review-dish">${review.dish}</div>
                    <div class="review-reviewer">${review.reviewer}</div>
                    <div class="review-date">${formattedDate}</div>
                    <div class="review-notes">${comment}</div>
                </div>
            `;
        }

        formatCategoryName(category) {
            return category.split('-').map(word => 
                word.charAt(0).toUpperCase() + word.slice(1)
            ).join(' ');
        }

        updateStats() {
            const totalReviews = this.reviews.length;
            const avgRating = totalReviews > 0 ? 
                (this.reviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews).toFixed(1) : 0;
            const totalReviewers = new Set(this.reviews.map(r => r.reviewer)).size;

            document.getElementById('totalReviews').textContent = totalReviews;
            document.getElementById('avgRating').textContent = avgRating;
            document.getElementById('totalReviewers').textContent = totalReviewers;
        }

        showError() {
            document.getElementById('loading').style.display = 'none';
            document.getElementById('error').style.display = 'block';
        }
    }

    new FoodReviewApp();
}); 