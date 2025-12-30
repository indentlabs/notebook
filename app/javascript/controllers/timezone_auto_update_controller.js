import { Controller } from "stimulus"

// Map IANA timezone identifiers to Rails ActiveSupport::TimeZone names
const IANA_TO_RAILS_TIMEZONE = {
    'America/New_York': 'Eastern Time (US & Canada)',
    'America/Chicago': 'Central Time (US & Canada)',
    'America/Denver': 'Mountain Time (US & Canada)',
    'America/Los_Angeles': 'Pacific Time (US & Canada)',
    'America/Anchorage': 'Alaska',
    'Pacific/Honolulu': 'Hawaii',
    'America/Phoenix': 'Arizona',
    'America/Indiana/Indianapolis': 'Indiana (East)',
    'America/Puerto_Rico': 'Atlantic Time (Canada)',
    'Europe/London': 'London',
    'Europe/Paris': 'Paris',
    'Europe/Berlin': 'Berlin',
    'Europe/Amsterdam': 'Amsterdam',
    'Europe/Madrid': 'Madrid',
    'Europe/Rome': 'Rome',
    'Europe/Vienna': 'Vienna',
    'Europe/Brussels': 'Brussels',
    'Europe/Stockholm': 'Stockholm',
    'Europe/Helsinki': 'Helsinki',
    'Europe/Athens': 'Athens',
    'Europe/Moscow': 'Moscow',
    'Asia/Tokyo': 'Tokyo',
    'Asia/Seoul': 'Seoul',
    'Asia/Shanghai': 'Beijing',
    'Asia/Hong_Kong': 'Hong Kong',
    'Asia/Singapore': 'Singapore',
    'Asia/Kolkata': 'Kolkata',
    'Asia/Mumbai': 'Mumbai',
    'Asia/Bangkok': 'Bangkok',
    'Asia/Jakarta': 'Jakarta',
    'Asia/Dubai': 'Abu Dhabi',
    'Asia/Jerusalem': 'Jerusalem',
    'Australia/Sydney': 'Sydney',
    'Australia/Melbourne': 'Melbourne',
    'Australia/Brisbane': 'Brisbane',
    'Australia/Perth': 'Perth',
    'Australia/Adelaide': 'Adelaide',
    'Australia/Darwin': 'Darwin',
    'Australia/Hobart': 'Hobart',
    'Pacific/Auckland': 'Auckland',
    'Pacific/Fiji': 'Fiji',
    'America/Sao_Paulo': 'Brasilia',
    'America/Buenos_Aires': 'Buenos Aires',
    'America/Santiago': 'Santiago',
    'America/Lima': 'Lima',
    'America/Bogota': 'Bogota',
    'America/Mexico_City': 'Mexico City',
    'America/Toronto': 'Eastern Time (US & Canada)',
    'America/Vancouver': 'Pacific Time (US & Canada)',
    'Africa/Cairo': 'Cairo',
    'Africa/Johannesburg': 'Pretoria',
    'Africa/Lagos': 'West Central Africa',
    'UTC': 'UTC'
}

export default class extends Controller {
    static values = {
        currentTimezone: String,
        updatedAt: Number,  // Unix timestamp
        updateUrl: String
    }

    connect() {
        this.maybeAutoUpdate()
    }

    // Convert IANA timezone to Rails timezone name
    ianaToRails(ianaTimezone) {
        // Direct mapping
        if (IANA_TO_RAILS_TIMEZONE[ianaTimezone]) {
            return IANA_TO_RAILS_TIMEZONE[ianaTimezone]
        }

        // Try to find a match by offset for US timezones
        const parts = ianaTimezone.split('/')
        if (parts.length >= 2 && parts[0] === 'America') {
            const now = new Date()
            const offset = -now.getTimezoneOffset() / 60

            if (offset === -5 || offset === -4) return 'Eastern Time (US & Canada)'
            if (offset === -6 || offset === -5) return 'Central Time (US & Canada)'
            if (offset === -7 || offset === -6) return 'Mountain Time (US & Canada)'
            if (offset === -8 || offset === -7) return 'Pacific Time (US & Canada)'
        }

        // Fallback: return null if we can't map it
        return null
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

        // Detect browser timezone and convert to Rails format
        const ianaTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone
        const railsTimezone = this.ianaToRails(ianaTimezone)

        if (!railsTimezone || railsTimezone === 'UTC') return

        // Mark as attempted
        sessionStorage.setItem('timezone_auto_updated', 'true')

        // Send update request with Rails timezone name
        this.updateTimezone(railsTimezone)
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
