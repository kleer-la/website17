(function() {
  'use strict';

  var state = {
    selectedConsultantId: null,
    selectedConsultantName: null,
    selectedSlot: null,
    currentWeekStart: null,
    availabilityData: null,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'America/Argentina/Buenos_Aires'
  };

  function init() {
    document.getElementById('visitor-timezone').textContent = state.timezone;
    state.currentWeekStart = getNextMonday(new Date());

    bindConsultantCards();
    bindWeekNavigation();
  }

  function getNextMonday(date) {
    var d = new Date(date);
    var day = d.getDay();
    // If today is weekday (Mon-Fri) and before 18:00, start from today's week
    // Otherwise start from next Monday
    if (day === 0) {
      d.setDate(d.getDate() + 1);
    } else if (day === 6) {
      d.setDate(d.getDate() + 2);
    } else {
      // Go back to Monday of current week
      d.setDate(d.getDate() - (day - 1));
    }
    d.setHours(0, 0, 0, 0);
    return d;
  }

  function bindConsultantCards() {
    var cards = document.querySelectorAll('.booking-consultant-card');
    cards.forEach(function(card) {
      card.addEventListener('click', function() {
        // Deselect all
        cards.forEach(function(c) { c.classList.remove('booking-consultant-card--selected'); });
        // Select this one
        card.classList.add('booking-consultant-card--selected');

        state.selectedConsultantId = card.dataset.consultantId;
        state.selectedConsultantName = card.dataset.consultantName;
        state.selectedSlot = null;

        document.getElementById('step-calendar').style.display = '';
        document.getElementById('step-form').style.display = 'none';

        loadAvailability();

        // Scroll to calendar
        document.getElementById('step-calendar').scrollIntoView({ behavior: 'smooth' });
      });
    });
  }

  function bindWeekNavigation() {
    document.getElementById('prev-week').addEventListener('click', function() {
      state.currentWeekStart.setDate(state.currentWeekStart.getDate() - 7);
      updateWeekNavigation();
      loadAvailability();
    });

    document.getElementById('next-week').addEventListener('click', function() {
      state.currentWeekStart.setDate(state.currentWeekStart.getDate() + 7);
      updateWeekNavigation();
      loadAvailability();
    });
  }

  function updateWeekNavigation() {
    var today = new Date();
    today.setHours(0, 0, 0, 0);
    var thisMonday = getNextMonday(today);

    // Disable prev if we're on current week
    document.getElementById('prev-week').disabled =
      state.currentWeekStart.getTime() <= thisMonday.getTime();

    // Disable next if we're 2 weeks ahead (14 day limit)
    var maxWeekStart = new Date(thisMonday);
    maxWeekStart.setDate(maxWeekStart.getDate() + 7);
    document.getElementById('next-week').disabled =
      state.currentWeekStart.getTime() >= maxWeekStart.getTime();
  }

  function formatWeekLabel(weekStart) {
    var weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 4); // Friday

    var opts = { month: 'short', day: 'numeric' };
    var locale = BOOKING_CONFIG.locale === 'es' ? 'es-AR' : 'en-US';
    return weekStart.toLocaleDateString(locale, opts) + ' - ' + weekEnd.toLocaleDateString(locale, opts);
  }

  function loadAvailability() {
    if (!state.selectedConsultantId) return;

    var loading = document.getElementById('calendar-loading');
    var grid = document.getElementById('calendar-grid');
    loading.style.display = '';
    grid.innerHTML = '';

    var startDate = state.currentWeekStart.toISOString();
    var endDate = new Date(state.currentWeekStart);
    endDate.setDate(endDate.getDate() + 5); // Monday to Friday
    var endDateStr = endDate.toISOString();

    var url = BOOKING_CONFIG.availabilityUrl + '/' + state.selectedConsultantId +
      '?start=' + encodeURIComponent(startDate) +
      '&end=' + encodeURIComponent(endDateStr) +
      '&timezone=' + encodeURIComponent(state.timezone);

    document.getElementById('calendar-week-label').textContent = formatWeekLabel(state.currentWeekStart);
    updateWeekNavigation();

    fetch(url)
      .then(function(response) {
        if (!response.ok) throw new Error('Failed to fetch availability');
        return response.json();
      })
      .then(function(data) {
        loading.style.display = 'none';
        state.availabilityData = data;
        renderCalendarGrid(data);
      })
      .catch(function(err) {
        loading.style.display = 'none';
        grid.innerHTML = '<div class="alert alert-warning">' + BOOKING_CONFIG.i18n.noAvailability + '</div>';
      });
  }

  function renderCalendarGrid(data) {
    var grid = document.getElementById('calendar-grid');
    grid.innerHTML = '';

    var slots = data.available_slots || [];
    if (slots.length === 0) {
      grid.innerHTML = '<div class="alert alert-info">' + BOOKING_CONFIG.i18n.noAvailability + '</div>';
      return;
    }

    // Group slots by day
    var slotsByDay = {};
    var dayNames = BOOKING_CONFIG.locale === 'es'
      ? ['Lun', 'Mar', 'Mié', 'Jue', 'Vie']
      : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    slots.forEach(function(slot) {
      var date = new Date(slot.start);
      var dateKey = date.toISOString().split('T')[0];
      if (!slotsByDay[dateKey]) {
        slotsByDay[dateKey] = [];
      }
      slotsByDay[dateKey].push(slot);
    });

    // Create columns for each weekday
    var table = document.createElement('div');
    table.className = 'booking-calendar__table';

    for (var i = 0; i < 5; i++) {
      var dayDate = new Date(state.currentWeekStart);
      dayDate.setDate(dayDate.getDate() + i);
      var dateKey = dayDate.toISOString().split('T')[0];

      var column = document.createElement('div');
      column.className = 'booking-calendar__day';

      var header = document.createElement('div');
      header.className = 'booking-calendar__day-header';
      header.innerHTML = '<strong>' + dayNames[i] + '</strong><br>' + dayDate.getDate();
      column.appendChild(header);

      var daySlots = slotsByDay[dateKey] || [];
      if (daySlots.length === 0) {
        var empty = document.createElement('div');
        empty.className = 'booking-calendar__no-slots';
        empty.textContent = '-';
        column.appendChild(empty);
      } else {
        daySlots.forEach(function(slot) {
          var btn = document.createElement('button');
          btn.type = 'button';
          btn.className = 'booking-calendar__slot';
          var slotTime = new Date(slot.start);
          btn.textContent = slotTime.toLocaleTimeString(
            BOOKING_CONFIG.locale === 'es' ? 'es-AR' : 'en-US',
            { hour: '2-digit', minute: '2-digit', hour12: false }
          );
          btn.dataset.start = slot.start;
          btn.dataset.end = slot.end;
          btn.addEventListener('click', function() {
            selectSlot(this, slot);
          });
          column.appendChild(btn);
        });
      }

      table.appendChild(column);
    }

    grid.appendChild(table);
  }

  function selectSlot(button, slot) {
    // Deselect all slots
    document.querySelectorAll('.booking-calendar__slot').forEach(function(s) {
      s.classList.remove('booking-calendar__slot--selected');
    });
    button.classList.add('booking-calendar__slot--selected');

    state.selectedSlot = slot;

    // Update form hidden fields
    document.getElementById('input-consultant-id').value = state.selectedConsultantId;
    document.getElementById('input-starts-at').value = slot.start;
    document.getElementById('input-ends-at').value = slot.end;

    // Update display
    var slotDate = new Date(slot.start);
    var locale = BOOKING_CONFIG.locale === 'es' ? 'es-AR' : 'en-US';
    var dateStr = slotDate.toLocaleDateString(locale, {
      weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
    });
    var timeStr = slotDate.toLocaleTimeString(locale, {
      hour: '2-digit', minute: '2-digit', hour12: false
    });

    document.getElementById('selected-consultant-name').textContent = state.selectedConsultantName;
    document.getElementById('selected-slot-display').textContent =
      dateStr + ' - ' + timeStr + ' (' + BOOKING_CONFIG.i18n.duration + ')';

    // Show form step
    document.getElementById('step-form').style.display = '';

    // Load reCAPTCHA for the booking form
    if (typeof loadReCaptcha === 'function') {
      loadReCaptcha('booking-form');
    }

    // Scroll to form
    document.getElementById('step-form').scrollIntoView({ behavior: 'smooth' });
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
