import { Controller } from "@hotwired/stimulus"

// The index's sticky bar: names the section under it, opens the jump sheet,
// and filters rows by name. Filtering hides rows rather than refetching, so
// it works offline in the PWA and survives Turbo morphs untouched.
export default class extends Controller {
  static targets = ["bar", "section", "currentName", "currentMark", "find", "empty", "sheet"]

  connect() {
    this.track()
  }

  track() {
    if (this.frame) return
    this.frame = requestAnimationFrame(() => {
      this.frame = null
      const line = this.barTarget.getBoundingClientRect().bottom + 8
      const visible = this.sectionTargets.filter(s => !s.hidden)
      const passed = visible.filter(s => s.getBoundingClientRect().top <= line)
      const current = passed.sort((a, b) => b.getBoundingClientRect().top - a.getBoundingClientRect().top)[0] || visible[0]
      if (current) this.show(current)
    })
  }

  show(section) {
    this.currentNameTarget.textContent = section.dataset.name
    this.currentMarkTarget.className = ["section-mark", section.dataset.hue].filter(Boolean).join(" ")
  }

  filter() {
    const query = this.findTarget.value.trim().toLowerCase()
    this.element.classList.toggle("is-filtering", query.length > 0)

    let any = false
    this.sectionTargets.forEach(section => {
      let sectionHit = false
      section.querySelectorAll(".index-family").forEach(family => {
        let familyHit = false
        family.querySelectorAll(".index-row").forEach(row => {
          const hit = !query || row.dataset.search.includes(query)
          row.hidden = !hit
          familyHit ||= hit
        })
        family.hidden = !familyHit
        sectionHit ||= familyHit
      })
      section.hidden = !sectionHit
      any ||= sectionHit
    })
    this.emptyTarget.hidden = any
    this.track()
  }

  clear() {
    this.findTarget.value = ""
    this.filter()
    this.findTarget.blur()
  }

  shortcut(event) {
    if (event.key !== "/" || event.target.closest("input, textarea, [contenteditable]")) return
    event.preventDefault()
    this.findTarget.focus()
  }

  openSheet() {
    this.sheetTarget.showModal()
  }

  closeOnBackdrop(event) {
    if (event.target === this.sheetTarget) this.sheetTarget.close()
  }

  jump() {
    if (this.findTarget.value) this.clear()
    this.sheetTarget.close()
  }

  top() {
    this.sheetTarget.close()
    window.scrollTo({ top: 0 })
  }
}
