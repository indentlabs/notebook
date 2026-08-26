import { Controller } from "stimulus"
import { ianaToRails, detectBrowserTimezone } from "../utils/timezone"

export default class extends Controller {
    static targets = ["detected"]
    static values = { current: String }

    connect() {
        this.detectTimezone()
    }

    detectTimezone() {
        try {
            const detectedTimezone = detectBrowserTimezone()
            const railsTimezone = ianaToRails(detectedTimezone)

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
