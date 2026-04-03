import { Controller } from "stimulus"

export default class extends Controller {
    static values = {
        text: String
    }

    copy(event) {
        event.preventDefault()
        const text = this.textValue || this.element.dataset.clipboardText

        if (!text) {
            this.showNotification('No link to copy', 'error')
            return
        }

        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(text).then(() => {
                this.showNotification('Link copied to clipboard!', 'success')
            }).catch((err) => {
                console.error('Failed to copy: ', err)
                this.fallbackCopy(text)
            })
        } else {
            this.fallbackCopy(text)
        }
    }

    fallbackCopy(text) {
        const textArea = document.createElement("textarea")
        textArea.value = text
        textArea.style.position = "fixed"
        textArea.style.left = "-9999px"
        document.body.appendChild(textArea)
        textArea.focus()
        textArea.select()

        try {
            const successful = document.execCommand('copy')
            if (successful) {
                this.showNotification('Link copied to clipboard!', 'success')
            } else {
                this.showNotification('Unable to copy link', 'error')
            }
        } catch (err) {
            console.error('Fallback copy failed:', err)
            this.showNotification('Copy failed', 'error')
        }

        document.body.removeChild(textArea)
    }

    showNotification(message, type) {
        if (typeof window.showNotification === 'function') {
            window.showNotification(message, type)
        } else {
            // Fallback if global notification isn't available
            alert(message)
        }
    }
}
