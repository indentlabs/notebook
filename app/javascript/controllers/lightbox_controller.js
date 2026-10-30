import { Controller } from "stimulus"

// Lightbox for the gallery on content#show, and for viewing images larger on
// the content#edit gallery tab.
//
// The grid renders one data-lightbox-target="item" element per image with
// the full-size URL, caption and links in data attributes, so this
// controller needs no server round-trips. Keyboard: ← → Home End Esc.
// Touch: swipe left/right. Focus stays inside the dialog while open and
// returns to the thumbnail that opened it.
export default class extends Controller {
  static targets = ["item", "modal", "stage", "image", "loading", "counter", "caption", "source", "download", "edit", "previous", "next"]
  static values = { pageName: String }

  connect() {
    // Fixed positioning must escape the page's transformed wrappers. Moving
    // the dialog out of this controller's scope also drops any data-action
    // bindings on it, so its events are wired by hand below.
    if (this.hasModalTarget && this.modalTarget.parentElement !== document.body) {
      this.modalHome = this.modalTarget
      document.body.appendChild(this.modalTarget)
    }
    this.index = -1
    this.opened = false

    this.onModalClick = this.onModalClick.bind(this)
    this.onKeydown = this.keydown.bind(this)
    this.onPointerDown = this.pointerDown.bind(this)
    this.onPointerUp = this.pointerUp.bind(this)
    this.modal.addEventListener("click", this.onModalClick)
    document.addEventListener("keydown", this.onKeydown)
    const stage = this.part("stage")
    stage.addEventListener("pointerdown", this.onPointerDown)
    stage.addEventListener("pointerup", this.onPointerUp)
    stage.addEventListener("pointercancel", this.onPointerUp)
  }

  disconnect() {
    if (this.opened) this.close()
    document.removeEventListener("keydown", this.onKeydown)
    if (this.modal) {
      this.modal.removeEventListener("click", this.onModalClick)
      const stage = this.part("stage")
      if (stage) {
        stage.removeEventListener("pointerdown", this.onPointerDown)
        stage.removeEventListener("pointerup", this.onPointerUp)
        stage.removeEventListener("pointercancel", this.onPointerUp)
      }
    }
    if (this.modalHome && this.modalHome.parentElement === document.body) this.modalHome.remove()
  }

  onModalClick(event) {
    const control = event.target.closest("[data-lightbox-action]")
    if (control) {
      event.preventDefault()
      const action = control.dataset.lightboxAction
      if (action === "close") this.close()
      if (action === "previous") this.previous(event)
      if (action === "next") this.next(event)
      if (action === "edit") this.edit(control)
      return
    }
    this.backdrop(event)
  }

  // The modal lives on <body>, so target lookups must not rely on scope.
  get modal() { return this.modalHome || this.modalTarget }
  part(name) { return this.modal.querySelector(`[data-lightbox-target='${name}']`) }

  open(event) {
    // On the edit page the trigger sits inside a card that has its own
    // buttons and links; let those do their own thing.
    const control = event.target.closest("a, button, input, textarea, select, label")
    if (control && control !== event.currentTarget) return

    const item = event.currentTarget.closest("[data-lightbox-target='item']")
    if (!item) return
    event.preventDefault()
    // Items can be reordered in place, so use DOM order rather than a stored index.
    this.index = Math.max(this.itemTargets.indexOf(item), 0)
    // Return focus somewhere focusable: the card's "View" button on the edit page.
    this.opener = item.querySelector("[data-lightbox-opener]") || item
    this.opened = true
    this.modal.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    this.render()
    this.part("next").focus()
  }

  close(event) {
    if (event) event.preventDefault()
    if (!this.opened) return
    this.opened = false
    this.modal.classList.add("hidden")
    document.body.style.overflow = ""
    this.part("image").removeAttribute("src")
    if (this.opener && this.opener.focus) this.opener.focus()
  }

