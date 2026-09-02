import { Controller } from "stimulus"

// Lightbox for the public gallery on content#show.
//
// The grid renders one <button data-lightbox-target="item"> per image with
// the full-size URL, caption and links in data attributes, so this
// controller needs no server round-trips. Keyboard: ← → Home End Esc.
// Touch: swipe left/right. Focus stays inside the dialog while open and
// returns to the thumbnail that opened it.
export default class extends Controller {
  static targets = ["item", "modal", "stage", "image", "loading", "counter", "caption", "source", "download", "edit", "previous", "next"]
  static values = { pageName: String }

  connect() {
    // Fixed positioning must escape the page's transformed wrappers.
    if (this.hasModalTarget && this.modalTarget.parentElement !== document.body) {
      this.modalHome = this.modalTarget
      document.body.appendChild(this.modalTarget)
    }
    this.index = -1
    this.opened = false
  }

  disconnect() {
    if (this.opened) this.close()
    if (this.modalHome && this.modalHome.parentElement === document.body) this.modalHome.remove()
  }

  // The modal lives on <body>, so target lookups must not rely on scope.
  get modal() { return this.modalHome || this.modalTarget }
  part(name) { return this.modal.querySelector(`[data-lightbox-target='${name}']`) }

  open(event) {
    const item = event.currentTarget
    this.index = parseInt(item.dataset.index, 10) || 0
    this.opener = item
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
