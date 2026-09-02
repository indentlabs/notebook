import { Controller } from "stimulus"
import Cropper from "cropperjs"
import "cropperjs/dist/cropper.css"

// Per-image framing editor for the gallery tab.
//
// Opens when a gallery card dispatches "gallery:edit" (or when the page hash
// is "#gallery/<dom_id>"). Lets the writer pick a focal point and, per display
// shape (ImagePresets), a crop rectangle with pan and zoom. Crops are kept
// normalised (fractions of the original image) so the server can validate
// and render them at any size.
//
// Cropper.js does the geometry and touch handling. We never read pixels
// from the canvas, so cross-origin S3 images work without CORS headers.
export default class extends Controller {
  static targets = [
    "modal", "subtitle", "coverButton", "coverLabel",
    "shapeTab", "shapeState", "stage", "loading", "image",
    "focalLayer", "focalDot", "cropControls", "zoom", "gridToggle", "help",
    "preview", "previewTitle", "previewBadge", "usage",
    "notes", "privacyRow", "privacy", "facts", "downloadLink",
    "status", "saveButton"
  ]

  static values = { presets: Array, pageName: String, pageType: String }

  connect() {
    // The edit page wraps its content in transformed containers, which would
    // make our fixed-position modal scroll and clip with them. Live on <body>.
    if (this.element.parentElement !== document.body) {
      document.body.appendChild(this.element)
      return // Stimulus reconnects the controller after the move
    }

    this.onGalleryEdit = this.onGalleryEdit.bind(this)
    this.onResize = this.onResize.bind(this)
    this.onCoversChanged = this.onCoversChanged.bind(this)
    window.addEventListener("gallery:edit", this.onGalleryEdit)
    window.addEventListener("resize", this.onResize)
    window.addEventListener("gallery:covers-changed", this.onCoversChanged)
    this.presetMap = {}
    this.presetsValue.forEach((preset) => { this.presetMap[preset.key] = preset })
    this.open = false
    this.openFromHash()
  }

  disconnect() {
    if (this.onGalleryEdit) window.removeEventListener("gallery:edit", this.onGalleryEdit)
    if (this.onResize) window.removeEventListener("resize", this.onResize)
    if (this.onCoversChanged) window.removeEventListener("gallery:covers-changed", this.onCoversChanged)
    this.destroyCropper()
  }

  // ---------------------------------------------------------------------
  // Opening and closing
  // ---------------------------------------------------------------------

  onGalleryEdit(event) {
    if (!event.detail || !event.detail.card) return
    event.preventDefault()
    this.openFor(event.detail.card)
  }

