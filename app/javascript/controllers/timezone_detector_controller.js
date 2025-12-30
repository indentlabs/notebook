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
    static targets = ["detected"]
    static values = { current: String }

    connect() {
        this.detectTimezone()
    }

    detectTimezone() {
        try {
            const detectedTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone
            const railsTimezone = this.ianaToRails(detectedTimezone)

            if (railsTimezone && railsTimezone !== this.currentValue) {
                // Show the friendly Rails timezone name to the user
                this.detectedTarget.textContent = railsTimezone
                // Store the IANA name as a data attribute for the apply function
                this.detectedTarget.dataset.ianaTimezone = detectedTimezone
                this.element.classList.remove('hidden')
            }
        } catch (e) {
            // Browser doesn't support Intl API, hide the detection notice
            console.warn('Timezone detection not supported:', e)
        }
    }

    // Convert IANA timezone to Rails timezone name
    ianaToRails(ianaTimezone) {
        // Direct mapping
        if (IANA_TO_RAILS_TIMEZONE[ianaTimezone]) {
            return IANA_TO_RAILS_TIMEZONE[ianaTimezone]
        }

        // Try to find a match by region (e.g., America/Detroit -> Eastern Time)
        // This handles less common city names in the same timezone
        const parts = ianaTimezone.split('/')
        if (parts.length >= 2) {
            const region = parts[0]

            // Common US timezone regions
            if (region === 'America') {
                // Try to determine by offset
                const now = new Date()
                const offset = -now.getTimezoneOffset() / 60

                if (offset === -5 || offset === -4) return 'Eastern Time (US & Canada)'
                if (offset === -6 || offset === -5) return 'Central Time (US & Canada)'
                if (offset === -7 || offset === -6) return 'Mountain Time (US & Canada)'
                if (offset === -8 || offset === -7) return 'Pacific Time (US & Canada)'
            }
        }

        // Fallback: return null if we can't map it
        return null
    }

    apply(event) {
        event.preventDefault()
        const railsTimezone = this.detectedTarget.textContent

        // Try multiple ways to find the timezone select element
        const selectElement = document.getElementById('user_time_zone') ||
                              document.querySelector('select[name="user[time_zone]"]')

        if (selectElement) {
            // Find the option that matches the Rails timezone name
            const options = Array.from(selectElement.options)
            const matchingOption = options.find(opt => opt.value === railsTimezone)

            if (matchingOption) {
                selectElement.value = railsTimezone
                // Hide the detection notice after applying
                this.element.classList.add('hidden')

                // Trigger change event for any listeners
                selectElement.dispatchEvent(new Event('change', { bubbles: true }))
            } else {
                // Timezone not in the list (rare edge case)
                console.warn('Detected timezone not found in options:', railsTimezone)
            }
        } else {
            console.warn('Could not find timezone select element')
        }
    }
}
