import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "repeatFrequency" ]
  connect() {
  }
  // TODO:NOT USED YOU CAN REMOVE IT OR USE IT FOR SOMETHING ELSE.
  showRepeatFrequency() {
    // stimulus create this variable 'this.repeatTarget' automatically from targets list
    const element = this.repeatFrequencyTarget
    element.classList.toggle('d-none')
  }
}