  openFromHash() {
    const match = window.location.hash.match(/^#gallery\/([a-z]+-\d+)$/)
    if (!match) return
    const card = document.getElementById("gallery-" + match[1])
    if (card) this.openFor(card)
  }

  openFor(card) {
    this.card = card
    this.info = { ...card.dataset }
    this.naturalWidth = parseInt(this.info.width, 10) || 0
    this.naturalHeight = parseInt(this.info.height, 10) || 0
    this.focal = {
      x: this.clamp(parseFloat(this.info.focalX) || 0.5, 0, 1),
      y: this.clamp(parseFloat(this.info.focalY) || 0.5, 0, 1)
    }
    this.crops = {}
    this.custom = {}
    try {
      const stored = JSON.parse(this.info.crops || "{}")
      Object.keys(stored).forEach((key) => {
        const rect = stored[key]
        if (rect && this.presetMap[key]) {
          this.crops[key] = { x: +rect.x, y: +rect.y, w: +rect.w, h: +rect.h }
          this.custom[key] = true
        }
      })
    } catch (e) { /* ignore malformed data */ }
    this.dirty = false
    this.saving = false
    this.currentPreset = null

    this.fillDetails()
    this.previousHash = window.location.hash
    window.location.hash = "gallery/" + card.id.replace(/^gallery-/, "")

    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    this.open = true
    this.previousFocus = document.activeElement

    this.loadImage()
  }

  close(event) {
    if (event) event.preventDefault()
    if (!this.open) return
    if (this.dirty && !window.confirm("Discard your unsaved framing changes?")) return
    this.teardown()
  }

  teardown() {
    this.destroyCropper()
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
    this.open = false
    if (window.location.hash.startsWith("#gallery/")) {
      history.replaceState(null, "", window.location.pathname + window.location.search + "#gallery")
    }
    if (this.previousFocus && this.previousFocus.focus) this.previousFocus.focus()
    this.card = null
  }

  fillDetails() {
    const pieces = [this.info.filename, this.dimensionsLabel(), this.humanSize(parseInt(this.info.byteSize, 10)), this.info.sourceLabel].filter(Boolean)
    this.subtitleTarget.textContent = pieces.join(" · ")

    this.applyCoverState(this.info.pinned === "true")

    const notes = this.card.querySelector("[data-gallery-target='notes']")
    this.notesTarget.value = notes ? notes.value : ""
    this.originalNotes = this.notesTarget.value

    const supportsPrivacy = !!this.card.querySelector("[data-gallery-target='privacyButton']")
    this.privacyRowTarget.classList.toggle("hidden", !supportsPrivacy)
    this.privacyTarget.value = this.info.privacy || "public"
    this.originalPrivacy = this.privacyTarget.value

    this.factsTarget.innerHTML = ""
    const facts = [
      ["Source", this.info.sourceLabel],
      ["File", this.info.filename],
      ["Size", this.dimensionsLabel() ? `${this.dimensionsLabel()} · ${this.humanSize(parseInt(this.info.byteSize, 10))}` : this.humanSize(parseInt(this.info.byteSize, 10))]
    ]
    facts.forEach(([label, value]) => {
      if (!value) return
      const row = document.createElement("div")
      row.className = "flex justify-between gap-3"
      const dt = document.createElement("dt")
      dt.textContent = label
      const dd = document.createElement("dd")
      dd.className = "text-right text-gray-700 dark:text-gray-200 truncate"
      dd.textContent = value
      row.appendChild(dt)
      row.appendChild(dd)
      this.factsTarget.appendChild(row)
    })

    this.downloadLinkTarget.href = this.info.originalUrl || "#"

    const pageName = this.pageNameValue || "This page"
    this.previewTitleTargets.forEach((el) => { el.textContent = pageName })
    if (this.hasPreviewBadgeTarget) this.previewBadgeTarget.textContent = this.pageTypeValue || ""

    this.refreshCoverRoles()
    this.setStatus("")
  }

  onCoversChanged() {
    if (!this.open || !this.card) return
    this.applyCoverState(this.card.dataset.pinned === "true")
    this.refreshCoverRoles()
  }

  // Header menu checks and the "Used now" line under each preview.
  refreshCoverRoles() {
    const gallery = this.galleryController()
    const roles = gallery ? gallery.rolesOf(this.card) : []
    this.element.querySelectorAll("[data-action*='image-editor#toggleCoverFor']").forEach((item) => {
      const active = roles.includes(item.dataset.preset)
      item.setAttribute("aria-checked", active ? "true" : "false")
      const check = item.querySelector("[data-role-check]")
      if (check) check.classList.toggle("invisible", !active)
    })

    if (!this.hasUsageTarget) return
    const cards = gallery ? gallery.cardTargets : []
    this.usageTargets.forEach((el) => {
      const preset = el.dataset.preset
      const specific = cards.find((card) => gallery.rolesOf(card).includes(preset))
      const pinned = cards.find((card) => card.dataset.pinned === "true")
      let text
      if (specific) {
        text = specific === this.card ? "Used now: this image" : `Used now: ${specific.dataset.filename || "another image"}`
      } else if (pinned) {
        text = pinned === this.card ? "Used now: this image (cover)" : "Used now: the cover image"
      } else {
        text = "Used now: a random image"
      }
      el.textContent = text
      el.classList.toggle("text-blue-600", !!specific && specific === this.card)
      el.classList.toggle("dark:text-blue-400", !!specific && specific === this.card)
    })
  }

  toggleCoverFor(event) {
    const gallery = this.galleryController()
    const preset = event.currentTarget.dataset.preset
    const details = event.currentTarget.closest("details")
    if (details) details.open = false
    if (!gallery || !this.card || !preset) return
    const item = this.card.querySelector(`[data-action*='gallery#toggleCoverFor'][data-preset='${preset}']`)
    if (!item) return
    gallery.toggleCoverFor({ target: item, currentTarget: item })
    setTimeout(() => this.refreshCoverRoles(), 1500)
  }

  loadImage() {
    this.destroyCropper()
    this.loadingTarget.classList.remove("hidden")
    this.imageTarget.classList.add("opacity-0")
    this.imageTarget.removeAttribute("src")

    const url = this.info.originalUrl || this.info.largeUrl
    const img = this.imageTarget
    const onLoad = () => {
      img.removeEventListener("load", onLoad)
      img.removeEventListener("error", onError)
      if (!this.naturalWidth || !this.naturalHeight) {
        this.naturalWidth = img.naturalWidth
        this.naturalHeight = img.naturalHeight
      }
      this.initCropper()
    }
    const onError = () => {
      img.removeEventListener("load", onLoad)
      img.removeEventListener("error", onError)
      this.loadingTarget.innerHTML = '<i class="material-icons mr-2">broken_image</i> The original image couldn\'t be loaded.'
    }
    img.addEventListener("load", onLoad)
    img.addEventListener("error", onError)
    img.src = url
  }

  // ---------------------------------------------------------------------
  // Cropper lifecycle
  // ---------------------------------------------------------------------

  initCropper() {
    const firstPreset = this.presetsValue[0].key
    this.applying = true
    this.cropper = new Cropper(this.imageTarget, {
      viewMode: 1,
      dragMode: "move",
      aspectRatio: this.presetMap[firstPreset].aspect,
      autoCrop: true,
      autoCropArea: 1,
      responsive: true,
      restore: false,
      background: false,
      modal: true,
      guides: this.gridToggleTarget.checked,
      center: true,
      highlight: false,
      movable: true,
      rotatable: false,
      scalable: false,
      zoomable: true,
      zoomOnTouch: true,
      zoomOnWheel: true,
      wheelZoomRatio: 0.08,
      cropBoxMovable: true,
      cropBoxResizable: true,
      toggleDragModeOnDblclick: false,
      checkCrossOrigin: false,
      checkOrientation: false,
      minCropBoxWidth: 24,
      minCropBoxHeight: 24,
      ready: () => {
        this.loadingTarget.classList.add("hidden")
        this.imageTarget.classList.remove("opacity-0")
        const canvas = this.cropper.getCanvasData()
        this.fitZoom = canvas.width / canvas.naturalWidth
        this.zoomTarget.value = "1"
        this.selectPresetKey(firstPreset)
        this.renderAllPreviews()
        this.applying = false
      },
      crop: () => {
        if (this.applying || !this.currentPreset || this.currentPreset === "focal") return
        const rect = this.normalizedFromCropper()
        if (!rect) return
        this.crops[this.currentPreset] = rect
        if (!this.custom[this.currentPreset]) {
          this.custom[this.currentPreset] = true
          this.refreshShapeStates()
        }
        this.markDirty()
        this.schedulePreview(this.currentPreset)
      },
      zoom: (event) => {
        if (this.currentPreset === "focal") { event.preventDefault(); return }
        if (!this.fitZoom) return
        const ratio = event.detail.ratio / this.fitZoom
        if (ratio < 0.999) { event.preventDefault(); return }
        if (ratio > 4.001) { event.preventDefault(); return }
        this.zoomTarget.value = ratio.toFixed(2)
      }
    })
  }

  destroyCropper() {
    if (this.cropper) {
      try { this.cropper.destroy() } catch (e) { /* noop */ }
      this.cropper = null
    }
    this.fitZoom = null
  }

  onResize() {
    if (!this.open || !this.cropper || this.currentPreset === "focal") return
    // Cropper handles its own resize; re-apply the rect so the box stays put.
    clearTimeout(this._resizeTimer)
    this._resizeTimer = setTimeout(() => this.applyRect(this.crops[this.currentPreset]), 120)
  }

  // ---------------------------------------------------------------------
  // Shapes
  // ---------------------------------------------------------------------

  selectShape(event) {
    const key = event.currentTarget.dataset.preset
    this.selectPresetKey(key)
  }

  selectPresetKey(key) {
    if (!this.cropper) return
    const leavingFocal = this.currentPreset === "focal"
    this.currentPreset = key

    this.shapeTabTargets.forEach((tab) => {
      const active = tab.dataset.preset === key
      tab.setAttribute("aria-selected", active ? "true" : "false")
      tab.classList.toggle("ring-2", active)
      tab.classList.toggle("ring-blue-500", active)
      tab.classList.toggle("border-blue-500", active)
    })

    if (key === "focal") {
      this.enterFocalMode()
      return
    }

    if (leavingFocal) this.exitFocalMode()
    this.cropControlsTarget.classList.remove("hidden")
    const preset = this.presetMap[key]
    this.applying = true
    this.cropper.setAspectRatio(preset.aspect)
    const rect = this.crops[key] || this.autoRect(key)
    this.crops[key] = rect
    this.applyRect(rect)
    this.applying = false
    this.refreshShapeStates()
    this.helpTarget.textContent = `Drag the box to choose what shows in the ${preset.label.toLowerCase()} (${preset.ratio_label || this.ratioLabel(preset)}). Drag a corner to zoom in or out, or use the slider. Arrow keys nudge.`
    this.schedulePreview(key)
  }

  refreshShapeStates() {
    this.shapeTabTargets.forEach((tab) => {
      const key = tab.dataset.preset
      const state = tab.querySelector("[data-image-editor-target='shapeState']")
      if (!state) return
      const isCustom = !!this.custom[key]
      state.textContent = isCustom ? "custom" : "auto"
      state.classList.toggle("bg-blue-100", isCustom)
      state.classList.toggle("text-blue-700", isCustom)
      state.classList.toggle("dark:bg-blue-900", isCustom)
      state.classList.toggle("dark:text-blue-200", isCustom)
      state.classList.toggle("bg-gray-100", !isCustom)
      state.classList.toggle("text-gray-500", !isCustom)
      state.classList.toggle("dark:bg-gray-700", !isCustom)
      state.classList.toggle("dark:text-gray-300", !isCustom)
    })
  }

  resetShape() {
    if (!this.currentPreset || this.currentPreset === "focal") return
    delete this.custom[this.currentPreset]
    this.crops[this.currentPreset] = this.autoRect(this.currentPreset)
    this.applying = true
    this.applyRect(this.crops[this.currentPreset])
    this.applying = false
    this.refreshShapeStates()
    this.markDirty()
    this.schedulePreview(this.currentPreset)
  }

  centerOnFocal() {
    if (!this.currentPreset || this.currentPreset === "focal") return
    const rect = { ...this.crops[this.currentPreset] }
    rect.x = this.clamp(this.focal.x - rect.w / 2, 0, 1 - rect.w)
    rect.y = this.clamp(this.focal.y - rect.h / 2, 0, 1 - rect.h)
    this.setRect(this.currentPreset, rect)
  }

  copyToAll() {
    if (!this.currentPreset || this.currentPreset === "focal") return
    const source = this.crops[this.currentPreset]
    const cx = source.x + source.w / 2
    const cy = source.y + source.h / 2
    const sourceHeightPx = source.h * this.naturalHeight
    Object.keys(this.presetMap).forEach((key) => {
      if (key === this.currentPreset) return
      const preset = this.presetMap[key]
      let hPx = sourceHeightPx
      let wPx = hPx * preset.aspect
      if (wPx > this.naturalWidth) { wPx = this.naturalWidth; hPx = wPx / preset.aspect }
      if (hPx > this.naturalHeight) { hPx = this.naturalHeight; wPx = hPx * preset.aspect }
      const w = wPx / this.naturalWidth
      const h = hPx / this.naturalHeight
      this.crops[key] = {
        x: this.clamp(cx - w / 2, 0, 1 - w),
        y: this.clamp(cy - h / 2, 0, 1 - h),
        w, h
      }
      this.custom[key] = true
      this.renderPreview(key)
    })
    this.refreshShapeStates()
    this.markDirty()
    this.setStatus("Framing copied to the other shapes.")
  }

  setRect(key, rect) {
    this.crops[key] = rect
    this.custom[key] = true
    if (key === this.currentPreset) {
      this.applying = true
      this.applyRect(rect)
      this.applying = false
    }
    this.refreshShapeStates()
    this.markDirty()
    this.schedulePreview(key)
  }

  // The largest rect of the preset's shape that fits, centred on the focal point.
  autoRect(key) {
    const preset = this.presetMap[key]
    const imageAspect = this.naturalWidth / this.naturalHeight
    let w, h
    if (imageAspect >= preset.aspect) {
      h = 1
      w = preset.aspect / imageAspect
    } else {
      w = 1
      h = imageAspect / preset.aspect
    }
    return {
      x: this.clamp(this.focal.x - w / 2, 0, 1 - w),
      y: this.clamp(this.focal.y - h / 2, 0, 1 - h),
      w, h
    }
  }

  applyRect(rect) {
    if (!this.cropper || !rect) return
    this.cropper.setData({
      x: rect.x * this.naturalWidth,
      y: rect.y * this.naturalHeight,
      width: rect.w * this.naturalWidth,
      height: rect.h * this.naturalHeight
    })
  }

  normalizedFromCropper() {
    const data = this.cropper.getData()
    if (!data || !this.naturalWidth || !this.naturalHeight) return null
    const w = this.clamp(data.width / this.naturalWidth, 0.01, 1)
    const h = this.clamp(data.height / this.naturalHeight, 0.01, 1)
    return {
      x: this.clamp(data.x / this.naturalWidth, 0, 1 - w),
      y: this.clamp(data.y / this.naturalHeight, 0, 1 - h),
      w, h
    }
  }

  // ---------------------------------------------------------------------
  // Zoom, grid, keyboard
  // ---------------------------------------------------------------------

  zoomSlider(event) {
    if (!this.cropper || !this.fitZoom) return
    this.cropper.zoomTo(parseFloat(event.target.value) * this.fitZoom)
  }

  zoomIn() { this.nudgeZoom(0.15) }
  zoomOut() { this.nudgeZoom(-0.15) }

  nudgeZoom(delta) {
    if (!this.cropper || !this.fitZoom) return
    const next = this.clamp(parseFloat(this.zoomTarget.value) + delta, 1, 4)
    this.zoomTarget.value = next.toFixed(2)
    this.cropper.zoomTo(next * this.fitZoom)
  }

  toggleGrid(event) {
    if (!this.cropper) return
    // Cropper has no runtime toggle for guides; flip the class it renders.
    const guides = this.stageTarget.querySelectorAll(".cropper-dashed")
    guides.forEach((el) => { el.style.display = event.target.checked ? "" : "none" })
  }

  keydown(event) {
    if (!this.open) return
    const tag = (event.target.tagName || "").toLowerCase()
    const typing = tag === "textarea" || tag === "input" || tag === "select"

    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
      return
    }
    if (event.key === "Enter" && (event.metaKey || event.ctrlKey)) {
      event.preventDefault()
      this.save()
      return
    }
    if (typing) return

    if (/^[1-9]$/.test(event.key)) {
      const index = parseInt(event.key, 10) - 1
      const preset = this.presetsValue[index]
      if (preset) { event.preventDefault(); this.selectPresetKey(preset.key); return }
      if (index === this.presetsValue.length) { event.preventDefault(); this.selectPresetKey("focal"); return }
      return
    }
    if (event.key === "f") { event.preventDefault(); this.selectPresetKey("focal"); return }
    if (event.key === "+" || event.key === "=") { event.preventDefault(); this.zoomIn(); return }
    if (event.key === "-" || event.key === "_") { event.preventDefault(); this.zoomOut(); return }

    const step = event.shiftKey ? 0.05 : 0.01
    const moves = { ArrowLeft: [-step, 0], ArrowRight: [step, 0], ArrowUp: [0, -step], ArrowDown: [0, step] }
    if (moves[event.key]) {
      event.preventDefault()
      const [dx, dy] = moves[event.key]
      if (this.currentPreset === "focal") {
        this.setFocal(this.focal.x + dx, this.focal.y + dy)
      } else if (this.currentPreset) {
        const rect = { ...this.crops[this.currentPreset] }
        rect.x = this.clamp(rect.x + dx, 0, 1 - rect.w)
        rect.y = this.clamp(rect.y + dy, 0, 1 - rect.h)
        this.setRect(this.currentPreset, rect)
      }
    }
  }

