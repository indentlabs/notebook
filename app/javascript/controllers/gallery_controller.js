import { Controller } from "stimulus"

// Gallery management on content#edit.
//
// One controller wraps the whole gallery tab: the sortable grid of cards,
// the drop-zone uploader, and the per-card actions (cover, privacy, notes,
// move, delete). Everything talks JSON to the server; nothing reloads the page.
//
// Cards are rendered server-side by content/edit/gallery/_card.html.erb and
// carry their endpoints as data attributes, so this controller never needs to
// know whether an image is an upload or a Basil commission.
export default class extends Controller {
  static targets = [
    "grid", "card", "count", "empty", "hint", "coverSummary",
    "dropzone", "fileInput", "queue", "bandwidth", "bandwidthBar",
    "media", "thumb", "coverChip", "coverButton", "coverLabel",
    "privacyButton", "privacyIcon", "privacyLabel",
    "notes", "notesStatus", "actions", "deleteConfirm", "dimensions"
  ]

  static values = {
    contentType: String,
    contentId: Number,
    sortUrl: String,
    uploadUrl: String,
    remainingKb: Number,
    maxUploadKb: Number
  }

  connect() {
    this.dragDepth = 0
    this.uploading = 0
    this.initSortable()
    this.notesTargets.forEach((textarea) => this.resizeTextarea(textarea))
    this.refreshCount()
    this.refreshBandwidth()
    this.onWindowPaste = this.onWindowPaste.bind(this)
    window.addEventListener("paste", this.onWindowPaste)
    this.onDocumentClick = this.onDocumentClick.bind(this)
    document.addEventListener("click", this.onDocumentClick)
  }

  disconnect() {
    window.removeEventListener("paste", this.onWindowPaste)
    document.removeEventListener("click", this.onDocumentClick)
    if (this.sortable) {
      try { this.sortable.sortable("destroy") } catch (e) { /* already gone */ }
      this.sortable = null
    }
  }

  // ---------------------------------------------------------------------
  // Reordering
  // ---------------------------------------------------------------------

  initSortable() {
    if (!this.hasGridTarget) return
    if (typeof window.$ === "undefined" || !window.$.fn || !window.$.fn.sortable) return

    const $grid = window.$(this.gridTarget)
    if ($grid.hasClass("ui-sortable")) return

    $grid.sortable({
      items: ".gallery-card",
      handle: ".gallery-card__media",
      cancel: "input,textarea,button,select,option,a",
      placeholder: "gallery-card gallery-card__placeholder",
      tolerance: "pointer",
      distance: 8,
      opacity: 0.9,
      start: () => this.element.classList.add("gallery--reordering"),
      stop: () => {
        this.element.classList.remove("gallery--reordering")
        this.persistOrder()
      }
    })
    this.sortable = $grid
  }

  moveUp(event) {
    const card = this.cardFor(event)
    const previous = card.previousElementSibling
    if (!previous) return
    card.parentNode.insertBefore(card, previous)
    card.querySelector("[data-action*='moveUp']").focus()
    this.persistOrder()
  }

  moveDown(event) {
    const card = this.cardFor(event)
    const next = card.nextElementSibling
    if (!next) return
    card.parentNode.insertBefore(next, card)
    card.querySelector("[data-action*='moveDown']").focus()
    this.persistOrder()
  }

  persistOrder() {
    const images = this.cardTargets.map((card, index) => ({
      id: parseInt(card.dataset.imageId, 10),
      type: card.dataset.imageType,
      position: index + 1
    }))

    this.request(this.sortUrlValue, "POST", {
      images,
      content_type: this.contentTypeValue,
      content_id: this.contentIdValue
    })
      .then(() => this.toast("Image order saved", "success"))
      .catch((error) => this.toast(error.message || "Couldn't save the new order", "error"))
  }

  // ---------------------------------------------------------------------
  // Cover
  // ---------------------------------------------------------------------

