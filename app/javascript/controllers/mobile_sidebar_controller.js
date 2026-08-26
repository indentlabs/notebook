import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["sidebar"]

    toggle(event) {
        event.stopPropagation()
        this.sidebarTarget.classList.toggle("hidden")
    }

    close(event) {
        // Close if clicking outside sidebar and toggle button
        if (!this.sidebarTarget.contains(event.target) &&
            !this.sidebarTarget.classList.contains("hidden")) {
            this.sidebarTarget.classList.add("hidden")
        }
    }
}
