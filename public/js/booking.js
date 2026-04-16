document.addEventListener('DOMContentLoaded', function () {
  // Character counter for situation textarea
  var textarea = document.getElementById('booking-situation');
  var counter = document.getElementById('booking-char-counter');

  if (textarea && counter) {
    var threshold = parseInt(textarea.getAttribute('data-char-threshold') || '50', 10);

    textarea.addEventListener('input', function () {
      var len = textarea.value.length;
      counter.textContent = len + ' / ' + threshold;
      if (len >= threshold) {
        counter.classList.add('text-success');
        counter.classList.remove('text-muted');
      } else {
        counter.classList.remove('text-success');
        counter.classList.add('text-muted');
      }
    });
  }

  // Bootstrap form validation
  var form = document.getElementById('booking-qualify-form');
  if (form) {
    form.addEventListener('submit', function (event) {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
      }
      form.classList.add('was-validated');
    });
  }

  // Auto-load availability when consultants list is present
  var consultantsList = document.getElementById('consultants-list');
  if (consultantsList) {
    loadAllAvailability();
  }

  // Timezone change reloads availability
  var timezoneSelect = document.getElementById('booking-timezone');
  if (timezoneSelect) {
    timezoneSelect.addEventListener('change', function () {
      loadAllAvailability();
    });
  }
});

function loadAllAvailability() {
  if (typeof BOOKING_CONFIG === 'undefined') return;

  var timezone = document.getElementById('booking-timezone').value;
  var startDate = new Date();
  startDate.setDate(startDate.getDate() + 1);
  var start = startDate.toISOString().split('T')[0];
  var endDate = new Date();
  endDate.setDate(endDate.getDate() + 15);
  var end = endDate.toISOString().split('T')[0];

  BOOKING_CONFIG.consultantIds.forEach(function (id) {
    loadConsultantAvailability(id, start, end, timezone);
  });
}

function loadConsultantAvailability(consultantId, start, end, timezone) {
  var card = document.querySelector('[data-consultant-id="' + consultantId + '"]');
  if (!card) return;

  var slotsContainer = card.querySelector('.availability-slots');
  slotsContainer.innerHTML = '<div class="text-center py-3"><div class="spinner-border spinner-border-sm" role="status"><span class="visually-hidden">Loading...</span></div></div>';

  var url = '/' + BOOKING_CONFIG.locale + '/consultant-availability/' + consultantId +
    '?token=' + encodeURIComponent(BOOKING_CONFIG.token) +
    '&area_slug=' + encodeURIComponent(BOOKING_CONFIG.areaSlug) +
    '&start=' + encodeURIComponent(start) +
    '&end=' + encodeURIComponent(end) +
    '&timezone=' + encodeURIComponent(timezone);

  var timeout = new Promise(function (_, reject) {
    setTimeout(function () { reject(new Error('timeout')); }, 10000);
  });

  Promise.race([fetch(url), timeout])
    .then(function (response) {
      if (!response.ok) throw new Error('HTTP ' + response.status);
      return response.json();
    })
    .then(function (data) {
      var slots = data.available_slots || data;
      renderSlots(slotsContainer, slots, consultantId);
    })
    .catch(function (err) {
      var msg = typeof BOOKING_CONFIG !== 'undefined' ? BOOKING_CONFIG.loadErrorText : 'Could not load availability.';
      slotsContainer.innerHTML = '<p class="text-muted small">' + msg + '</p>';
    });
}

var PAGE_SIZE = 8;

function renderSlots(container, slots, consultantId) {
  if (!slots || slots.length === 0) {
    var msg = typeof BOOKING_CONFIG !== 'undefined' ? BOOKING_CONFIG.noSlotsText : 'No available slots.';
    container.innerHTML = '<p class="text-muted small">' + msg + '</p>';
    return;
  }

  container.innerHTML = '';
  container._allSlots = slots;
  container._page = 0;
  container._consultantId = consultantId;
  showSlotsPage(container);
}

