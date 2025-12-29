import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["detected"]
    static values = { current: String }

    connect() {
        this.detectTimezone()
    }

    detectTimezone() {
        try {
            const detectedTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone

            if (detectedTimezone && detectedTimezone !== this.currentValue) {
                this.detectedTarget.textContent = detectedTimezone
                this.element.classList.remove('hidden')
            }
        } catch (e) {
            // Browser doesn't support Intl API, hide the detection notice
            console.warn('Timezone detection not supported:', e)
        }
    }

    apply(event) {
        event.preventDefault()
        const detectedTimezone = this.detectedTarget.textContent
        const selectElement = document.getElementById('user_time_zone')

        if (selectElement) {
            // Find the option that matches the detected timezone
            const options = Array.from(selectElement.options)
            const matchingOption = options.find(opt => opt.value === detectedTimezone)

            if (matchingOption) {
                selectElement.value = detectedTimezone
                // Hide the detection notice after applying
                this.element.classList.add('hidden')

                // Trigger change event for any listeners
                selectElement.dispatchEvent(new Event('change', { bubbles: true }))
            } else {
                // Timezone not in the list (rare edge case)
                console.warn('Detected timezone not found in options:', detectedTimezone)
            }
        }
    }
}
