import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "messages", "input", "form", "submitBtn", "typingIndicator", "sidebar" ]
  static values = {
    chatUid: String,
    characterId: String,
    latestTimestamp: Number
  }

  connect() {
    this.scrollToBottom()
    this.startPolling()
  }

  disconnect() {
    this.stopPolling()
  }

  submit(event) {
    if (event.type === "keydown" && event.key !== "Enter") return
    if (event.type === "keydown" && event.shiftKey) return // Allow Shift+Enter for newline

    event.preventDefault()
    
    const content = this.inputTarget.value.trim()
    if (!content) return

    this.sendUserMessage(content)
  }

  async sendUserMessage(content) {
    // 1. Optimistically append user message
    this.lastUserMessage = content
    this.appendMessage({ role: 'user', content: content })
    this.inputTarget.value = ""
    this.inputTarget.style.height = 'auto' // reset auto-grow if any
    
    // 2. Disable input & show typing
    this.setLoadingState(true)

    // 3. Send to server
    const token = document.querySelector('meta[name="csrf-token"]').content
    try {
      const response = await fetch(`/ai/talk/to/${this.characterIdValue}/chats/${this.chatUidValue}/messages`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token,
          'Accept': 'application/json'
        },
        body: JSON.stringify({ content: content })
      })

      if (!response.ok) {
        throw new Error("Network response was not ok")
      }
      
      // Server returns 202 Accepted. Polling will pick up the AI response.
    } catch (error) {
      console.error("Error sending message:", error)
      this.appendMessage({ role: 'system', content: 'Failed to send message. Please try again.' })
      this.setLoadingState(false)
    }
  }

  startPolling() {
    this.pollInterval = setInterval(() => this.pollLatest(), 2000)
  }

  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
    }
  }

  async pollLatest() {
    try {
      const response = await fetch(`/ai/talk/to/${this.characterIdValue}/chats/${this.chatUidValue}/latest?since=${this.latestTimestampValue}`, {
        headers: { 'Accept': 'application/json' }
      })
      
      if (!response.ok) return

      const data = await response.json()
      
      if (data.messages && data.messages.length > 0) {
        let hasAiResponse = false

        data.messages.forEach(msg => {
          if (msg.timestamp > this.latestTimestampValue) {
            this.latestTimestampValue = msg.timestamp
          }
          
          // Deduplicate the optimistically rendered user message
          if (msg.role === 'user' && msg.content === this.lastUserMessage) {
            this.lastUserMessage = null
            return
          }

          this.appendMessage(msg)
          
          if (msg.role === 'ai' || msg.role === 'system') {
            hasAiResponse = true
          }
        })

        if (hasAiResponse) {
          this.setLoadingState(false)
        }
      }
    } catch (error) {
      console.error("Error polling messages:", error)
    }
  }

  appendMessage(msg) {
    // Don't render system messages visibly unless you want to, but we'll render errors.
    if (msg.role === 'system' && !msg.content.includes('Error') && !msg.content.includes('could not reply') && !msg.content.includes('Failed')) {
      return
    }

    const div = document.createElement('div')
    div.className = `flex w-full mb-4 ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`
    
    const bubble = document.createElement('div')
    
    if (msg.role === 'user') {
      bubble.className = "bg-blue-600 text-white rounded-2xl rounded-br-sm px-4 py-2 max-w-[80%] whitespace-pre-wrap"
      bubble.innerText = msg.content
    } else if (msg.role === 'ai') {
      bubble.className = "bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 border border-gray-200 dark:border-gray-700 shadow-sm rounded-2xl rounded-bl-sm px-4 py-2 max-w-[80%] whitespace-pre-wrap"
      bubble.innerText = msg.content
    } else {
       // System error msg
      bubble.className = "bg-red-50 text-red-600 rounded-2xl px-4 py-2 max-w-[80%] italic text-sm text-center mx-auto whitespace-pre-wrap"
      bubble.innerText = msg.content
    }

    div.appendChild(bubble)
    this.messagesTarget.appendChild(div)
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  setLoadingState(isLoading) {
    this.inputTarget.disabled = isLoading
    this.submitBtnTarget.disabled = isLoading
    
    if (isLoading) {
      // Create typing indicator if it doesn't exist
      const div = document.createElement('div')
      div.id = "chat-typing-indicator"
      div.className = "flex w-full mb-4 justify-start"
      div.innerHTML = `
        <div class="bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-2xl rounded-bl-sm px-4 py-3 flex items-center space-x-1">
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0s;"></div>
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.2s;"></div>
          <div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.4s;"></div>
        </div>
      `
      this.messagesTarget.appendChild(div)
      this.scrollToBottom()
    } else {
      const indicator = document.getElementById("chat-typing-indicator")
      if (indicator) indicator.remove()
      
      // Auto-focus input after AI replies
      setTimeout(() => this.inputTarget.focus(), 100)
    }
  }

  toggleSidebar() {
    this.sidebarTarget.classList.toggle('hidden')
    this.sidebarTarget.classList.toggle('flex')
  }
}