function showSlotsPage(container) {
  var slots = container._allSlots;
  var page = container._page;
  var consultantId = container._consultantId;
  var start = page * PAGE_SIZE;
  var end = start + PAGE_SIZE;
  var pageSlots = slots.slice(start, end);

  var wrapper = container.querySelector('.slots-wrapper');
  if (!wrapper) {
    wrapper = document.createElement('div');
    wrapper.className = 'd-flex flex-wrap gap-2 slots-wrapper';
    container.appendChild(wrapper);
  } else {
    wrapper.innerHTML = '';
  }

  pageSlots.forEach(function (slot) {
    var date = new Date(slot.start);
    var label = date.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' }) +
      ' ' + date.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'btn btn-outline-primary btn-sm slot-btn';
    btn.setAttribute('data-consultant-id', consultantId);
    btn.setAttribute('data-start-time', slot.start);
    btn.setAttribute('data-end-time', slot.end);
    btn.textContent = label;
    btn.onclick = function () { selectSlot(btn); };
    wrapper.appendChild(btn);
  });

  // Remove existing nav
  var existingNav = container.querySelector('.slots-nav');
  if (existingNav) existingNav.remove();

  if (slots.length > PAGE_SIZE) {
    var nav = document.createElement('div');
    nav.className = 'slots-nav d-flex justify-content-between align-items-center mt-2';

    var prevBtn = document.createElement('button');
    prevBtn.type = 'button';
    prevBtn.className = 'btn btn-sm btn-outline-secondary';
    prevBtn.textContent = '\u2190';
    prevBtn.disabled = page === 0;
    prevBtn.onclick = function () {
      container._page--;
      showSlotsPage(container);
    };

    var nextBtn = document.createElement('button');
    nextBtn.type = 'button';
    nextBtn.className = 'btn btn-sm btn-outline-secondary';
    nextBtn.textContent = '\u2192';
    nextBtn.disabled = end >= slots.length;
    nextBtn.onclick = function () {
      container._page++;
      showSlotsPage(container);
    };

    var pageInfo = document.createElement('small');
    pageInfo.className = 'text-muted';
    pageInfo.textContent = (start + 1) + '-' + Math.min(end, slots.length) + ' / ' + slots.length;

    nav.appendChild(prevBtn);
    nav.appendChild(pageInfo);
    nav.appendChild(nextBtn);
    container.appendChild(nav);
  }
}

function selectSlot(btn) {
  // Deselect all
  document.querySelectorAll('.slot-btn.active').forEach(function (el) {
    el.classList.remove('active');
  });

  // Select this one
  btn.classList.add('active');

  // Show confirm button below the consultants list
  var container = document.getElementById('consultants-list');
  var existing = document.getElementById('confirm-booking-btn');
  if (!existing) {
    var wrapper = document.createElement('div');
    wrapper.className = 'col-12 text-center mt-2';
    var confirmBtn = document.createElement('button');
    confirmBtn.id = 'confirm-booking-btn';
    confirmBtn.className = 'btn my-primary-button';
    confirmBtn.textContent = BOOKING_CONFIG.confirmText;
    confirmBtn.onclick = function () { confirmBooking(btn); };
    wrapper.appendChild(confirmBtn);
    container.appendChild(wrapper);
  } else {
    existing.onclick = function () { confirmBooking(btn); };
  }
}

function confirmBooking(slotBtn) {
  var confirmBtn = document.getElementById('confirm-booking-btn');
  confirmBtn.disabled = true;
  confirmBtn.textContent = '...';

  var timezone = document.getElementById('booking-timezone').value;

  var formData = new FormData();
  formData.append('booking_token', BOOKING_CONFIG.token);
  formData.append('area_slug', BOOKING_CONFIG.areaSlug);
  formData.append('consultant_id', slotBtn.getAttribute('data-consultant-id'));
  formData.append('start_time', slotBtn.getAttribute('data-start-time'));
  formData.append('end_time', slotBtn.getAttribute('data-end-time'));
  formData.append('timezone', timezone);
  formData.append('visitor_name', BOOKING_CONFIG.visitorName);
  formData.append('visitor_email', BOOKING_CONFIG.visitorEmail);

  fetch('/' + BOOKING_CONFIG.locale + '/book-meeting', {
    method: 'POST',
    body: formData
  })
    .then(function (response) {
      return response.json().then(function (body) {
        if (!response.ok) {
          console.error('Booking failed:', response.status, body);
          throw new Error(body.error || 'Booking failed');
        }
        return body;
      });
    })
    .then(function () {
      confirmBtn.textContent = BOOKING_CONFIG.confirmedText;
      confirmBtn.disabled = true;
      confirmBtn.classList.remove('my-primary-button');
      confirmBtn.classList.add('btn-outline-success');
      document.querySelectorAll('.slot-btn').forEach(function (el) {
        el.disabled = true;
      });
    })
    .catch(function (err) {
      console.error('Booking error:', err);
      confirmBtn.disabled = false;
      confirmBtn.textContent = BOOKING_CONFIG.confirmText;
    });
}
