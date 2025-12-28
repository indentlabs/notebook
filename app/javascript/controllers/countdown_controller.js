import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["display"]

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
        // Use UTC to match server-side Date.current (Rails defaults to UTC)
        const now = new Date()
        const utcHours = now.getUTCHours()
        const utcMinutes = now.getUTCMinutes()
        const utcSeconds = now.getUTCSeconds()

        // Calculate time remaining until UTC midnight
        const secondsUntilMidnight = (24 * 60 * 60) - (utcHours * 3600 + utcMinutes * 60 + utcSeconds)

        if (secondsUntilMidnight <= 0) {
            this.displayTarget.textContent = "00:00:00"
            return
        }

        const hours = Math.floor(secondsUntilMidnight / 3600)
        const minutes = Math.floor((secondsUntilMidnight % 3600) / 60)
        const seconds = secondsUntilMidnight % 60

        const formatted = [
            hours.toString().padStart(2, '0'),
            minutes.toString().padStart(2, '0'),
            seconds.toString().padStart(2, '0')
        ].join(':')

        this.displayTarget.textContent = formatted
    }
}