  toggleCover(event) {
    const card = this.cardFor(event)
    if (card.dataset.busy === "cover") return
    card.dataset.busy = "cover"

    const wasCover = card.dataset.pinned === "true"
    const willBeCover = !wasCover

    // Optimistic update; reconciled from the response below.
    this.applyCoverState(card, willBeCover)
    if (willBeCover) this.cardTargets.forEach((other) => { if (other !== card) this.applyCoverState(other, false) })

    this.request(card.dataset.pinUrl, "POST")
      .then((data) => {
        this.applyCoverState(card, data.pinned === true)
        if (data.pinned) this.cardTargets.forEach((other) => { if (other !== card) this.applyCoverState(other, false) })
        this.toast(data.pinned ? "This image is now the cover" : "Cover removed. A random image will be used until you pick one.", "success")
      })
      .catch((error) => {
        this.applyCoverState(card, wasCover)
        this.toast(error.message || "Couldn't update the cover", "error")
      })
      .finally(() => { delete card.dataset.busy })
  }

  applyCoverState(card, isCover) {
    card.dataset.pinned = isCover ? "true" : "false"

    const media = card.querySelector("[data-gallery-target='media']")
    media.classList.toggle("ring-2", isCover)
    media.classList.toggle("ring-inset", isCover)
    media.classList.toggle("ring-yellow-400", isCover)

    card.querySelector("[data-gallery-target='coverChip']").classList.toggle("hidden", !isCover)

    const button = card.querySelector("[data-gallery-target='coverButton']")
    button.setAttribute("aria-pressed", isCover ? "true" : "false")
    button.title = isCover
      ? "This image is the cover. Click to stop using it as the cover."
      : "Use this image on cards, the page banner and link previews."
    const active = ["bg-yellow-400", "border-yellow-400", "text-yellow-900"]
    const inactive = ["border-gray-300", "dark:border-gray-600", "text-gray-700", "dark:text-gray-200", "hover:bg-yellow-50", "dark:hover:bg-gray-700"]
    active.forEach((c) => button.classList.toggle(c, isCover))
    inactive.forEach((c) => button.classList.toggle(c, !isCover))
    button.querySelector(".material-icons").textContent = isCover ? "star" : "star_border"
    card.querySelector("[data-gallery-target='coverLabel']").textContent = isCover ? "Cover" : "Set as cover"

    this.refreshCoverSummary()
    this.announceCoverChange()
  }

  // Close any open "use only for" menus when clicking elsewhere.
  onDocumentClick(event) {
    document.querySelectorAll("details.gallery-cover-menu[open]").forEach((details) => {
      if (!details.contains(event.target)) details.open = false
    })
  }

  // Cover for one shape only (banner / card / square ...).
  toggleCoverFor(event) {
    const item = event.currentTarget || event.target
    const card = this.cardFor(event)
    const preset = item.dataset.preset
    const label = item.dataset.label || preset
    const details = item.closest("details")
    if (details) details.open = false
    if (!card || !preset || card.dataset.busy) return
    card.dataset.busy = "role"

    const wasActive = this.rolesOf(card).includes(preset)
    const url = card.dataset.pinUrl + (card.dataset.pinUrl.includes("?") ? "&" : "?") + "preset=" + encodeURIComponent(preset)

    this.request(url, "POST")
      .then((data) => {
        this.applyCoverRoles(card, data.cover_for || [])
        if (data.active) {
          this.cardTargets.forEach((other) => {
            if (other !== card) this.applyCoverRoles(other, this.rolesOf(other).filter((role) => role !== preset))
          })
        }
        this.toast(data.active ? `This image is now the ${label.toLowerCase()} cover` : `${label} cover removed`, "success")
      })
      .catch((error) => {
        this.applyCoverRoles(card, wasActive ? this.rolesOf(card) : this.rolesOf(card).filter((role) => role !== preset))
        this.toast(error.message || "Couldn't update the cover", "error")
      })
      .finally(() => { delete card.dataset.busy })
  }

  rolesOf(card) {
    try { return JSON.parse(card.dataset.coverFor || "[]") } catch (e) { return [] }
  }

  applyCoverRoles(card, roles) {
    card.dataset.coverFor = JSON.stringify(roles)
    card.querySelectorAll("[data-gallery-target='roleChip']").forEach((chip) => {
      chip.classList.toggle("hidden", !roles.includes(chip.dataset.preset))
    })
    card.querySelectorAll("[data-action*='toggleCoverFor']").forEach((item) => {
      const active = roles.includes(item.dataset.preset)
      item.setAttribute("aria-checked", active ? "true" : "false")
      const check = item.querySelector("[data-role-check]")
      if (check) check.classList.toggle("invisible", !active)
    })
    this.announceCoverChange()
  }

