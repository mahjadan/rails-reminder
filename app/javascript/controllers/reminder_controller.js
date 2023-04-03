import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "repeatFrequency" ]
  connect() {
  }
  showRepeatFrequency() {
    // stimulus create this variable 'this.repeatTarget' automatically from targets list
    const element = this.repeatFrequencyTarget
    element.classList.toggle('d-none')
  }
}
