export const categoryFilters = () => {
  const triggers = document.querySelectorAll(".js-category-filter-trigger");
  if (!triggers.length) return;

  const filterContent = document.querySelector(".js-category-filter-content");
  if (filterContent) {
    filterContent.querySelectorAll(".filter-input-price-container").forEach((container, i) => {
      const label = container.querySelector("label");
      const input = container.querySelector("input");
      if (label && input && !label.getAttribute("for") && !input.id) {
        const id = "price-filter-" + i;
        input.id = id;
        label.setAttribute("for", id);
      }
    });
  }

  const mobileQuery = window.matchMedia("(max-width: 767px)");

  triggers.forEach((trigger) => {
    trigger.addEventListener("click", () => {
      const title = trigger.dataset.filterTitle || "Filtros";
      const isMobile = mobileQuery.matches;

      window.openModal?.({
        title,
        contentSelector: ".js-category-filter-content",
        mode: isMobile ? "drawer" : "modal",
        size: isMobile ? undefined : "lg",
      });
    });
  });
};