  announceCoverChange() {
    window.dispatchEvent(new CustomEvent("gallery:covers-changed"))
  }

  refreshCoverSummary() {
    if (!this.hasCoverSummaryTarget) return
    const cover = this.cardTargets.find((card) => card.dataset.pinned === "true")
    this.coverSummaryTarget.textContent = cover
      ? "Your cover image is used on cards, the page banner and link previews."
      : "No cover chosen yet. A random image is used on cards and banners until you set one."
  }

  // ---------------------------------------------------------------------
  // Privacy
  // ---------------------------------------------------------------------

  togglePrivacy(event) {
    const card = this.cardFor(event)
    if (card.dataset.busy === "privacy") return
    card.dataset.busy = "privacy"

    const current = card.dataset.privacy || "public"
    const next = current === "public" ? "private" : "public"
    this.applyPrivacyState(card, next)

    this.request(card.dataset.updateUrl, "PATCH", { [card.dataset.paramKey]: { privacy: next } })
      .then((data) => {
        const saved = (data.image && data.image.privacy) || next
        this.applyPrivacyState(card, saved)
        this.toast(saved === "public" ? "Image is now public" : "Image is now private", "success")
      })
      .catch((error) => {
        this.applyPrivacyState(card, current)
        this.toast(error.message || "Couldn't update privacy", "error")
      })
      .finally(() => { delete card.dataset.busy })
  }

  applyPrivacyState(card, privacy) {
    card.dataset.privacy = privacy
    const button = card.querySelector("[data-gallery-target='privacyButton']")
    if (!button) return
    const isPublic = privacy === "public"
    const publicClasses = ["border-green-300", "text-green-700", "dark:border-green-700", "dark:text-green-300"]
    const privateClasses = ["border-gray-300", "text-gray-600", "dark:border-gray-600", "dark:text-gray-300"]
    publicClasses.forEach((c) => button.classList.toggle(c, isPublic))
    privateClasses.forEach((c) => button.classList.toggle(c, !isPublic))
    button.title = isPublic
      ? "Visible to anyone who can see this page. Click to make it private."
      : "Only you and collaborators can see this image. Click to make it public."
    card.querySelector("[data-gallery-target='privacyIcon']").textContent = isPublic ? "public" : "lock"
    card.querySelector("[data-gallery-target='privacyLabel']").textContent = isPublic ? "Public" : "Private"
  }

  // ---------------------------------------------------------------------
  // Notes
  // ---------------------------------------------------------------------

  autosize(event) {
    this.resizeTextarea(event.target)
  }

  resizeTextarea(textarea) {
    textarea.style.height = "auto"
    textarea.style.height = Math.max(textarea.scrollHeight, 56) + "px"
  }

  notesKeydown(event) {
    if (event.key === "Enter" && (event.metaKey || event.ctrlKey)) {
      event.preventDefault()
      event.target.blur()
    }
  }

  saveNotes(event) {
    const textarea = event.target
    const card = this.cardFor(event)
    const value = textarea.value
    if (value === (textarea.dataset.originalValue || "")) return

    const status = card.querySelector("[data-gallery-target='notesStatus']")
    this.setStatus(status, "Saving…", "text-gray-400")

    this.request(card.dataset.updateUrl, "PATCH", { [card.dataset.paramKey]: { notes: value } })
      .then(() => {
        textarea.dataset.originalValue = value
        const thumb = card.querySelector("[data-gallery-target='thumb']")
        if (thumb && value.trim()) thumb.alt = value.trim()
        this.setStatus(status, "Saved", "text-green-600 dark:text-green-400", true)
      })
      .catch((error) => {
        this.setStatus(status, "Not saved", "text-red-600 dark:text-red-400", true)
        this.toast(error.message || "Couldn't save notes", "error")
      })
  }

