export const productVariants = () => {
  const container = document.querySelector(".js-product-variants");
  if (!container) return;

  const dataScript = container.querySelector(".js-product-variants-data");
  if (!dataScript) return;

  let variants;
  try {
    variants = JSON.parse(dataScript.textContent);
  } catch (e) {
    return;
  }

  const groups = Array.from(container.querySelectorAll(".js-product-variant-group"));
  const priceDisplay = document.querySelector(".js-price-display");
  const comparePriceDisplay = document.querySelector(".js-compare-price-display");

  // A pill selecionada tem fundo (token bg-control) e as nao selecionadas sao
  // transparentes. O swatch de cor tem seu proprio estado (outline via CSS).
  function applySelectedStyle(option, selected) {
    if (option.classList.contains("js-product-variant-swatch")) return;
    option.classList.toggle("bg-control", selected);
  }

  function selectOption(option) {
    const group = option.closest(".js-product-variant-group");
    if (!group) return;

    group.querySelectorAll(".js-product-variant-option").forEach(function (opt) {
      opt.removeAttribute("data-selected");
      applySelectedStyle(opt, false);
    });
    option.setAttribute("data-selected", "true");
    applySelectedStyle(option, true);
  }

  function getSelectedOptionNames() {
    return groups.map(function (group) {
      const selected = group.querySelector('[data-selected="true"]');
      return selected ? selected.dataset.optionName : null;
    });
  }

  function findMatchingVariant(optionNames) {
    return variants.find(function (v) {
      return optionNames.every(function (name, index) {
        return name === null || v["option" + index] === name;
      });
    });
  }

  function updatePrice() {
    const variant = findMatchingVariant(getSelectedOptionNames());
    if (!variant) return;

    if (priceDisplay) {
      priceDisplay.textContent = variant.price_short;
      priceDisplay.style.display = "";
    }

    if (comparePriceDisplay) {
      const line = comparePriceDisplay.querySelector("span");
      comparePriceDisplay.textContent = variant.compare_at_price_short || "";
      if (line) comparePriceDisplay.appendChild(line);
      comparePriceDisplay.style.display = variant.compare_at_price_short ? "inline-block" : "none";
    }

    if (variant.image !== undefined && variant.image !== null) {
      window.setProductGalleryImage?.(variant.image);
    }
  }

  function updateStockStatus() {
    groups.forEach(function (group, groupIndex) {
      const options = Array.from(group.querySelectorAll(".js-product-variant-option"));
      let firstAvailable = null;

      options.forEach(function (option) {
        const optionName = option.dataset.optionName;
        const available = variants.some(function (v) {
          return v["option" + groupIndex] === optionName && v.available;
        });

        if (available) {
          option.classList.remove("opacity-40", "pointer-events-none", "line-through");
          if (!firstAvailable) firstAvailable = option;
        } else {
          option.classList.add("opacity-40", "pointer-events-none", "line-through");
          if (option.dataset.selected) applySelectedStyle(option, false);
          option.removeAttribute("data-selected");
        }
      });

      const hasSelected = options.some(function (option) {
        return option.hasAttribute("data-selected");
      });

      if (!hasSelected && firstAvailable) {
        selectOption(firstAvailable);
      }
    });
  }

  container.addEventListener("click", function (e) {
    const option = e.target.closest(".js-product-variant-option");
    if (!option || option.classList.contains("pointer-events-none")) return;

    selectOption(option);
    updatePrice();
  });

  updateStockStatus();
  updatePrice();
};
