export const productAddToCart = () => {
  const form = document.querySelector("#product_form");
  if (!form) return;

  const priceDisplay = document.querySelector(".js-price-display");
  const comparePriceDisplay = document.querySelector(".js-compare-price-display");
  const stickyPriceDisplay = document.querySelector(".js-sticky-price-display");
  const stickyComparePriceDisplay = document.querySelector(".js-sticky-compare-price-display");

  const quantityInput = form.querySelector(".js-quantity-input");
  const quantityUp = form.querySelector(".js-quantity-up");
  const buyBtn = form.querySelector(".js-product-sticky-buy-btn");
  const initialBuyState = buyBtn ? buyBtn.dataset.state : null;

  var lastLimitToastAt = 0;

  function syncStickyPrice() {
    if (stickyPriceDisplay && priceDisplay) {
      stickyPriceDisplay.textContent = priceDisplay.textContent;
      stickyPriceDisplay.style.display = priceDisplay.style.display;
    }
    if (stickyComparePriceDisplay && comparePriceDisplay) {
      stickyComparePriceDisplay.innerHTML = comparePriceDisplay.innerHTML;
      stickyComparePriceDisplay.style.display = comparePriceDisplay.style.display;
    }
  }

  if (priceDisplay && (stickyPriceDisplay || stickyComparePriceDisplay)) {
    var observerTarget = comparePriceDisplay ? comparePriceDisplay.parentElement : priceDisplay.parentElement;
    if (observerTarget) {
      var priceObserver = new MutationObserver(syncStickyPrice);
      priceObserver.observe(observerTarget, {
        childList: true,
        characterData: true,
        subtree: true,
        attributes: true,
        attributeFilter: ["style"],
      });
    }
  }

  /* ------------------------------------------------------------------ *
   * Stock data                                                          *
   * ------------------------------------------------------------------ */

  // product.variants_object is serialized twice by the templates: on
  // #single-product[data-variants] (rendered for every product, with or without
  // variations) and inside .js-product-variants-data (only when the product has
  // variations). Read the widest source first — this module must also work for
  // products with a single implicit variant.
  function parseVariants() {
    var raw = null;
    var detail = document.querySelector("#single-product");
    if (detail) raw = detail.getAttribute("data-variants");
    if (!raw) {
      var dataScript = document.querySelector(".js-product-variants-data");
      if (dataScript) raw = dataScript.textContent;
    }
    if (!raw) return [];

    try {
      var parsed = JSON.parse(raw);
      if (Array.isArray(parsed)) return parsed;
      if (parsed && typeof parsed === "object") {
        return Object.keys(parsed).map(function (key) {
          return parsed[key];
        });
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  var variants = parseVariants();

  // Returns the variant matching the current pill selection, or null when the
  // selection is still incomplete (multi-variation products before every group
  // has a pick) — in that case no stock limit can be enforced yet.
  function getSelectedVariant() {
    if (!variants.length) return null;

    var groups = Array.prototype.slice.call(form.querySelectorAll(".js-product-variant-group"));
    if (!groups.length) return variants[0];

    var names = groups.map(function (group) {
      var selected = group.querySelector('[data-selected="true"]');
      return selected ? selected.dataset.optionName : null;
    });

    if (
      names.some(function (name) {
        return name === null || name === undefined;
      })
    ) {
      return null;
    }

    return (
      variants.find(function (variant) {
        return names.every(function (name, index) {
          return variant["option" + index] === name;
        });
      }) || null
    );
  }

  // null = unlimited stock (Nuvemshop serializes unlimited stock as null).
  function getStockLimit() {
    var variant = getSelectedVariant();

    if (variant) {
      if (variant.stock === null || variant.stock === undefined) return null;
      var stock = parseInt(variant.stock, 10);
      return isNaN(stock) ? null : stock;
    }

    var attr = quantityInput ? quantityInput.getAttribute("data-max-stock") : null;
    if (!attr) return null;
    var fallback = parseInt(attr, 10);
    return isNaN(fallback) ? null : fallback;
  }

  /* ------------------------------------------------------------------ *
   * Quantity stepper + stock ceiling                                    *
   * ------------------------------------------------------------------ */

  function notifyStockLimit(limit) {
    if (limit === null || limit < 1) return;

    var now = Date.now();
    if (now - lastLimitToastAt < 1500) return;
    lastLimitToastAt = now;

    var label = quantityUp ? quantityUp.getAttribute("data-stock-limit-label") : null;
    if (!label) return;

    window.showToast?.({ message: label + ": " + limit, icon: "alert-circle" });
  }

  function setAriaDisabled(element, disabled) {
    if (!element) return;
    if (disabled) element.setAttribute("aria-disabled", "true");
    else element.removeAttribute("aria-disabled");
  }

  // `max` is only written when the limit is a usable ceiling. A max lower than
  // the min="1" rendered by the template would make the input fail native
  // constraint validation and silently block the form submit event.
  function applyMaxAttribute(limit) {
    if (!quantityInput) return;
    if (limit === null || limit < 1) quantityInput.removeAttribute("max");
    else quantityInput.setAttribute("max", String(limit));
  }

  // Only the "+" carries a disabled state: the "-" is already inert at 1 and
  // dimming it would change the validated Figma look of the stepper at rest.
  function refreshStepperState(limit, value) {
    setAriaDisabled(quantityUp, limit !== null && value >= Math.max(limit, 1));
  }

  // options.enforceMin — false while the user is typing, so an empty field is
  // not rewritten to "1" mid-edit. options.notify — show a toast when the typed
  // value had to be capped.
  function syncQuantity(options) {
    options = options || {};
    if (!quantityInput) return 1;

    var limit = getStockLimit();
    var value = parseInt(quantityInput.value, 10);
    applyMaxAttribute(limit);

    if (isNaN(value) || value < 1) {
      if (options.enforceMin === false) {
        refreshStepperState(limit, isNaN(value) ? 1 : value);
        return isNaN(value) ? 1 : value;
      }
      value = 1;
    }

    if (limit !== null && limit >= 1 && value > limit) {
      value = limit;
      if (options.notify) notifyStockLimit(limit);
    }

    if (quantityInput.value !== String(value)) quantityInput.value = String(value);
    refreshStepperState(limit, value);
    return value;
  }

  // store.js.tpl:1683-1694 binds its own (unbounded) click handlers on
  // .js-quantity-up/.js-quantity-down. Capturing on the form and stopping
  // propagation keeps the stepper single-sourced here, where the stock ceiling
  // is known. The quickshop stepper in the grid keeps using the legacy handler.
  if (quantityInput) {
    form.addEventListener(
      "click",
      function (e) {
        var up = e.target.closest(".js-quantity-up");
        var down = up ? null : e.target.closest(".js-quantity-down");
        if (!up && !down) return;

        e.preventDefault();
        e.stopPropagation();

        var limit = getStockLimit();
        var value = parseInt(quantityInput.value, 10);
        if (isNaN(value) || value < 1) value = 1;

        if (up) {
          if (limit !== null && value >= Math.max(limit, 1)) {
            notifyStockLimit(limit);
            syncQuantity({ enforceMin: true });
            return;
          }
          value = value + 1;
        } else if (value > 1) {
          value = value - 1;
        }

        quantityInput.value = String(value);
        syncQuantity({ enforceMin: true });
      },
      true
    );

    quantityInput.addEventListener("input", function () {
      syncQuantity({ notify: true, enforceMin: false });
    });

    quantityInput.addEventListener("change", function () {
      syncQuantity({ notify: true, enforceMin: true });
    });
  }

  /* ------------------------------------------------------------------ *
   * Buy button state per selected variant                               *
   * ------------------------------------------------------------------ */

  // Only a server-rendered 'cart' button is ever flipped. 'contact', 'catalog'
  // and a server-rendered 'nostock' keep the behaviour the template defined.
  function refreshBuyButtonState() {
    if (!buyBtn || initialBuyState !== "cart") return;

    var variant = getSelectedVariant();
    if (!variant) return;

    var stock = variant.stock === null || variant.stock === undefined ? null : parseInt(variant.stock, 10);
    var soldOut = variant.available === false || (stock !== null && !isNaN(stock) && stock < 1);

    var text = buyBtn.getAttribute(soldOut ? "data-text-nostock" : "data-text-cart");

    buyBtn.dataset.state = soldOut ? "nostock" : "cart";
    buyBtn.disabled = soldOut;
    buyBtn.classList.toggle("nostock", soldOut);
    buyBtn.classList.toggle("cart", !soldOut);
    if (text) buyBtn.textContent = text;
  }

  // product-variants.js listens on .js-product-variants, a descendant of
  // document, so by the time this fires the data-selected flag already points at
  // the new option. No sibling import is involved — both modules read the same
  // template-rendered DOM.
  document.addEventListener("click", function (e) {
    if (!e.target.closest(".js-product-variant-option")) return;
    syncQuantity({ enforceMin: true });
    refreshBuyButtonState();
  });

  syncQuantity({ enforceMin: true });
  refreshBuyButtonState();

  /* ------------------------------------------------------------------ *
   * Add to cart                                                         *
   * ------------------------------------------------------------------ */

  form.addEventListener("submit", function (e) {
    // The shipping calculator lives inside #product_form, so pressing Enter in
    // the zipcode field implicitly submits the product form. Never treat that
    // as an add-to-cart.
    var active = document.activeElement;
    if (active && active.classList && active.classList.contains("js-shipping-input")) {
      e.preventDefault();
      return;
    }

    var submitBtn = form.querySelector(".js-product-sticky-buy-btn");
    // Never fall through to a native submit while disabled — that would navigate
    // away to the cart page instead of doing nothing.
    if (submitBtn && submitBtn.disabled) {
      e.preventDefault();
      return;
    }

    // Only "cart" is a real add-to-cart action. "contact"/"catalog" states fall
    // through to the native form submission, same as the legacy .js-addtocart
    // handler (store.js.tpl:1724) skipping its own AJAX flow for those cases.
    if (submitBtn && submitBtn.dataset.state !== "cart") return;

    e.preventDefault();

    // store.js.tpl:1584-1594 binds its own submit handler on `.js-product-form`
    // that unconditionally sets disabled on [type="submit"] and only ever relies
    // on the page navigating away to clear it. This flow is AJAX and never
    // reloads, so that handler would leave the button permanently disabled.
    // Ours is registered first (plain script at end of body vs. theirs inside
    // LS.ready.then()), so stopping immediate propagation keeps it from running
    // at all; the finally block below is the belt-and-braces guard in case that
    // registration order ever flips.
    e.stopImmediatePropagation();

    // Clamp BEFORE reading the form, so the posted quantity can never exceed the
    // stock of the variant that is currently selected.
    var stockLimit = getStockLimit();
    if (stockLimit !== null && stockLimit < 1) {
      refreshBuyButtonState();
      return;
    }
    var quantity = quantityInput ? String(syncQuantity({ enforceMin: true, notify: true })) : "1";

    var formData = new FormData(form);
    if (quantityInput) formData.set(quantityInput.name || "quantity", quantity);
    else quantity = formData.get("quantity") || "1";

    var selectedOptions = [];
    form.querySelectorAll(".js-product-variant-group").forEach(function (group) {
      var variationId = group.dataset.variationId;
      var selected = group.querySelector('[data-selected="true"]');
      if (variationId && selected && selected.dataset.optionId) {
        formData.append("variation[" + variationId + "]", selected.dataset.optionId);
        if (selected.dataset.optionName) selectedOptions.push(selected.dataset.optionName);
      }
    });

    // #shipping-variant-id is also inside the form, but it is only refreshed by
    // the legacy select-based variant flow, which this PDP no longer renders.
    // Keep it aligned with the pills so the payload is never contradictory.
    var selectedVariant = getSelectedVariant();
    if (selectedVariant && selectedVariant.id && formData.has("variant_id")) {
      formData.set("variant_id", selectedVariant.id);
    }

    var cartUrl = form.getAttribute("action");
    if (!cartUrl) return;

    var productName = document.querySelector(".js-product-name");
    productName = productName ? productName.textContent.trim() : "";

    var productPriceEl = stickyPriceDisplay || priceDisplay;
    var productPrice = productPriceEl ? productPriceEl.textContent.trim() : "";

    var productImageEl = document.querySelector(".js-product-gallery img");
    var productImage = productImageEl ? productImageEl.currentSrc || productImageEl.src : "";

    if (submitBtn) {
      submitBtn.style.pointerEvents = "none";
      submitBtn.style.opacity = "0.5";
    }

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
          quantity: quantity,
          variation: selectedOptions.length > 0 ? selectedOptions.join(" / ") : null,
        });
        window.onCartUpdate?.();
      })
      .catch(function (err) {
        console.error("Add to cart error:", err);
      })
      .finally(function () {
        if (submitBtn) {
          submitBtn.style.pointerEvents = "";
          submitBtn.style.opacity = "";
          // Clear a disabled flag set by anything else during this submit, then
          // let the stock logic decide the real state for the current variant.
          submitBtn.disabled = false;
          submitBtn.removeAttribute("disabled");
          refreshBuyButtonState();
        }
      });
  });
};