  setStatus(element, text, colorClasses, fade = false) {
    if (!element) return
    element.className = "absolute right-2 bottom-2 text-xs transition-opacity pointer-events-none " + colorClasses
    element.textContent = text
    element.style.opacity = "1"
    clearTimeout(element._fadeTimer)
    if (fade) element._fadeTimer = setTimeout(() => { element.style.opacity = "0" }, 1800)
  }

  // ---------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------

  confirmDelete(event) {
    this.showDeleteConfirm(this.cardFor(event))
  }

  showDeleteConfirm(card) {
    this.cardTargets.forEach((other) => { if (other !== card) this.hideDeleteConfirm(other) })
    card.querySelector("[data-gallery-target='actions']").classList.add("hidden")
    const confirm = card.querySelector("[data-gallery-target='deleteConfirm']")
    confirm.classList.remove("hidden")
    confirm.classList.add("flex")
    confirm.querySelector("[data-action*='gallery#delete']").focus()
  }

  cancelDelete(event) {
    this.hideDeleteConfirm(this.cardFor(event))
  }

  hideDeleteConfirm(card) {
    const confirm = card.querySelector("[data-gallery-target='deleteConfirm']")
    if (!confirm) return
    confirm.classList.add("hidden")
    confirm.classList.remove("flex")
    card.querySelector("[data-gallery-target='actions']").classList.remove("hidden")
  }

  delete(event) {
    const card = this.cardFor(event)
    if (card.dataset.busy === "delete") return
    card.dataset.busy = "delete"
    card.classList.add("opacity-50", "pointer-events-none")

    this.request(card.dataset.deleteUrl, "DELETE")
      .then((data) => {
        card.style.transition = "opacity 200ms, transform 200ms"
        card.style.opacity = "0"
        card.style.transform = "scale(0.97)"
        setTimeout(() => {
          card.remove()
          this.refreshCount()
          this.refreshCoverSummary()
        }, 200)
        if (data && typeof data.remaining_kb === "number") this.setRemainingKb(data.remaining_kb)
        this.toast("Image deleted", "success")
      })
      .catch((error) => {
        delete card.dataset.busy
        card.classList.remove("opacity-50", "pointer-events-none")
        this.hideDeleteConfirm(card)
        this.toast(error.message || "Couldn't delete the image", "error")
      })
  }

  // ---------------------------------------------------------------------
  // Editor hand-off
  // ---------------------------------------------------------------------

  edit(event) {
    const card = this.cardFor(event)
    const detail = { card, dataset: { ...card.dataset } }
    const opened = window.dispatchEvent(new CustomEvent("gallery:edit", { detail, cancelable: true }))
    // No editor on the page (cancelled events mean an editor took over).
    if (opened && card.dataset.originalUrl) window.open(card.dataset.originalUrl, "_blank", "noopener")
  }

  // Called by the editor after it saves, so the card reflects new state.
  refreshCard(card, image) {
    if (!card || !image) return
    if (typeof image.pinned === "boolean") this.applyCoverState(card, image.pinned)
    if (Array.isArray(image.cover_for)) this.applyCoverRoles(card, image.cover_for)
    if (image.privacy) this.applyPrivacyState(card, image.privacy)
    const notes = card.querySelector("[data-gallery-target='notes']")
    if (notes && typeof image.notes === "string" && notes.value !== image.notes) {
      notes.value = image.notes
      notes.dataset.originalValue = image.notes
      this.resizeTextarea(notes)
    }
    if (image.urls && image.urls.large) {
      const thumb = card.querySelector("[data-gallery-target='thumb']")
      if (thumb) {
        const separator = image.urls.large.includes("?") ? "&" : "?"
        thumb.src = image.urls.large + separator + "v=" + Date.now()
      }
      card.dataset.largeUrl = image.urls.large
    }
    if (image.crops) card.dataset.crops = JSON.stringify(image.crops)
    if (typeof image.focal_x === "number") card.dataset.focalX = image.focal_x
    if (typeof image.focal_y === "number") card.dataset.focalY = image.focal_y
    const thumb = card.querySelector("[data-gallery-target='thumb']")
    if (thumb && typeof image.focal_x === "number" && typeof image.focal_y === "number") {
      thumb.style.objectPosition = `${(image.focal_x * 100).toFixed(1)}% ${(image.focal_y * 100).toFixed(1)}%`
    }
  }

