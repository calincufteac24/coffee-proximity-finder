import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["latitude", "longitude", "results", "loading", "error", "meta", "emptyState"]

  async search(event) {
    event.preventDefault()

    const lat = this.latitudeTarget.value.trim()
    const lng = this.longitudeTarget.value.trim()

    if (!lat || !lng) {
      this.showError("Please enter both latitude and longitude.")
      return
    }

    this.showLoading()
    this.hideError()
    this.hideResults()

    try {
      const response = await fetch(`/api/v1/coffee_shops?x=${encodeURIComponent(lat)}&y=${encodeURIComponent(lng)}`, {
        headers: { "Accept": "application/vnd.api+json" }
      })

      const json = await response.json()

      if (!response.ok) {
        const detail = json.errors?.[0]?.detail || "Something went wrong."
        this.showError(detail)
        return
      }

      this.renderResults(json)
    } catch (err) {
      this.showError("Network error. Is the server running?")
    }
  }

  useMyLocation() {
    if (!navigator.geolocation) {
      this.showError("Geolocation is not supported by your browser.")
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.latitudeTarget.value = position.coords.latitude.toFixed(6)
        this.longitudeTarget.value = position.coords.longitude.toFixed(6)
        this.latitudeTarget.dispatchEvent(new Event("input"))
        this.longitudeTarget.dispatchEvent(new Event("input"))
      },
      () => this.showError("Unable to retrieve your location.")
    )
  }

  renderResults(json) {
    const shops = json.data
    const meta = json.meta

    if (shops.length === 0) {
      this.emptyStateTarget.classList.remove("hidden")
      this.resultsTarget.classList.add("hidden")
      this.metaTarget.classList.add("hidden")
      this.loadingTarget.classList.add("hidden")
      return
    }

    this.emptyStateTarget.classList.add("hidden")

    this.resultsTarget.innerHTML = shops.map((shop, index) => {
      const attrs = shop.attributes
      const distance = parseFloat(attrs.distance).toFixed(4)
      const medals = ["🥇", "🥈", "🥉"]

      return `
        <div class="group relative bg-zinc-900/50 backdrop-blur-sm border border-zinc-800/50 rounded-2xl p-6
                    hover:border-amber-500/30 hover:bg-zinc-900/80 transition-all duration-300
                    animate-fade-in" style="animation-delay: ${index * 100}ms">
          <div class="flex items-start justify-between gap-4">
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-3 mb-3">
                <span class="text-2xl">${medals[index] || "☕"}</span>
                <h3 class="text-lg font-semibold text-zinc-100 truncate">${attrs.name}</h3>
              </div>
              <div class="flex flex-wrap gap-x-6 gap-y-2 text-sm text-zinc-400">
                <div class="flex items-center gap-1.5">
                  <svg class="w-4 h-4 text-zinc-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                  </svg>
                  <span>${attrs.latitude}, ${attrs.longitude}</span>
                </div>
              </div>
            </div>
            <div class="text-right shrink-0">
              <div class="text-2xl font-bold text-amber-400">${distance}</div>
              <div class="text-xs text-zinc-500 mt-0.5">km away</div>
            </div>
          </div>
        </div>
      `
    }).join("")

    // Meta info
    const syncedAt = meta.last_synced_at ? new Date(meta.last_synced_at).toLocaleString() : "Never"
    this.metaTarget.innerHTML = `
      <div class="flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-xs text-zinc-500">
        <span>Origin: ${meta.origin.latitude}, ${meta.origin.longitude}</span>
        <span class="hidden sm:inline">•</span>
        <span>Results: ${meta.total_count}</span>
        <span class="hidden sm:inline">•</span>
        <span>Last synced: ${syncedAt}</span>
      </div>
    `

    this.resultsTarget.classList.remove("hidden")
    this.metaTarget.classList.remove("hidden")
    this.loadingTarget.classList.add("hidden")
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
    this.resultsTarget.classList.add("hidden")
    this.metaTarget.classList.add("hidden")
    this.emptyStateTarget.classList.add("hidden")
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
    this.loadingTarget.classList.add("hidden")
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.metaTarget.classList.add("hidden")
    this.emptyStateTarget.classList.add("hidden")
  }
}
