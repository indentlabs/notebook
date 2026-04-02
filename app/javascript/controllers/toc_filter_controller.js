import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["page", "allFilter"]

  filter(event) {
    const selectedType = event.currentTarget.dataset.pageType

    this.pageTargets.forEach(el => {
      el.style.display = el.dataset.pageType === selectedType ? "" : "none"
    })
  }

  showAll() {
    this.pageTargets.forEach(el => {
      el.style.display = ""
    })
  }
}
