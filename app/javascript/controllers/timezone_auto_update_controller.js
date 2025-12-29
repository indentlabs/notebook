import { Controller } from "stimulus"

export default class extends Controller {
    static values = {
        currentTimezone: String,
        updatedAt: Number,  // Unix timestamp
        updateUrl: String
    }

    connect() {
        this.maybeAutoUpdate()
    }

    maybeAutoUpdate() {
        // Skip if already attempted this session
        if (sessionStorage.getItem('timezone_auto_updated')) return

        // Check if within migration window (before Jan 31, 2026)
        const cutoffDate = new Date('2026-01-31T23:59:59Z')
        if (new Date() > cutoffDate) return

        // Check if user has default UTC timezone
        if (this.currentTimezoneValue !== 'UTC') return

        // Check if user was created/updated before 2026 (before feature launch)
        const featureLaunchDate = new Date('2026-01-01T00:00:00Z')
        const userUpdatedAt = new Date(this.updatedAtValue * 1000)
        if (userUpdatedAt >= featureLaunchDate) return

        // Detect browser timezone
        const detectedTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone
        if (!detectedTimezone || detectedTimezone === 'UTC') return

        // Mark as attempted
        sessionStorage.setItem('timezone_auto_updated', 'true')

        // Send update request
        this.updateTimezone(detectedTimezone)
    }

    async updateTimezone(timezone) {
        try {
            const response = await fetch(this.updateUrlValue, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ time_zone: timezone })
            })
            if (response.ok) {
                console.log('Timezone auto-updated to:', timezone)
            }
        } catch (e) {
            console.warn('Failed to auto-update timezone:', e)
        }
    }
}
