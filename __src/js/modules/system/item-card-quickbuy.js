export const itemCardQuickbuy = () => {
  const container = document.querySelector(".js-quickbuy-container");
  if (!container) return;

  var currentOpen = null;

  function openDropdown(dropdown) {
    var trigger = dropdown.querySelector(".js-quickbuy-dropdown-trigger");
    var list = dropdown.querySelector(".js-quickbuy-dropdown-list");
    var icon = dropdown.querySelector(".js-quickbuy-dropdown-icon");
    if (!trigger || !list) return;

    list.hidden = false;
    trigger.setAttribute("aria-expanded", "true");
    if (icon) icon.style.transform = "rotate(180deg)";

    // Size pill container to fit first 3 pills in one row
    var pills = list.querySelectorAll(".js-quickbuy-pill");
    if (pills.length > 0) {
      var count = Math.min(pills.length, 3);
      var totalWidth = 0;
      for (var i = 0; i < count; i++) {
        totalWidth += pills[i].offsetWidth;
      }
      // Add gaps (8px each) + container padding (16px)
      var gap = 8 * (count - 1);
      var padding = 16;
      list.style.width = (totalWidth + gap + padding) + "px";
    }

    currentOpen = dropdown;
  }

  function closeDropdown(dropdown) {
    var trigger = dropdown.querySelector(".js-quickbuy-dropdown-trigger");
    var list = dropdown.querySelector(".js-quickbuy-dropdown-list");
    var icon = dropdown.querySelector(".js-quickbuy-dropdown-icon");
    if (!trigger || !list) return;

    list.hidden = true;
    trigger.setAttribute("aria-expanded", "false");
    if (icon) icon.style.transform = "";
    if (currentOpen === dropdown) currentOpen = null;
  }

  function closeCurrent() {
    if (currentOpen) closeDropdown(currentOpen);
  }

  document.addEventListener("click", function (e) {
    var trigger = e.target.closest(".js-quickbuy-dropdown-trigger");
    if (trigger) {
      var dropdown = trigger.closest(".js-quickbuy-dropdown");
      if (!dropdown) return;

      if (currentOpen && currentOpen !== dropdown) {
        closeCurrent();
      }

      var list = dropdown.querySelector(".js-quickbuy-dropdown-list");
      if (list && list.hidden) {
        openDropdown(dropdown);
      } else {
        closeDropdown(dropdown);
      }
      return;
    }

    var option = e.target.closest(".js-quickbuy-dropdown-option");
    if (option) {
      var dropdown = option.closest(".js-quickbuy-dropdown");
      if (!dropdown) return;

      var label = dropdown.querySelector(".js-quickbuy-dropdown-label");
      if (label) {
        label.textContent = option.dataset.optionName || option.textContent.trim();
      }

      var allOptions = dropdown.querySelectorAll(".js-quickbuy-dropdown-option");
      allOptions.forEach(function (opt) {
        opt.removeAttribute("data-selected");
      });
      option.setAttribute("data-selected", "true");

      closeDropdown(dropdown);
      return;
    }

    var pill = e.target.closest(".js-quickbuy-pill");
    if (pill) {
      var dropdown = pill.closest(".js-quickbuy-dropdown");
      if (!dropdown) return;

      dropdown.querySelectorAll(".js-quickbuy-pill").forEach(function (p) {
        p.removeAttribute("data-selected");
        p.style.background = "rgba(0,0,0,0.05)";
      });
      pill.setAttribute("data-selected", "true");
      pill.style.background = "rgba(0,0,0,0.15)";

      var label = dropdown.querySelector(".js-quickbuy-dropdown-label");
      if (label) {
        label.textContent = pill.dataset.optionName || pill.textContent.trim();
      }

      closeDropdown(dropdown);
      return;
    }

    var addBtn = e.target.closest(".js-quickbuy-add-btn");
    if (addBtn) {
      var card = addBtn.closest("[data-product-id]");
      if (!card) return;

      var productName = card.dataset.productName || "";
      var productPrice = card.dataset.productPrice || "";
      var productImage = card.dataset.productImage || "";

      // Collect selected variation option names
      var selectedOptions = [];
      var qbContainer = addBtn.closest(".js-quickbuy-container");
      if (qbContainer) {
        qbContainer.querySelectorAll(".js-quickbuy-dropdown").forEach(function (dropdown) {
          var selected = dropdown.querySelector("[data-selected='true']");
          if (selected) {
            var value = selected.dataset.optionName || selected.textContent.trim();
            if (value) selectedOptions.push(value);
          }
        });
      }

      // Build FormData for add-to-cart
      var productId = card.dataset.productId;
      var cartUrl = document.body.dataset.cartUrl;
      if (!productId || !cartUrl) return;

      var formData = new FormData();
      formData.append("add_to_cart", productId);
      formData.append("quantity", "1");

      // Add variation selections (variation[variationId] = optionId)
      if (qbContainer) {
        qbContainer.querySelectorAll(".js-quickbuy-dropdown").forEach(function (dropdown) {
          var variationId = dropdown.dataset.variationId;
          var selected = dropdown.querySelector("[data-selected='true']");
          if (variationId && selected && selected.dataset.optionId) {
            formData.append("variation[" + variationId + "]", selected.dataset.optionId);
          }
        });
      }

      // Disable button during request
      addBtn.style.pointerEvents = "none";
      addBtn.style.opacity = "0.5";

      // Add to cart via Nuvemshop cart endpoint
      fetch(cartUrl, {
        method: "POST",
        body: formData,
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then(function (res) {
          if (!res.ok) throw new Error("Add to cart failed");
          window.showProductToast?.({
            image: productImage,
            name: productName,
            price: productPrice,
            quantity: 1,
            variation: selectedOptions.length > 0 ? selectedOptions.join(" / ") : null,
          });
          window.onCartUpdate?.();
        })
        .catch(function (err) {
          console.error("Quickbuy add to cart error:", err);
        })
        .finally(function () {
          addBtn.style.pointerEvents = "";
          addBtn.style.opacity = "";
        });

      return;
    }

    if (currentOpen && !e.target.closest(".js-quickbuy-dropdown")) {
      closeCurrent();
    }
  });

  // Mark out-of-stock options as inactive
  function updateStockStatus(card) {
    var script = card.querySelector(".js-quickbuy-variants-data");
    if (!script) return;

    var variants;
    try {
      variants = JSON.parse(script.textContent);
    } catch (e) {
      return;
    }

    var containers = card.querySelectorAll(".js-quickbuy-container");
    containers.forEach(function (qbContainer) {
      var dropdowns = qbContainer.querySelectorAll(".js-quickbuy-dropdown");
      dropdowns.forEach(function (dropdown, variationIndex) {
        var optionKey = "option" + variationIndex;

      var label = dropdown.querySelector(".js-quickbuy-dropdown-label");
      var icon = dropdown.querySelector(".js-quickbuy-dropdown-icon");
      var trigger = dropdown.querySelector(".js-quickbuy-dropdown-trigger");
      var firstAvailable = null;

      // Build stock map for this variation
      var allItems = dropdown.querySelectorAll(".js-quickbuy-dropdown-option, .js-quickbuy-pill");
      var stockMap = {};
      allItems.forEach(function (el) {
        var optionName = (el.dataset.optionName || el.textContent.trim());
        if (stockMap[optionName] === undefined) {
          stockMap[optionName] = variants.some(function (v) {
            return v[optionKey] === optionName && v.available;
          });
        }
        if (stockMap[optionName] && !firstAvailable) {
          firstAvailable = optionName;
        }
      });

      // Desktop options
      dropdown.querySelectorAll(".js-quickbuy-dropdown-option").forEach(function (opt) {
        var optionName = (opt.dataset.optionName || opt.textContent.trim());
        if (!stockMap[optionName]) {
          opt.classList.add("opacity-40", "pointer-events-none", "line-through");
          opt.removeAttribute("data-selected");
        }
      });

      // Mobile pills
      dropdown.querySelectorAll(".js-quickbuy-pill").forEach(function (pill) {
        var optionName = (pill.dataset.optionName || pill.textContent.trim());
        if (!stockMap[optionName]) {
          pill.classList.add("opacity-40", "pointer-events-none", "line-through");
          pill.removeAttribute("data-selected");
          pill.style.background = "rgba(0,0,0,0.05)";
        }
      });

      // Select first available or mark as sold out
      if (firstAvailable) {
        var selectedDesktop = false;
        dropdown.querySelectorAll(".js-quickbuy-dropdown-option").forEach(function (opt) {
          var optionName = (opt.dataset.optionName || opt.textContent.trim());
          if (optionName === firstAvailable && !selectedDesktop) {
            opt.setAttribute("data-selected", "true");
            selectedDesktop = true;
          } else {
            opt.removeAttribute("data-selected");
          }
        });

        var selectedMobile = false;
        dropdown.querySelectorAll(".js-quickbuy-pill").forEach(function (pill) {
          var optionName = (pill.dataset.optionName || pill.textContent.trim());
          if (optionName === firstAvailable && !selectedMobile) {
            pill.setAttribute("data-selected", "true");
            pill.style.background = "rgba(0,0,0,0.15)";
            selectedMobile = true;
          } else {
            pill.removeAttribute("data-selected");
            if (!pill.classList.contains("opacity-40")) {
              pill.style.background = "rgba(0,0,0,0.05)";
            }
          }
        });

        if (label) label.textContent = firstAvailable;
      } else {
        // All options sold out
        if (label) label.textContent = "Esgotado";
        if (icon) icon.style.display = "none";
        if (trigger) {
          trigger.classList.add("pointer-events-none", "opacity-40");
        }
      }
      });

      // Hide add button if all variants are sold out
      var allSoldOut = !variants.some(function (v) { return v.available; });
      if (allSoldOut) {
        var addBtn = qbContainer.querySelector(".js-quickbuy-add-btn");
        if (addBtn) addBtn.style.display = "none";
      }
    });
  }

  document.querySelectorAll("[data-product-id]").forEach(updateStockStatus);

  window.initQuickbuyDropdowns = function () {
    document.querySelectorAll("[data-product-id]").forEach(updateStockStatus);
  };
};