  // ---------------------------------------------------------------------
  // Uploads
  // ---------------------------------------------------------------------

  pickFiles(event) {
    event.preventDefault()
    if (this.hasFileInputTarget) this.fileInputTarget.click()
  }

  filesChosen(event) {
    this.enqueueFiles(event.target.files)
    event.target.value = ""
  }

  dragEnter(event) {
    if (!this.dragHasFiles(event)) return
    event.preventDefault()
    this.dragDepth += 1
    this.element.classList.add("gallery-dropzone--active")
  }

  dragOver(event) {
    if (!this.dragHasFiles(event)) return
    event.preventDefault()
    event.dataTransfer.dropEffect = "copy"
  }

  dragLeave(event) {
    if (!this.dragHasFiles(event)) return
    this.dragDepth = Math.max(0, this.dragDepth - 1)
    if (this.dragDepth === 0) this.element.classList.remove("gallery-dropzone--active")
  }

  drop(event) {
    if (!this.dragHasFiles(event)) return
    event.preventDefault()
    this.dragDepth = 0
    this.element.classList.remove("gallery-dropzone--active")
    this.enqueueFiles(event.dataTransfer.files)
  }

  onWindowPaste(event) {
    if (!this.hasUploadUrlValue) return
    if (!this.element.offsetParent) return // tab hidden
    const items = Array.from((event.clipboardData && event.clipboardData.items) || [])
    const files = items.filter((item) => item.kind === "file" && item.type.startsWith("image/")).map((item) => item.getAsFile())
    if (files.length === 0) return
    event.preventDefault()
    this.enqueueFiles(files)
  }

  dragHasFiles(event) {
    const types = event.dataTransfer && event.dataTransfer.types
    return this.hasUploadUrlValue && types && Array.from(types).includes("Files")
  }

  // Files are sent one at a time so progress is meaningful, the bandwidth
  // check sees each previous result, and the server never has to juggle
  // several uploads for the same page at once.
  enqueueFiles(fileList) {
    const files = Array.from(fileList || [])
    if (files.length === 0) return
    this.pending = this.pending || []
    files.forEach((file) => {
      const row = this.buildQueueRow(file)
      this.queueTarget.appendChild(row)
      this.queueTarget.classList.remove("hidden")
      this.pending.push({ file, row })
    })
    this.drainQueue()
  }

  drainQueue() {
    if (this.uploading > 0) return
    const next = this.pending && this.pending.shift()
    if (!next) return
    this.uploadFile(next.file, next.row)
  }

  uploadFile(file, row) {
    if (!file.type.startsWith("image/")) {
      this.failRow(row, `${file.name} isn't an image file.`, false)
      this.drainQueue()
      return
    }

    const sizeKb = file.size / 1000
    if (this.hasRemainingKbValue && sizeKb > this.remainingKbValue) {
      this.failRow(row, `${file.name} is ${this.humanSize(file.size)}, but you only have ${this.humanSize(this.remainingKbValue * 1000)} of upload bandwidth left.`, false)
      this.drainQueue()
      return
    }

    this.sendFile(file, row)
  }

  sendFile(file, row) {
    const form = new FormData()
    form.append("content_type", this.contentTypeValue)
    form.append("content_id", this.contentIdValue)
    form.append("src", file, file.name)
    form.append("privacy", "public")

    const xhr = new XMLHttpRequest()
    const bar = row.querySelector(".gallery-upload__bar")
    const status = row.querySelector(".gallery-upload__status")
    this.uploading += 1
    row.dataset.state = "uploading"
    status.textContent = "Uploading…"

    xhr.upload.addEventListener("progress", (e) => {
      if (!e.lengthComputable) return
      const pct = Math.round((e.loaded / e.total) * 100)
      bar.style.width = pct + "%"
      status.textContent = pct < 100 ? `Uploading… ${pct}%` : "Processing…"
    })

    xhr.addEventListener("load", () => {
      this.uploading -= 1
      setTimeout(() => this.drainQueue(), 0)
      let data = {}
      try { data = JSON.parse(xhr.responseText || "{}") } catch (e) { /* not JSON */ }

      if (xhr.status >= 200 && xhr.status < 300 && data.html) {
        bar.style.width = "100%"
        this.insertCard(data.html)
        if (typeof data.remaining_kb === "number") this.setRemainingKb(data.remaining_kb)
        status.textContent = "Added to gallery"
        row.dataset.state = "done"
        setTimeout(() => {
          row.remove()
          if (this.queueTarget.children.length === 0) this.queueTarget.classList.add("hidden")
        }, 1200)
        this.toast(`${file.name} uploaded`, "success")
      } else {
        if (typeof data.remaining_kb === "number") this.setRemainingKb(data.remaining_kb)
        this.failRow(row, data.error || `Couldn't upload ${file.name} (HTTP ${xhr.status}).`, true, file)
      }
    })

    xhr.addEventListener("error", () => {
      this.uploading -= 1
      setTimeout(() => this.drainQueue(), 0)
      this.failRow(row, `Couldn't upload ${file.name}. Check your connection and try again.`, true, file)
    })

    xhr.open("POST", this.uploadUrlValue)
    xhr.setRequestHeader("X-CSRF-Token", this.csrfToken())
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
    xhr.setRequestHeader("Accept", "application/json")
    xhr.send(form)
  }

