export const cartDrawerSystem = () => {
  const drawer = document.querySelector(".js-cart-drawer");
  if (!drawer) return;

  let isOpen = false;
  let fetchController = null;

  const backdrop = drawer.querySelector(".js-cart-drawer-backdrop");
  const closeBtn = drawer.querySelector(".js-cart-drawer-close");

  const openDrawer = () => {
    if (isOpen) return;
    isOpen = true;
    drawer.dataset.state = "open";
    window.setHeaderMenuActive?.(true);

    if (window.innerWidth < 768) {
      document.body.style.overflow = "hidden";
    }

    refreshCart();
  };

  const closeDrawer = () => {
    if (!isOpen) return;
    isOpen = false;
    drawer.dataset.state = "closed";
    window.setHeaderMenuActive?.(false);

    if (window.innerWidth < 768) {
      document.body.style.overflow = "";
    }
  };

  // Fetch remote drawer HTML and return parsed elements
  const fetchRemoteDrawer = () => {
    if (fetchController) fetchController.abort();
    fetchController = new AbortController();

    return fetch(window.location.pathname, { signal: fetchController.signal })
      .then((res) => {
        if (!res.ok) throw new Error("fetch failed");
        return res.text();
      })
      .then((html) => {
        const doc = new DOMParser().parseFromString(html, "text/html");
        return doc;
      })
      .finally(() => {
        fetchController = null;
      });
  };

  // Update footer, badge, and empty state from remote doc (no list swap)
  const syncMeta = (doc) => {
    const remoteDrawer = doc.querySelector(".js-cart-drawer");
    if (!remoteDrawer) return;

    // Footer (subtotal + CTA)
    const remoteFooter = remoteDrawer.querySelector(".js-cart-drawer-footer");
    const localFooter = drawer.querySelector(".js-cart-drawer-footer");
    if (remoteFooter && localFooter) {
      localFooter.innerHTML = remoteFooter.innerHTML;
      localFooter.style.display = remoteFooter.style.display;
    }

    // Empty state
    const remoteEmpty = remoteDrawer.querySelector(".js-empty-ajax-cart");
    const localEmpty = drawer.querySelector(".js-empty-ajax-cart");
    if (remoteEmpty && localEmpty) {
      localEmpty.style.display = remoteEmpty.style.display;
      localEmpty.innerHTML = remoteEmpty.innerHTML;
    }

    // Header badge
    const remoteWidget = doc.querySelector(".js-cart-widget-amount");
    const localWidget = document.querySelector(".js-cart-widget-amount");
    if (remoteWidget && localWidget) {
      localWidget.textContent = remoteWidget.textContent;
    }

    if (typeof lucide !== "undefined") lucide.createIcons();
  };

  // Full refresh: replaces items list + meta
  const refreshCart = () => {
    fetchRemoteDrawer()
      .then((doc) => {
        if (!doc) return;
        const remoteDrawer = doc.querySelector(".js-cart-drawer");
        if (!remoteDrawer) return;

        const remoteList = remoteDrawer.querySelector(".js-ajax-cart-list");
        const localList = drawer.querySelector(".js-ajax-cart-list");
        if (remoteList && localList) {
          localList.innerHTML = remoteList.innerHTML;
        }

        syncMeta(doc);
      })
      .catch((err) => {
        if (err.name === "AbortError") return;
      });
  };

  // Soft refresh: only updates footer/badge (keeps current list intact)
  const refreshMeta = () => {
    fetchRemoteDrawer()
      .then((doc) => {
        if (doc) syncMeta(doc);
      })
      .catch((err) => {
        if (err.name === "AbortError") return;
      });
  };

  // Event: backdrop click
  if (backdrop) backdrop.addEventListener("click", closeDrawer);

  // Event: close button
  if (closeBtn) closeBtn.addEventListener("click", closeDrawer);

  // Event: toggle buttons
  document.addEventListener("click", (e) => {
    const toggle = e.target.closest(".js-cart-drawer-toggle");
    if (!toggle) return;
    e.preventDefault();
    isOpen ? closeDrawer() : openDrawer();
  });

  // Event: Escape key
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && isOpen) closeDrawer();
  });

  // Event: animated item removal
  drawer.addEventListener("click", (e) => {
    const removeBtn = e.target.closest(".js-cart-remove-btn");
    if (!removeBtn) return;

    const itemId = removeBtn.dataset.removeItemId;
    if (!itemId) return;

    const cartItem = removeBtn.closest(".js-cart-item");
    if (!cartItem) {
      LS.removeItem(itemId, true);
      return;
    }

    // Prevent double-click
    if (cartItem.dataset.removing) return;
    cartItem.dataset.removing = "true";

    // Fire server removal in background
    LS.removeItem(itemId, true);

    // Animate: fade + slide right
    const h = cartItem.offsetHeight;
    cartItem.style.overflow = "hidden";
    cartItem.style.maxHeight = h + "px";
    cartItem.style.transition = "opacity 0.2s ease-out, transform 0.2s ease-out";
    cartItem.style.opacity = "0";
    cartItem.style.transform = "translateX(40px)";

    // After fade, collapse height
    setTimeout(() => {
      cartItem.style.transition = "max-height 0.25s ease-in-out, padding 0.25s ease-in-out, border-width 0.25s ease-in-out";
      cartItem.style.maxHeight = "0";
      cartItem.style.paddingTop = "0";
      cartItem.style.paddingBottom = "0";
      cartItem.style.borderWidth = "0";
      cartItem.style.marginTop = "0";
      cartItem.style.marginBottom = "0";
    }, 200);

    // After collapse, clean up DOM + sync
    setTimeout(() => {
      cartItem.remove();

      const remaining = drawer.querySelectorAll(".js-cart-item");
      if (remaining.length === 0) {
        const emptyState = drawer.querySelector(".js-empty-ajax-cart");
        if (emptyState) emptyState.style.display = "";
        const footer = drawer.querySelector(".js-cart-drawer-footer");
        if (footer) footer.style.display = "none";
      }

      // Only sync footer/badge — list is already correct
      refreshMeta();
    }, 450);
  });

  // Register window globals
  window.openCartDrawer = openDrawer;
  window.closeCartDrawer = closeDrawer;
  window.onCartUpdate = () => refreshCart();
};
