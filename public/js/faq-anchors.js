// A link to one FAQ question (#que-es-kanban-y-para-que-sirve) opens it.
// The browser does the jump itself — a real hash navigation, so Back returns
// to where the link was clicked; this only opens the accordion entry, on load
// and on every hash change, and brings it back into view once it has opened
// (opening it may close another one above and move it).
(function () {
  function openLinkedQuestion() {
    var id = decodeURIComponent(window.location.hash.slice(1));
    if (!id) return;
    var item = document.getElementById(id);
    if (!item || !item.classList.contains('accordion-item') || !window.bootstrap) return;

    var panel = item.querySelector('.accordion-collapse');
    if (!panel || panel.classList.contains('show')) return;

    panel.addEventListener('shown.bs.collapse', function () {
      item.scrollIntoView({ block: 'start' });
    }, { once: true });
    window.bootstrap.Collapse.getOrCreateInstance(panel, { toggle: false }).show();
  }

  document.addEventListener('DOMContentLoaded', openLinkedQuestion);
  window.addEventListener('hashchange', openLinkedQuestion);
})();
