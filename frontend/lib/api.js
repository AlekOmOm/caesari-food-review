const API_URL = 'https://1u5t1vutr1.execute-api.us-east-1.amazonaws.com';

// This file will handle API calls.

async function getUsers() {
    try {
        const response = await fetch('lib/users.json');
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        const users = await response.json();
        return users;
    } catch (error) {
        console.error('Failed to fetch users:', error);
        return [];
    }
}

// Mock API functions that will be replaced with real AWS API calls in phase 2
const api = {
    async listReviews() {
        const response = await fetch(`${API_URL}/reviews`);
        const data = await response.json();
        return data;
    },

    async addReview(reviewData) {
        const response = await fetch(`${API_URL}/reviews`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(reviewData),
        });
        const data = await response.json();
        return data;
    },

    async createReview(reviewData) {
        // Alias for addReview for consistency
        return this.addReview(reviewData);
    },

    async updateReview(id, reviewData) {
        // For now, just return the updated review
        // In phase 2, this will PUT to AWS API Gateway
        await new Promise(resolve => setTimeout(resolve, 100));
        return { ...reviewData, id };
    },

    async deleteReview(id) {
        // For now, just return success
        // In phase 2, this will DELETE to AWS API Gateway
        await new Promise(resolve => setTimeout(resolve, 100));
        return { success: true };
    }
};

// Export for future use
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { getUsers, api };
}