  buildQueueRow(file) {
    const row = document.createElement("div")
    row.className = "gallery-upload flex items-center gap-3 p-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg"
    row.dataset.state = "queued"

    const thumb = document.createElement("div")
    thumb.className = "w-14 h-14 flex-shrink-0 rounded-md bg-gray-100 dark:bg-gray-700 overflow-hidden flex items-center justify-center"
    if (file.type.startsWith("image/")) {
      const img = document.createElement("img")
      img.className = "w-full h-full object-cover"
      img.alt = ""
      img.src = URL.createObjectURL(file)
      img.addEventListener("load", () => URL.revokeObjectURL(img.src))
      thumb.appendChild(img)
    } else {
      thumb.innerHTML = '<i class="material-icons text-gray-400">insert_drive_file</i>'
    }

    const body = document.createElement("div")
    body.className = "flex-1 min-w-0"
    body.innerHTML = `
      <div class="flex items-center justify-between gap-2 text-sm">
        <span class="truncate font-medium text-gray-900 dark:text-white"></span>
        <span class="text-xs text-gray-500 whitespace-nowrap"></span>
      </div>
      <div class="mt-1 h-1.5 w-full rounded-full bg-gray-200 dark:bg-gray-700 overflow-hidden">
        <div class="gallery-upload__bar h-full bg-blue-600 transition-all" style="width: 0%"></div>
      </div>
      <div class="mt-1 flex items-center justify-between gap-2">
        <span class="gallery-upload__status text-xs text-gray-500 dark:text-gray-400">Queued</span>
        <span class="gallery-upload__actions flex items-center gap-2"></span>
      </div>`
    body.querySelector("span.truncate").textContent = file.name
    body.querySelector("span.text-xs.text-gray-500.whitespace-nowrap").textContent = this.humanSize(file.size)

    row.appendChild(thumb)
    row.appendChild(body)
    return row
  }

  failRow(row, message, retryable, file) {
    row.dataset.state = "failed"
    row.classList.add("border-red-300", "dark:border-red-700")
    const status = row.querySelector(".gallery-upload__status")
    status.textContent = message
    status.className = "gallery-upload__status text-xs text-red-600 dark:text-red-300"
    row.querySelector(".gallery-upload__bar").classList.replace("bg-blue-600", "bg-red-500")

    const actions = row.querySelector(".gallery-upload__actions")
    actions.innerHTML = ""
    if (retryable && file) {
      const retry = document.createElement("button")
      retry.type = "button"
      retry.className = "text-xs font-medium text-blue-600 hover:underline"
      retry.textContent = "Retry"
      retry.addEventListener("click", () => {
        row.classList.remove("border-red-300", "dark:border-red-700")
        status.className = "gallery-upload__status text-xs text-gray-500 dark:text-gray-400"
        row.querySelector(".gallery-upload__bar").classList.replace("bg-red-500", "bg-blue-600")
        row.querySelector(".gallery-upload__bar").style.width = "0%"
        actions.innerHTML = ""
        this.sendFile(file, row)
      })
      actions.appendChild(retry)
    }
    const dismiss = document.createElement("button")
    dismiss.type = "button"
    dismiss.className = "text-xs text-gray-500 hover:underline"
    dismiss.textContent = "Dismiss"
    dismiss.addEventListener("click", () => {
      row.remove()
      if (this.queueTarget.children.length === 0) this.queueTarget.classList.add("hidden")
    })
    actions.appendChild(dismiss)
  }