  // ---------------------------------------------------------------------
  // Focal point mode
  // ---------------------------------------------------------------------

  enterFocalMode() {
    this.cropControlsTarget.classList.add("hidden")
    this.applying = true
    this.cropper.clear()
    this.cropper.disable()
    this.applying = false
    this.focalLayerTarget.classList.remove("hidden")
    this.positionFocalDot()
    this.helpTarget.textContent = "Drag the dot to the most important part of the image. Wherever the image is shown without its own crop, this point stays in view."
  }

  exitFocalMode() {
    this.focalLayerTarget.classList.add("hidden")
    this.applying = true
    this.cropper.enable()
    this.cropper.crop()
    this.applying = false
  }

  positionFocalDot() {
    if (!this.cropper) return
    const canvas = this.cropper.getCanvasData()
    this.focalDotTarget.style.left = (canvas.left + this.focal.x * canvas.width) + "px"
    this.focalDotTarget.style.top = (canvas.top + this.focal.y * canvas.height) + "px"
  }

  focalPointerDown(event) {
    event.preventDefault()
    this.focalDragging = true
    this.focalLayerTarget.setPointerCapture(event.pointerId)
    this.focalFromPointer(event)
  }

  focalPointerMove(event) {
    if (!this.focalDragging) return
    this.focalFromPointer(event)
  }

