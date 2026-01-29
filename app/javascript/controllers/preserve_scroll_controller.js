import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    // Save scroll position before form submission
    sessionStorage.setItem('scrollPosition', window.scrollY.toString())
  }

  connect() {
    // Restore scroll position after page load
    const scrollPosition = sessionStorage.getItem('scrollPosition')
    if (scrollPosition) {
      window.scrollTo(0, parseInt(scrollPosition))
      sessionStorage.removeItem('scrollPosition')
    }
  }
}
