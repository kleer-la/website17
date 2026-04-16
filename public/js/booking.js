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

  // Schedule button toggle
  var btnSchedule = document.getElementById('btn-schedule');
  var consultantPanel = document.getElementById('consultant-panel');

  if (btnSchedule && consultantPanel) {
    btnSchedule.addEventListener('click', function () {
      consultantPanel.style.display = 'block';
      btnSchedule.disabled = true;
      loadAllAvailability();
    });
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
  var start = new Date().toISOString().split('T')[0];
  var endDate = new Date();
  endDate.setDate(endDate.getDate() + 14);
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

  fetch(url)
    .then(function (response) {
      if (!response.ok) throw new Error('Failed to load availability');
      return response.json();
    })
    .then(function (slots) {
      renderSlots(slotsContainer, slots, consultantId);
    })
    .catch(function () {
      slotsContainer.innerHTML = '<p class="text-muted small">Could not load availability.</p>';
    });
}

function renderSlots(container, slots, consultantId) {
  if (!slots || slots.length === 0) {
    container.innerHTML = '<p class="text-muted small">No available slots in the next 2 weeks.</p>';
    return;
  }

  var html = '<div class="d-flex flex-wrap gap-2">';
  slots.forEach(function (slot) {
    var date = new Date(slot.start_time);
    var label = date.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' }) +
      ' ' + date.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });

    html += '<button type="button" class="btn btn-outline-primary btn-sm slot-btn" ' +
      'data-consultant-id="' + consultantId + '" ' +
      'data-start-time="' + slot.start_time + '" ' +
      'onclick="selectSlot(this)">' +
      label + '</button>';
  });
  html += '</div>';

  container.innerHTML = html;
}

function selectSlot(btn) {
  // Deselect all
  document.querySelectorAll('.slot-btn.active').forEach(function (el) {
    el.classList.remove('active');
  });

  // Select this one
  btn.classList.add('active');

  // Show confirm button if not present
  var panel = document.getElementById('consultant-panel');
  var existing = document.getElementById('confirm-booking-btn');
  if (!existing) {
    var confirmBtn = document.createElement('button');
    confirmBtn.id = 'confirm-booking-btn';
    confirmBtn.className = 'btn btn-success mt-3';
    confirmBtn.textContent = BOOKING_CONFIG.confirmText;
    confirmBtn.onclick = function () { confirmBooking(btn); };
    panel.appendChild(confirmBtn);
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
  formData.append('timezone', timezone);
  formData.append('service_area_id', BOOKING_CONFIG.serviceAreaId);
  formData.append('visitor_name', '');
  formData.append('visitor_email', '');

  fetch('/' + BOOKING_CONFIG.locale + '/book-meeting', {
    method: 'POST',
    body: formData
  })
    .then(function (response) {
      if (!response.ok) throw new Error('Booking failed');
      return response.json();
    })
    .then(function () {
      confirmBtn.textContent = BOOKING_CONFIG.confirmedText;
      confirmBtn.classList.remove('btn-success');
      confirmBtn.classList.add('btn-outline-success');
      // Disable all slot buttons
      document.querySelectorAll('.slot-btn').forEach(function (el) {
        el.disabled = true;
      });
    })
    .catch(function () {
      confirmBtn.disabled = false;
      confirmBtn.textContent = BOOKING_CONFIG.confirmText;
      confirmBtn.classList.add('btn-danger');
    });
}