  focalPointerUp(event) {
    if (!this.focalDragging) return
    this.focalDragging = false
    try { this.focalLayerTarget.releasePointerCapture(event.pointerId) } catch (e) { /* noop */ }
  }

  focalFromPointer(event) {
    const canvas = this.cropper.getCanvasData()
    const bounds = this.focalLayerTarget.getBoundingClientRect()
    const x = (event.clientX - bounds.left - canvas.left) / canvas.width
    const y = (event.clientY - bounds.top - canvas.top) / canvas.height
    this.setFocal(x, y)
  }

  setFocal(x, y) {
    this.focal = { x: this.clamp(x, 0, 1), y: this.clamp(y, 0, 1) }
    this.positionFocalDot()
    // Shapes that are still automatic follow the focal point.
    Object.keys(this.presetMap).forEach((key) => {
      if (!this.custom[key]) {
        this.crops[key] = this.autoRect(key)
        this.renderPreview(key)
      }
    })
    this.markDirty()
  }

  // ---------------------------------------------------------------------
  // Previews (pure CSS from the normalised rects)
  // ---------------------------------------------------------------------

  schedulePreview(key) {
    if (this._previewFrame) cancelAnimationFrame(this._previewFrame)
    this._previewFrame = requestAnimationFrame(() => this.renderPreview(key))
  }