  insertCard(html) {
    const template = document.createElement("template")
    template.innerHTML = html.trim()
    const card = template.content.firstElementChild
    this.gridTarget.appendChild(card)
    const notes = card.querySelector("[data-gallery-target='notes']")
    if (notes) this.resizeTextarea(notes)
    this.refreshCount()
    this.refreshCoverSummary()
    if (this.sortable) this.sortable.sortable("refresh")
    card.scrollIntoView({ behavior: "smooth", block: "nearest" })
  }

  // ---------------------------------------------------------------------
  // Counters
  // ---------------------------------------------------------------------

  refreshCount() {
    const count = this.cardTargets.length
    if (this.hasCountTarget) this.countTarget.textContent = count
    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", count > 0)
    if (this.hasGridTarget) this.gridTarget.parentElement.classList.toggle("hidden", count === 0)
    if (this.hasHintTarget) this.hintTarget.classList.toggle("hidden", count < 2)

    const badge = document.getElementById("gallery-nav-count")
    if (badge) {
      badge.textContent = count
      badge.classList.toggle("hidden", count === 0)
    }
  }

  setRemainingKb(kb) {
    this.remainingKbValue = kb
    this.refreshBandwidth()
  }

  refreshBandwidth() {
    if (!this.hasBandwidthTarget || !this.hasRemainingKbValue) return
    const remaining = Math.max(0, this.remainingKbValue)
    this.bandwidthTarget.textContent = this.humanSize(remaining * 1000)
    if (this.hasBandwidthBarTarget && this.hasMaxUploadKbValue && this.maxUploadKbValue > 0) {
      const pct = Math.max(0, Math.min(100, (remaining / this.maxUploadKbValue) * 100))
      this.bandwidthBarTarget.style.width = pct + "%"
    }
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  cardFor(event) {
    return event.target.closest("[data-gallery-target='card']")
  }

  csrfToken() {
    const meta = document.querySelector("meta[name='csrf-token']")
    return meta ? meta.content : ""
  }

  request(url, method, body) {
    const headers = {
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRF-Token": this.csrfToken(),
      "Accept": "application/json"
    }
    const options = { method, headers, credentials: "same-origin" }
    if (body !== undefined) {
      headers["Content-Type"] = "application/json"
      options.body = JSON.stringify(body)
    }

    return fetch(url, options).then((response) => {
      return response.text().then((text) => {
        let data = {}
        try { data = text ? JSON.parse(text) : {} } catch (e) { /* not JSON */ }
        if (!response.ok || data.error) {
          const message = data.error || this.statusMessage(response.status)
          throw new Error(Array.isArray(message) ? message.join(", ") : message)
        }
        return data
      })
    })
  }

  statusMessage(status) {
    switch (status) {
      case 401: return "Please log in and try again."
      case 403: return "You don't have permission to change this image."
      case 404: return "That image no longer exists."
      case 422: return "The server couldn't apply that change."
      default: return `Something went wrong (HTTP ${status}).`
    }
  }

  toast(message, type) {
    if (typeof window.showToast === "function") {
      window.showToast(message, type)
      return
    }
    const note = document.createElement("div")
    note.className = "fixed bottom-4 right-4 px-4 py-2 rounded-md text-white z-50 " + (type === "success" ? "bg-green-500" : "bg-red-500")
    note.textContent = message
    document.body.appendChild(note)
    setTimeout(() => note.remove(), 3000)
  }

  humanSize(bytes) {
    if (!bytes || bytes <= 0) return "0 KB"
    if (bytes < 1000 * 1000) return (bytes / 1000).toFixed(bytes < 100000 ? 1 : 0) + " KB"
    if (bytes < 1000 * 1000 * 1000) return (bytes / (1000 * 1000)).toFixed(1) + " MB"
    return (bytes / (1000 * 1000 * 1000)).toFixed(2) + " GB"
  }
}
