import { Controller } from "@hotwired/stimulus"

// Muestra cuántos caracteres quedan en un campo con maxlength.
//
//   <div data-controller="char-counter">
//     <textarea maxlength="1000" data-char-counter-target="input" data-action="input->char-counter#update"></textarea>
//     <span data-char-counter-target="output"></span>
//   </div>
export default class extends Controller {
  static targets = ["input", "output"]

  connect() {
    this.update()
  }

  update() {
    const max = Number(this.inputTarget.maxLength)
    const left = max - this.inputTarget.value.length
    this.outputTarget.textContent = `${left} de ${max} caracteres disponibles`
    this.outputTarget.classList.toggle("text-danger", left < 50)
  }
}