  renderAllPreviews() {
    Object.keys(this.presetMap).forEach((key) => {
      if (!this.crops[key]) this.crops[key] = this.autoRect(key)
      this.renderPreview(key)
    })
  }

  renderPreview(key) {
    const rect = this.crops[key]
    if (!rect) return
    const src = this.info.largeUrl || this.info.originalUrl
    this.previewTargets.forEach((box) => {
      if (box.dataset.preset !== key) return
      let img = box.querySelector("img")
      if (!img) {
        img = document.createElement("img")
        img.alt = ""
        img.draggable = false
        img.className = "absolute max-w-none select-none"
        img.src = src
        box.appendChild(img)
      }
      const boxWidth = box.clientWidth || 1
      const boxHeight = box.clientHeight || 1
      // Scale so the crop rect exactly fills the box.
      const scaleX = boxWidth / (rect.w * this.naturalWidth)
      const scaleY = boxHeight / (rect.h * this.naturalHeight)
      const scale = Math.max(scaleX, scaleY)
      img.style.width = (this.naturalWidth * scale) + "px"
      img.style.height = (this.naturalHeight * scale) + "px"
      img.style.left = (-rect.x * this.naturalWidth * scale) + "px"
      img.style.top = (-rect.y * this.naturalHeight * scale) + "px"
    })
  }

