// Kleer Lab — contact modal. Vanilla replacement for the old Stimulus
// modal_controller.js (no Stimulus/Turbo in website17).
(function () {
  "use strict";

  var FOCUSABLE = [
    'a[href]', 'button:not([disabled])', 'input:not([disabled])',
    'textarea:not([disabled])', 'select:not([disabled])', 'iframe',
    '[tabindex]:not([tabindex="-1"])'
  ].join(",");

  var lastFocused = null;

  // GTM lives in the layout; this only pushes. If the container is blocked or
  // absent the array still exists and nothing here breaks.
  function track(event, params) {
    window.dataLayer = window.dataLayer || [];
    var payload = { event: "lab_" + event };
    if (params) {
      Object.keys(params).forEach(function (k) { payload[k] = params[k]; });
    }
    window.dataLayer.push(payload);
  }

  function panel() {
    return document.getElementById("lab-contact-modal");
  }

  function isOpen() {
    var el = panel();
    return !!el && !el.classList.contains("hidden");
  }

  function focusables() {
    var el = panel();
    if (!el) return [];
    return Array.prototype.filter.call(el.querySelectorAll(FOCUSABLE), function (node) {
      return node.offsetWidth > 0 || node.offsetHeight > 0 || node === document.activeElement;
    });
  }

  function open() {
    var el = panel();
    // /contacto renders the form inline and omits the modal: send the CTA there.
    if (!el) {
      var inline = document.getElementById("lab-contact-form");
      if (inline) {
        inline.scrollIntoView({ block: "start" });
        var field = inline.querySelector("input, textarea");
        if (field) field.focus({ preventScroll: true });
      }
      return;
    }
    if (isOpen()) return;
    lastFocused = document.activeElement;
    track("formulario_abierto");
    el.classList.remove("hidden");
    document.body.style.overflow = "hidden";
    // Land on the first field rather than the close button.
    var first = el.querySelector("input, textarea") || focusables()[0];
    if (first) first.focus();
  }

  function close() {
    var el = panel();
    if (!el || !isOpen()) return;
    el.classList.add("hidden");
    document.body.style.overflow = "";
    // Return focus to whatever opened the modal.
    if (lastFocused && typeof lastFocused.focus === "function") lastFocused.focus();
    lastFocused = null;
  }

  // Keep Tab inside the dialog while it is open.
  function trap(event) {
    var items = focusables();
    if (items.length === 0) return;
    var first = items[0];
    var last = items[items.length - 1];

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    } else if (!panel().contains(document.activeElement)) {
      event.preventDefault();
      first.focus();
    }
  }

  document.addEventListener("click", function (event) {
    var tracked = event.target.closest("[data-lab-track]");
    if (tracked) {
      var name = tracked.getAttribute("data-lab-track");
      track(name, name === "caso" ? { lab_caso: tracked.getAttribute("data-lab-case") } : null);
    }

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

  // Page-load events, marked in the view: /contacto/gracias is the conversion.
  document.querySelectorAll("[data-lab-event]").forEach(function (el) {
    track(el.getAttribute("data-lab-event"));
  });

  document.addEventListener("keydown", function (event) {
    if (!isOpen()) return;
    if (event.key === "Escape") close();
    else if (event.key === "Tab") trap(event);
  });
})();
