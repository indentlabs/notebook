import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["display"]
    static values = { timezone: String }

    connect() {
        this.updateCountdown()
        this.interval = setInterval(() => this.updateCountdown(), 1000)
    }

    disconnect() {
        if (this.interval) {
            clearInterval(this.interval)
        }
    }

    updateCountdown() {
        const timezone = this.hasTimezoneValue ? this.timezoneValue : 'UTC'

        // Get current time in user's timezone
        const now = new Date()
        const options = { timeZone: timezone, hour: 'numeric', minute: 'numeric', second: 'numeric', hour12: false }

        let timeString
        try {
            timeString = now.toLocaleTimeString('en-US', options)
        } catch (e) {
            // Fallback to UTC if timezone is invalid
            timeString = now.toLocaleTimeString('en-US', { timeZone: 'UTC', hour: 'numeric', minute: 'numeric', second: 'numeric', hour12: false })
        }

        const [hours, minutes, seconds] = timeString.split(':').map(Number)

        // Calculate time remaining until midnight in user's timezone
        const secondsUntilMidnight = (24 * 60 * 60) - (hours * 3600 + minutes * 60 + seconds)

        if (secondsUntilMidnight <= 0) {
            this.displayTarget.textContent = "00:00:00"
            return
        }

        const remainingHours = Math.floor(secondsUntilMidnight / 3600)
        const remainingMinutes = Math.floor((secondsUntilMidnight % 3600) / 60)
        const remainingSeconds = secondsUntilMidnight % 60

        const formatted = [
            remainingHours.toString().padStart(2, '0'),
            remainingMinutes.toString().padStart(2, '0'),
            remainingSeconds.toString().padStart(2, '0')
        ].join(':')

        this.displayTarget.textContent = formatted
    }
}