  // ---------------------------------------------------------------------
  // Cover, delete
  // ---------------------------------------------------------------------

  toggleCover() {
    const gallery = this.galleryController()
    if (!gallery || !this.card) return
    const button = this.card.querySelector("[data-gallery-target='coverButton']")
    gallery.toggleCover({ target: button })
    // Reflect the optimistic state; the gallery reconciles the card itself.
    setTimeout(() => this.applyCoverState(this.card.dataset.pinned === "true"), 50)
    setTimeout(() => this.applyCoverState(this.card.dataset.pinned === "true"), 1500)
  }

  applyCoverState(isCover) {
    this.coverButtonTarget.setAttribute("aria-pressed", isCover ? "true" : "false")
    const active = ["bg-yellow-400", "border-yellow-400", "text-yellow-900"]
    const inactive = ["border-gray-300", "dark:border-gray-600", "text-gray-700", "dark:text-gray-200", "hover:bg-yellow-50", "dark:hover:bg-gray-700"]
    active.forEach((c) => this.coverButtonTarget.classList.toggle(c, isCover))
    inactive.forEach((c) => this.coverButtonTarget.classList.toggle(c, !isCover))
    this.coverButtonTarget.querySelector(".material-icons").textContent = isCover ? "star" : "star_border"
    this.coverLabelTarget.textContent = isCover ? "Cover" : "Set as cover"
  }

