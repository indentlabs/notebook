import { Controller } from "stimulus"

export default class extends Controller {
    static values = {
        userId: String,
        following: Boolean
    }

    static targets = ["text", "icon"]

    connect() {
        // Initialize state from data attribute if needed, 
        // but values are already set via data-follow-button-following-value
    }

    toggle(event) {
        event.preventDefault()

        const button = this.element
        const isFollowing = this.followingValue

        // Disable button during request
        button.disabled = true
        button.style.opacity = '0.7'

        // Determine action and endpoint
        const action = isFollowing ? 'DELETE' : 'POST'
        const endpoint = isFollowing ? `/users/${this.userIdValue}/unfollow` : `/users/${this.userIdValue}/follow`

        fetch(endpoint, {
            method: action,
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            credentials: 'same-origin'
        })
            .then(response => {
                if (response.ok) {
                    // Toggle the follow state
                    const newFollowingState = !isFollowing
                    this.followingValue = newFollowingState

                    // Update button appearance
                    if (newFollowingState) {
                        button.classList.remove('bg-blue-600', 'hover:bg-blue-700', 'text-white')
                        button.classList.add('bg-gray-100', 'dark:bg-gray-700', 'hover:bg-gray-200', 'dark:hover:bg-gray-600', 'text-gray-700', 'dark:text-gray-200')
                        this.textTarget.textContent = 'Following'
                        this.iconTarget.textContent = 'check'
                    } else {
                        button.classList.remove('bg-gray-100', 'dark:bg-gray-700', 'hover:bg-gray-200', 'dark:hover:bg-gray-600', 'text-gray-700', 'dark:text-gray-200')
                        button.classList.add('bg-blue-600', 'hover:bg-blue-700', 'text-white')
                        this.textTarget.textContent = 'Follow User'
                        this.iconTarget.textContent = 'person_add'
                    }

                    // Show success notification
                    this.showNotification(newFollowingState ? 'Now following user!' : 'Unfollowed user', 'success')
                } else {
                    throw new Error('Network response was not ok')
                }
            })
            .catch(error => {
                console.error('Error:', error)
                this.showNotification('Failed to update follow status', 'error')
            })
            .finally(() => {
                // Re-enable button
                button.disabled = false
                button.style.opacity = '1'
            })
    }

    showNotification(message, type) {
        if (typeof window.showNotification === 'function') {
            window.showNotification(message, type)
        } else {
            alert(message)
        }
    }
}
