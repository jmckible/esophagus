// Minimal service worker to enable PWA install prompt.
// Network-first strategy — the app relies on Turbo for navigation.
self.addEventListener("install", (event) => {
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(clients.claim())
})

self.addEventListener("fetch", (event) => {
  // Let the browser handle all fetches normally (network-first).
  // This satisfies the PWA installability requirement without
  // introducing caching complexity.
  return
})
