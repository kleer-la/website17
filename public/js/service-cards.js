function initializeServiceCard(id, hoverColor, borderHoverColor, borderColor) {
  const areaCard = document.getElementById(`service-card-${id}`);
  areaCard.addEventListener('mouseover', function() {
      areaCard.style.backgroundColor = hoverColor;
      areaCard.style.border = `3px solid ${borderHoverColor}`;
  });

  areaCard.addEventListener('mouseout', function() {
      areaCard.style.backgroundColor = 'white';
      areaCard.style.border = `3px solid ${borderColor}`;
  });

  areaCard.onclick = function(e) {
      e.stopPropagation();
  };
}

document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.service-card').forEach(card => {
      initializeServiceCard(
          card.id.split('-').pop(),
          card.dataset.hoverColor,
          card.dataset.borderHoverColor,
          card.dataset.borderColor
      );
  });
});
