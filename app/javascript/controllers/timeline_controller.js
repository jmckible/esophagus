import { Controller } from '@hotwired/stimulus'

// Works a recipe's steps back from a ready time. A step that takes clock time
// opens with its duration as inline code:
//   `10 min`, `1½ h`  takes that long
//   `~5 h`            about that long
//   `6 h+`            at least that long, so it can start the night before
//   `≤ 1½ h`          a hold that can last up to that long; planned at half,
//                     so the steps before it can run early or late
//   `+1 h`            happens that far into the previous timed step
// A step without one happens alongside the previous timed step.
const STORAGE_KEY = 'esophagus.readyAt'
const FRACTIONS = { '½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3 }
const MINUTE = 60 * 1000

export default class extends Controller {
  static targets = ['readyAt', 'summary']

  // Also runs after a Turbo morph, which drops the step labels and resets the input
  connect() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY)
      if (saved) this.readyAtTarget.value = saved
    } catch {}
    this.render()
  }

  refresh() {
    this.connect()
  }

  change() {
    try { localStorage.setItem(STORAGE_KEY, this.readyAtTarget.value) } catch {}
    this.render()
  }

  render() {
    const [hours, minutes] = (this.readyAtTarget.value || '17:30').split(':').map(Number)
    const ready = new Date()
    ready.setHours(hours, minutes, 0, 0)

    const steps = this.plan()
    const total = steps.reduce((sum, step) => Math.max(sum, step.consumes ? step.start + step.planned : 0), 0)
    const base = ready.getTime() - total * MINUTE

    let parentLabel = null
    for (const step of steps) {
      let label
      if (step.kind === 'alongside') {
        label = parentLabel
      } else {
        const at = new Date(base + step.start * MINUTE)
        if (step.kind === 'minimum' && this.beforeDawn(at, ready)) {
          label = 'Night before'
        } else if (step.kind === 'hold') {
          const end = new Date(at.getTime() + step.planned * MINUTE)
          const from = this.clock(new Date(end.getTime() - step.minutes * MINUTE))
          const to = this.clock(end)
          const suffix = to.match(/\s?[AP]M$/i)?.[0]
          label = `${suffix && from.endsWith(suffix) ? from.slice(0, -suffix.length) : from}–${to}`
        } else {
          label = this.clock(at)
        }
        if (step.consumes) parentLabel = label
      }
      this.label(step.element, label)
    }

    const first = steps[0] && this.labelOf(steps[0].element)
    const firstClock = steps.map((step) => this.labelOf(step.element)).find((label) => label && label !== 'Night before')
    this.summaryTarget.textContent = first === 'Night before' ? `Start the night before, then at ${firstClock}` : `Start at ${first}`
  }

  // Minutes from the first step, for each step in the directions
  plan() {
    const steps = []
    let elapsed = 0
    let lastStart = 0
    for (const element of this.element.querySelectorAll('.lexxy-content > ol:first-of-type > li')) {
      const opening = [...element.childNodes].find((node) =>
        node.nodeType === Node.ELEMENT_NODE ? !node.classList.contains('step-time') : node.textContent.trim()
      )
      const parsed = opening?.nodeName === 'CODE' && this.parse(opening.textContent)
      if (!parsed) {
        steps.push({ element, kind: 'alongside' })
      } else if (parsed.kind === 'offset') {
        steps.push({ element, kind: 'offset', start: lastStart + parsed.minutes })
      } else {
        const planned = parsed.kind === 'hold' ? parsed.minutes / 2 : parsed.minutes
        steps.push({ element, ...parsed, start: elapsed, planned, consumes: true })
        lastStart = elapsed
        elapsed += planned
      }
    }
    return steps
  }

  parse(text) {
    let source = text.trim()
    let kind = 'duration'
    if (source.startsWith('+')) { kind = 'offset'; source = source.slice(1) }
    else if (/^(≤|<=)/.test(source)) { kind = 'hold'; source = source.replace(/^(≤|<=)/, '') }
    else if (source.endsWith('+')) { kind = 'minimum'; source = source.slice(0, -1) }
    source = source.replace(/^~/, '')

    let minutes = 0
    let matched = false
    for (const [, whole, fraction, unit] of source.matchAll(/(\d+(?:\.\d+)?)?\s*([½¼¾⅓⅔])?\s*(h|hrs?|hours?|m|mins?|minutes?)\b/g)) {
      const amount = Number(whole || 0) + (FRACTIONS[fraction] || 0)
      if (!amount) continue
      minutes += unit.startsWith('h') ? amount * 60 : amount
      matched = true
    }
    return matched ? { kind, minutes } : null
  }

  beforeDawn(at, ready) {
    return at.toDateString() !== ready.toDateString() || at.getHours() < 7
  }

  clock(date) {
    return date.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })
  }

  label(element, text) {
    let label = element.querySelector(':scope > .step-time')
    if (!label) {
      label = document.createElement('span')
      label.className = 'step-time'
      element.prepend(label)
    }
    label.textContent = text || ''
  }

  labelOf(element) {
    return element.querySelector(':scope > .step-time')?.textContent
  }
}
