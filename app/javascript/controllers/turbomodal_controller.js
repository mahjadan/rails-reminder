import { Controller } from "@hotwired/stimulus";
import * as bootstrap from "bootstrap";

// Connects to data-controller="turbomodal"
export default class extends Controller {
  connect() {
    console.log('turbomodal controller connected');
    this.modal = new bootstrap.Modal(this.element)
  }

  open() {
    if (!this.modal.isOpened) {
      this.modal.show()
    }
  }

  close(event) {
    if (event.detail.success) {
      this.modal.hide()
    }
  }
}