  deleteImage() {
    const gallery = this.galleryController()
    const card = this.card
    if (!gallery || !card) return
    this.dirty = false
    this.teardown()
    gallery.showDeleteConfirm(card)
    card.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  // ---------------------------------------------------------------------
  // Saving
  // ---------------------------------------------------------------------

  save(event) {
    if (event) event.preventDefault()
    if (!this.card || this.saving) return
    this.saving = true
    this.saveButtonTarget.disabled = true
    this.setStatus("Saving…")

    const crops = {}
    Object.keys(this.presetMap).forEach((key) => {
      crops[key] = this.custom[key] ? this.roundRect(this.crops[key]) : null
    })

    const attributes = {
      crops,
      focal_x: +this.focal.x.toFixed(4),
      focal_y: +this.focal.y.toFixed(4)
    }
    if (this.notesTarget.value !== this.originalNotes) attributes.notes = this.notesTarget.value
    if (!this.privacyRowTarget.classList.contains("hidden") && this.privacyTarget.value !== this.originalPrivacy) {
      attributes.privacy = this.privacyTarget.value
    }

    const gallery = this.galleryController()
    const request = gallery
      ? gallery.request(this.info.updateUrl, "PATCH", { [this.info.paramKey]: attributes })
      : Promise.reject(new Error("Gallery controller not found"))

    request
      .then((data) => {
        if (gallery && data.image) gallery.refreshCard(this.card, data.image)
        this.dirty = false
        this.setStatus("Saved")
        if (gallery) gallery.toast("Framing saved", "success")
        this.teardown()
      })
      .catch((error) => {
        this.setStatus(error.message || "Couldn't save the framing")
        if (gallery) gallery.toast(error.message || "Couldn't save the framing", "error")
      })
      .finally(() => {
        this.saving = false
        this.saveButtonTarget.disabled = false
      })
  }

  markDirty() {
    this.dirty = true
    this.setStatus("Unsaved changes")
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  galleryController() {
    const root = this.element.closest("[data-controller~='gallery']") || document.querySelector("[data-controller~='gallery']")
    if (!root) return null
    return this.application.getControllerForElementAndIdentifier(root, "gallery")
  }

  dimensionsLabel() {
    return this.naturalWidth && this.naturalHeight ? `${this.naturalWidth} × ${this.naturalHeight}` : ""
  }

  ratioLabel(preset) {
    return preset.ratio ? `${preset.ratio[0]}:${preset.ratio[1]}` : ""
  }

  roundRect(rect) {
    return { x: +rect.x.toFixed(4), y: +rect.y.toFixed(4), w: +rect.w.toFixed(4), h: +rect.h.toFixed(4) }
  }

  clamp(value, min, max) {
    if (Number.isNaN(value)) return min
    return Math.min(Math.max(value, min), max)
  }

  humanSize(bytes) {
    if (!bytes || bytes <= 0) return ""
    if (bytes < 1000 * 1000) return (bytes / 1000).toFixed(0) + " KB"
    return (bytes / (1000 * 1000)).toFixed(1) + " MB"
  }
}
