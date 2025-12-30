// Shared timezone utility - single source of truth for Rails <-> IANA conversions
// Rails ActiveSupport::TimeZone uses names like "Pacific Time (US & Canada)"
// JavaScript Intl API uses IANA identifiers like "America/Los_Angeles"

export const IANA_TO_RAILS = {
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

// Build reverse mapping (Rails -> IANA) programmatically
export const RAILS_TO_IANA = Object.fromEntries(
    Object.entries(IANA_TO_RAILS).map(([iana, rails]) => [rails, iana])
)

/**
 * Convert Rails timezone name to IANA identifier for use with JavaScript Intl API
 * @param {string} railsTimezone - Rails timezone name like "Pacific Time (US & Canada)"
 * @returns {string} IANA identifier like "America/Los_Angeles", or original value if not found
 */
export function railsToIana(railsTimezone) {
    return RAILS_TO_IANA[railsTimezone] || railsTimezone
}

/**
 * Convert IANA timezone identifier to Rails timezone name
 * @param {string} ianaTimezone - IANA identifier like "America/Los_Angeles"
 * @returns {string|null} Rails timezone name, or null if not mappable
 */
export function ianaToRails(ianaTimezone) {
    // Direct lookup
    if (IANA_TO_RAILS[ianaTimezone]) {
        return IANA_TO_RAILS[ianaTimezone]
    }

    // Fallback: Try to match by offset for common US timezones
    // This handles less common city names in the same timezone (e.g., America/Detroit)
    const parts = ianaTimezone.split('/')
    if (parts.length >= 2 && parts[0] === 'America') {
        const now = new Date()
        const offset = -now.getTimezoneOffset() / 60

        if (offset === -5 || offset === -4) return 'Eastern Time (US & Canada)'
        if (offset === -6 || offset === -5) return 'Central Time (US & Canada)'
        if (offset === -7 || offset === -6) return 'Mountain Time (US & Canada)'
        if (offset === -8 || offset === -7) return 'Pacific Time (US & Canada)'
    }

    return null
}

/**
 * Detect the browser's timezone
 * @returns {string} IANA timezone identifier
 */
export function detectBrowserTimezone() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone
}
