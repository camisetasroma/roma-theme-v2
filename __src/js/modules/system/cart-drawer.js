export const cartDrawerSystem = () => {
  const drawer = document.querySelector(".js-cart-drawer");
  if (!drawer) return;

  let isOpen = false;

  const backdrop = drawer.querySelector(".js-cart-drawer-backdrop");
  const closeBtn = drawer.querySelector(".js-cart-drawer-close");
  const panel = drawer.querySelector(".js-cart-drawer-panel");

  const applyDesktopOffset = () => {
    if (!panel) return;
    if (window.innerWidth >= 768) {
      const header = document.querySelector(".js-new-header");
      const headerHeight = header ? header.offsetHeight : 0;
      panel.style.top = headerHeight + "px";
      panel.style.height = "calc(100% - " + headerHeight + "px)";
    } else {
      panel.style.top = "";
      panel.style.height = "";
    }
  };

  let resizeTimer = null;
  const onResize = () => {
    if (!isOpen) return;
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(applyDesktopOffset, 100);
  };

  window.addEventListener("resize", onResize);

  const openDrawer = () => {
    if (isOpen) return;
    isOpen = true;

    // Capture header height BEFORE body lock changes scroll/header state
    const preHeaderHeight = (() => {
      if (!panel || window.innerWidth < 768) return 0;
      const header = document.querySelector(".js-new-header");
      return header ? header.offsetHeight : 0;
    })();

    const scrollPos = window.scrollY;

    window.setHeaderMenuActive?.(true);

    drawer.dataset.state = "open";

    document.body.style.overflow = "hidden";
    document.documentElement.style.overflow = "hidden";
    document.body.style.position = "fixed";
    document.body.style.width = "100%";
    document.body.style.top = "-" + scrollPos + "px";

    // Apply pre-calculated offset (avoids wrong header height after body lock)
    if (panel && window.innerWidth >= 768) {
      panel.style.top = preHeaderHeight + "px";
      panel.style.height = "calc(100% - " + preHeaderHeight + "px)";
    } else if (panel) {
      panel.style.top = "";
      panel.style.height = "";
    }

    refreshCart();
  };

  const closeDrawer = () => {
    if (!isOpen) return;
    isOpen = false;
    drawer.dataset.state = "closed";

    const scrollY = Math.abs(parseInt(document.body.style.top || "0", 10));
    document.body.style.overflow = "";
    document.documentElement.style.overflow = "";
    document.body.style.position = "";
    document.body.style.width = "";
    document.body.style.top = "";
    window.scrollTo(0, scrollY);
    window.setHeaderMenuActive?.(false);
  };

  // Simple fetch that does NOT abort previous requests
  const fetchPage = () => {
    return fetch(window.location.pathname)
      .then((res) => {
        if (!res.ok) throw new Error("fetch failed");
        return res.text();
      })
      .then((html) => new DOMParser().parseFromString(html, "text/html"));
  };

  // Update footer, badge, and empty state from remote doc
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

    // Header badge (desktop)
    const remoteWidget = doc.querySelector(".js-cart-widget-amount");
    const localWidget = document.querySelector(".js-cart-widget-amount");
    if (remoteWidget && localWidget) {
      localWidget.textContent = remoteWidget.textContent;
    }

    // Header badge (mobile)
    const localBadge = document.querySelector(".js-cart-widget-badge");
    if (localBadge && remoteWidget) {
      const countText = remoteWidget.textContent.replace(/\D/g, "");
      const count = parseInt(countText, 10) || 0;
      if (count > 0) {
        localBadge.textContent = count;
        localBadge.hidden = false;
      } else {
        localBadge.hidden = true;
      }
    }

    if (typeof lucide !== "undefined") lucide.createIcons();
  };

  // Detect items present locally but missing from remote (removed by backend due to stock)
  const detectRemovedItems = (localList, remoteDoc) => {
    const localItems = localList.querySelectorAll(".js-cart-item[data-item-id]");
    const remoteDrawer = remoteDoc.querySelector(".js-cart-drawer");
    const remoteIds = new Set();
    if (remoteDrawer) {
      remoteDrawer.querySelectorAll(".js-cart-item[data-item-id]").forEach((el) => {
        remoteIds.add(el.dataset.itemId);
      });
    }

    const removed = [];
    localItems.forEach((el) => {
      if (!remoteIds.has(el.dataset.itemId)) {
        removed.push({
          id: el.dataset.itemId,
          name: el.dataset.itemName || "",
          element: el,
        });
      }
    });
    return removed;
  };

  // Animate out removed items (same pattern as manual removal lines 210-227)
  const animateRemovedItems = (items) => {
    return new Promise((resolve) => {
      if (items.length === 0) return resolve();

      items.forEach((item) => {
        const el = item.element;
        const h = el.offsetHeight;
        el.style.overflow = "hidden";
        el.style.maxHeight = h + "px";
        el.style.transition = "opacity 0.2s ease-out, transform 0.2s ease-out";
        el.style.opacity = "0";
        el.style.transform = "translateX(40px)";

        setTimeout(() => {
          el.style.transition = "max-height 0.25s ease-in-out, padding 0.25s ease-in-out, border-width 0.25s ease-in-out";
          el.style.maxHeight = "0";
          el.style.paddingTop = "0";
          el.style.paddingBottom = "0";
          el.style.borderWidth = "0";
          el.style.marginTop = "0";
          el.style.marginBottom = "0";
        }, 200);
      });

      setTimeout(resolve, 450);
    });
  };

  let isRefreshing = false;

  // Full refresh: replaces items list + meta
  const refreshCart = () => {
    if (isRefreshing) return;
    isRefreshing = true;

    fetchPage()
      .then((doc) => {
        if (!doc) {
          isRefreshing = false;
          return;
        }
        const remoteDrawer = doc.querySelector(".js-cart-drawer");
        if (!remoteDrawer) {
          isRefreshing = false;
          return;
        }

        const remoteList = remoteDrawer.querySelector(".js-ajax-cart-list");
        const localList = drawer.querySelector(".js-ajax-cart-list");
        if (!remoteList || !localList) {
          isRefreshing = false;
          return;
        }

        const removedItems = detectRemovedItems(localList, doc);

        if (removedItems.length > 0) {
          // Animate out removed items, then replace HTML and notify user
          animateRemovedItems(removedItems).then(() => {
            localList.innerHTML = remoteList.innerHTML;
            syncMeta(doc);
            isRefreshing = false;

            // Toast feedback
            if (removedItems.length === 1) {
              window.showToast?.({
                message: "\"" + removedItems[0].name + "\" foi removido do carrinho por estar esgotado",
                icon: "alert-circle",
              });
            } else {
              window.showToast?.({
                message: removedItems.length + " produtos foram removidos do carrinho por estarem esgotados",
                icon: "alert-circle",
              });
            }
          });
        } else {
          // No items removed — direct replacement (current behavior)
          localList.innerHTML = remoteList.innerHTML;
          syncMeta(doc);
          isRefreshing = false;
        }
      })
      .catch(() => {
        isRefreshing = false;
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

  // Track pending removals for batched sync
  let pendingRemovals = 0;
  let removeSyncTimer = null;

  const scheduleRemoveSync = () => {
    clearTimeout(removeSyncTimer);
    // Wait 1.2s after last removal to let all LS.removeItem AJAX calls complete
    removeSyncTimer = setTimeout(() => {
      pendingRemovals = 0;
      refreshCart();
    }, 1200);
  };

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
    pendingRemovals++;

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

    // After collapse, hide item visually but keep in DOM so platform JS
    // can still reference it during its AJAX callback (avoids null .style errors).
    // refreshCart() will replace the full list HTML later.
    setTimeout(() => {
      cartItem.style.display = "none";

      const remaining = drawer.querySelectorAll(".js-cart-item:not([style*='display: none'])");
      if (remaining.length === 0) {
        const emptyState = drawer.querySelector(".js-empty-ajax-cart");
        if (emptyState) emptyState.style.display = "";
        const footer = drawer.querySelector(".js-cart-drawer-footer");
        if (footer) footer.style.display = "none";
      }

      // Debounced: wait for all rapid removals to settle, then full sync
      scheduleRemoveSync();
    }, 450);
  });

  // Refresh progress bars after quantity +/- clicks inside drawer.
  // Listens on the drawer for clicks on .js-cart-quantity-btn, then waits
  // for the platform AJAX to finish before refreshing.
  let quantitySyncTimer = null;
  drawer.addEventListener("click", (e) => {
    if (!e.target.closest(".js-cart-quantity-btn")) return;
    if (pendingRemovals > 0) return;
    clearTimeout(quantitySyncTimer);
    quantitySyncTimer = setTimeout(() => {
      refreshCart();
    }, 2000);
  });

  // Observe platform updates to desktop badge and mirror to mobile badge
  const desktopBadge = document.querySelector(".js-cart-widget-amount");
  const mobileBadge = document.querySelector(".js-cart-widget-badge");
  if (desktopBadge && mobileBadge) {
    const badgeObserver = new MutationObserver(() => {
      const countText = desktopBadge.textContent.replace(/\D/g, "");
      const count = parseInt(countText, 10) || 0;
      if (count > 0) {
        mobileBadge.textContent = count;
        mobileBadge.hidden = false;
      } else {
        mobileBadge.hidden = true;
      }
    });
    badgeObserver.observe(desktopBadge, { childList: true, characterData: true, subtree: true });
  }

  // Register window globals
  window.openCartDrawer = openDrawer;
  window.closeCartDrawer = closeDrawer;
  window.onCartUpdate = () => refreshCart();
};
