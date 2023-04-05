import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbomodal"
export default class extends Controller {
  connect() {
        console.log('modal controller connected');
  }

  submitEnd(event) {
    console.log(event);
    console.log(event.detail.success);
    if (event.detail.success) {
      this.hideModal()
    }
  }

  hideModal(event) {
    this.element.remove()
  }
}
