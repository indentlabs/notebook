import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.createOverlay()
    this.boundHandleMouseOver = this.handleMouseOver.bind(this)
    this.boundHandleMouseOut = this.handleMouseOut.bind(this)
    
    // Use event delegation on the document
    document.addEventListener("mouseover", this.boundHandleMouseOver)
    document.addEventListener("mouseout", this.boundHandleMouseOut)
  }

  disconnect() {
    document.removeEventListener("mouseover", this.boundHandleMouseOver)
    document.removeEventListener("mouseout", this.boundHandleMouseOut)
    if (this.overlay) {
      this.overlay.remove()
    }
  }

  createOverlay() {
    if (document.getElementById("global-tooltip-overlay")) {
      this.overlay = document.getElementById("global-tooltip-overlay")
      return
    }

    this.overlay = document.createElement("div")
    this.overlay.id = "global-tooltip-overlay"
    // Tailwind classes for a sleek tooltip with small rounded text, initially hidden but preserving bounds
    this.overlay.className = "fixed pointer-events-none opacity-0 transition-opacity duration-150 z-50 bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 text-sm py-1.5 px-3 rounded-lg shadow-xl whitespace-nowrap font-medium tracking-wide"
    this.overlay.style.zIndex = "99999"
    document.body.appendChild(this.overlay)
  }

  handleMouseOver(event) {
    // Find closest element with class 'tooltipped' or attribute 'data-tooltip'
    const target = event.target.closest('.tooltipped, [data-tooltip], .sidebar-tooltip')
    if (!target) return

    const tooltipText = target.getAttribute('data-tooltip') || target.getAttribute('title')
    if (!tooltipText) return
    
    // Remove native title so browser tooltip doesn't also show
    if (target.getAttribute('title')) {
      target.removeAttribute('title')
      // Store it in data-tooltip so we don't lose it on subsequent hovers
      target.setAttribute('data-tooltip', tooltipText)
    }

    this.overlay.textContent = tooltipText
    
    // Calculate position
    const rect = target.getBoundingClientRect()
    // Read data-position, fallback to 'top'. 
    // Wait, the sidebar specifies 'right' but some might not specify anything.
    let position = target.getAttribute('data-position') || 'top' 
    
    // Automatically swap position if it's the sidebar-tooltip because the layout is specific
    if (target.classList.contains('sidebar-tooltip')) {
      position = 'right'
    }

    const tooltipRect = this.overlay.getBoundingClientRect()
    const spacing = 10 // distance from element
    let top, left

    switch (position) {
      case 'bottom':
        top = rect.bottom + spacing
        left = rect.left + (rect.width / 2) - (tooltipRect.width / 2)
        break;
      case 'right':
        top = rect.top + (rect.height / 2) - (tooltipRect.height / 2)
        left = rect.right + spacing
        break;
      case 'left':
        top = rect.top + (rect.height / 2) - (tooltipRect.height / 2)
        left = rect.left - tooltipRect.width - spacing
        break;
      case 'top':
      default:
        top = rect.top - tooltipRect.height - spacing
        left = rect.left + (rect.width / 2) - (tooltipRect.width / 2)
        break;
    }
    
    // Simple edge detection to prevent tooltip going off-screen horizontally or vertically
    const padding = 12
    if (left < padding) left = padding
    if (top < padding) top = rect.bottom + spacing // flip to bottom if hit top
    if (left + tooltipRect.width > window.innerWidth - padding) {
      left = window.innerWidth - tooltipRect.width - padding
    }
    
    this.overlay.style.top = `${top}px`
    this.overlay.style.left = `${left}px`
    this.overlay.classList.remove('opacity-0')
    this.overlay.classList.add('opacity-100')
  }

  handleMouseOut(event) {
    const target = event.target.closest('.tooltipped, [data-tooltip], .sidebar-tooltip')
    if (!target) return

    this.overlay.classList.remove('opacity-100')
    this.overlay.classList.add('opacity-0')
  }
}
