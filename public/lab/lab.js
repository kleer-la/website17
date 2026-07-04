// Kleer Lab — contact modal. Vanilla replacement for the old Stimulus
// modal_controller.js (no Stimulus/Turbo in website17).
(function () {
  "use strict";

  function panel() {
    return document.getElementById("lab-contact-modal");
  }

  function open() {
    var el = panel();
    if (!el) return;
    el.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  function close() {
    var el = panel();
    if (!el) return;
    el.classList.add("hidden");
    document.body.style.overflow = "";
  }

  document.addEventListener("click", function (event) {
    var trigger = event.target.closest("[data-lab-modal]");
    if (trigger) {
      var action = trigger.getAttribute("data-lab-modal");
      if (action === "open") {
        event.preventDefault();
        open();
      } else if (action === "close") {
        event.preventDefault();
        close();
      }
      return;
    }
    // Click on the backdrop (the panel root itself, not its children) closes.
    if (event.target === panel()) close();
  });

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") close();
  });
})();