  // "Edit framing": on the edit page, hand the image to the in-page editor
  // (image_editor_controller cancels the event). Elsewhere, follow the link.
  edit(link) {
    const item = this.itemTargets[this.index]
    const card = item && item.closest(".gallery-card")
    if (card) {
      const event = new CustomEvent("gallery:edit", { detail: { card, dataset: { ...card.dataset } }, cancelable: true })
      this.close()
      if (!window.dispatchEvent(event)) return
    }
    if (link.href && !link.getAttribute("href").startsWith("#")) window.location.href = link.href
  }

  backdrop(event) {
    // Clicks on the stage itself (not the image or arrows) close.
    if (event.target === this.part("stage")) this.close()
  }

  previous(event) {
    if (event) event.stopPropagation()
    this.go(this.index - 1)
  }

  next(event) {
    if (event) event.stopPropagation()
    this.go(this.index + 1)
  }

  go(index) {
    const count = this.itemTargets.length
    if (count === 0) return
    this.index = (index + count) % count
    this.render()
  }

  render() {
    const item = this.itemTargets[this.index]
    if (!item) return
    const count = this.itemTargets.length
    const image = this.part("image")
    const loading = this.part("loading")

    loading.classList.remove("hidden")
    loading.classList.add("flex")
    image.classList.add("opacity-0")
    const onLoad = () => {
      image.removeEventListener("load", onLoad)
      loading.classList.add("hidden")
      loading.classList.remove("flex")
      image.classList.remove("opacity-0")
    }
    image.addEventListener("load", onLoad)
    image.src = item.dataset.full
    image.alt = item.dataset.caption || `${this.pageNameValue} image ${this.index + 1}`

    this.part("counter").textContent = `${this.index + 1} of ${count}`
    this.part("caption").textContent = item.dataset.caption || ""
    this.part("source").textContent = item.dataset.source || ""

    const download = this.part("download")
    download.href = item.dataset.download || item.dataset.full

    const edit = this.part("edit")
    if (item.dataset.editUrl) {
      edit.href = item.dataset.editUrl
      edit.classList.remove("hidden")
    } else {
      edit.classList.add("hidden")
    }

    const single = count < 2
    this.part("previous").classList.toggle("hidden", single)
    this.part("next").classList.toggle("hidden", single)

    this.preload(this.index + 1)
    this.preload(this.index - 1)
  }

  preload(index) {
    const count = this.itemTargets.length
    if (count < 2) return
    const item = this.itemTargets[(index + count) % count]
    if (item && item.dataset.full) {
      const img = new Image()
      img.src = item.dataset.full
    }
  }

  keydown(event) {
    if (!this.opened) return
    switch (event.key) {
      case "Escape": event.preventDefault(); this.close(); break
      case "ArrowLeft": event.preventDefault(); this.previous(); break
      case "ArrowRight": event.preventDefault(); this.next(); break
      case "Home": event.preventDefault(); this.go(0); break
      case "End": event.preventDefault(); this.go(this.itemTargets.length - 1); break
      case "Tab": this.trapFocus(event); break
      default: break
    }
  }

  trapFocus(event) {
    const focusable = Array.from(this.modal.querySelectorAll("a[href], button:not([disabled])"))
      .filter((el) => el.offsetParent !== null)
    if (focusable.length === 0) return
    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  pointerDown(event) {
    if (event.pointerType !== "touch") return
    this.swipeStartX = event.clientX
    this.swipeStartY = event.clientY
  }

  pointerUp(event) {
    if (event.pointerType !== "touch" || this.swipeStartX === undefined) return
    const dx = event.clientX - this.swipeStartX
    const dy = event.clientY - this.swipeStartY
    this.swipeStartX = undefined
    if (Math.abs(dx) < 50 || Math.abs(dy) > Math.abs(dx)) return
    if (dx < 0) this.next()
    else this.previous()
  }
}
