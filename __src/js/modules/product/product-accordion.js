export const productAccordion = () => {
  const items = document.querySelectorAll(".js-accordion-item");
  if (!items.length) return;

  const controllers = new Map();

  items.forEach((item) => {
    const toggle = item.querySelector(".js-accordion-toggle");
    const content = item.querySelector(".js-accordion-content");
    if (!toggle || !content) return;

    const setState = (isOpen) => {
      item.dataset.state = isOpen ? "open" : "closed";
      toggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
      content.hidden = !isOpen;

      const icon = item.querySelector(".js-accordion-icon");
      if (icon) {
        const newIcon = document.createElement("i");
        newIcon.setAttribute("data-lucide", isOpen ? "minus" : "plus");
        newIcon.className = icon.className;
        icon.replaceWith(newIcon);
        if (typeof lucide !== "undefined") lucide.createIcons();
      }
    };

    toggle.addEventListener("click", () => setState(item.dataset.state !== "open"));
    controllers.set(item, setState);
  });

  const sizeGuideLink = document.querySelector('a[href="#tabela-de-medidas"]');
  const sizeGuideItem = document.getElementById("tabela-de-medidas");
  const openSizeGuide = sizeGuideItem && controllers.get(sizeGuideItem);

  if (sizeGuideLink && openSizeGuide) {
    sizeGuideLink.addEventListener("click", (e) => {
      e.preventDefault();
      openSizeGuide(true);
      sizeGuideItem.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  }
};
