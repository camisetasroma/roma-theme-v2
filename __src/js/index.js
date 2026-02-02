const app = () => {
  const header = document.querySelector(".js-new-header");
  if (!header) return;

  const SCROLL_THRESHOLD = 50;
  let isScrolled = false;
  let isMenuActive = false;

  function updateHeaderState() {
    const shouldBeActive = isScrolled || isMenuActive;
    header.setAttribute(
      "data-state",
      shouldBeActive ? "active" : "transparent",
    );
  }

  function handleScroll() {
    const scrollY = window.scrollY || window.pageYOffset;
    const wasScrolled = isScrolled;
    isScrolled = scrollY > SCROLL_THRESHOLD;
    if (wasScrolled !== isScrolled) updateHeaderState();
  }

  window.addEventListener("scroll", handleScroll, { passive: true });
  handleScroll();

  window.setHeaderMenuActive = function (active) {
    isMenuActive = active;
    updateHeaderState();
  };
};

const menuSystem = () => {
  const menuMobile = document.querySelector(".js-menu-mobile");
  const menuMobileToggle = document.querySelector(".js-menu-mobile-toggle");
  const menuMobileClose = document.querySelector(".js-menu-mobile-close");
  const menuMobileTabs = document.querySelectorAll(".js-menu-mobile-tab");
  const menuMobilePanels = document.querySelectorAll(".js-menu-mobile-panel");
  const menuDesktopToggles = document.querySelectorAll(".js-menu-desktop-toggle");
  const menuDropdowns = document.querySelectorAll(".js-menu-dropdown");

  let isMobileMenuOpen = false;
  let activeDesktopMenu = null;

  // === MOBILE ===

  const openMobileMenu = () => {
    if (!menuMobile) return;
    isMobileMenuOpen = true;
    menuMobile.hidden = false;
    document.body.style.overflow = "hidden";
    window.setHeaderMenuActive?.(true);

   

    reinitIcons();
    requestAnimationFrame(initCarouselScrollbars);
  };

  const closeMobileMenu = () => {
    if (!menuMobile) return;
    isMobileMenuOpen = false;
    menuMobile.hidden = true;
    document.body.style.overflow = "";
    window.setHeaderMenuActive?.(false);
  };

  const switchMobileTab = (index) => {
    menuMobileTabs.forEach((tab, i) => {
      if (i === index) {
        tab.classList.add("bg-black/5!", "font-semibold!");
      } else {
        tab.classList.remove("bg-black/5!", "font-semibold!");
      }
    });
    menuMobilePanels.forEach((panel, i) => {
      if (i === index) {
        panel.classList.remove("hidden");
        panel.classList.add("block");
      } else {
        panel.classList.remove("block");
        panel.classList.add("hidden");
      }
    });
    reinitIcons();
  };

  menuMobileToggle?.addEventListener("click", () => {
    isMobileMenuOpen ? closeMobileMenu() : openMobileMenu();
  });

  menuMobileClose?.addEventListener("click", closeMobileMenu);

  menuMobileTabs.forEach((tab, index) => {
    tab.addEventListener("click", () => switchMobileTab(index));
  });

  // === CAROUSEL SCROLLBAR ===

  function initCarouselScrollbars() {
    document.querySelectorAll(".js-menu-carousel").forEach((carousel) => {
      if (carousel._scrollbarInit) return;
      carousel._scrollbarInit = true;

      const track = carousel.querySelector(".js-menu-carousel-track");
      const thumb = carousel.querySelector(".js-menu-carousel-scrollbar-thumb");
      if (!track || !thumb) return;

      let rafId = null;
      const updateThumb = () => {
        const { scrollWidth, clientWidth, scrollLeft } = track;
        if (scrollWidth <= clientWidth) {
          thumb.parentElement.style.display = "none";
          return;
        }
        thumb.parentElement.style.display = "block";
        const ratio = clientWidth / scrollWidth;
        const thumbWidth = Math.max(ratio * 100, 15);
        const maxScroll = scrollWidth - clientWidth;
        const thumbLeft = maxScroll > 0 ? (scrollLeft / maxScroll) * (100 - thumbWidth) : 0;
        thumb.style.width = thumbWidth + "%";
        thumb.style.marginLeft = thumbLeft + "%";
      };

      const onScroll = () => {
        if (rafId) cancelAnimationFrame(rafId);
        rafId = requestAnimationFrame(updateThumb);
      };

      track.addEventListener("scroll", onScroll, { passive: true });

      // Drag support
      let isDragging = false;
      let startX = 0;
      let startScroll = 0;

      thumb.addEventListener("mousedown", (e) => {
        isDragging = true;
        startX = e.clientX;
        startScroll = track.scrollLeft;
        e.preventDefault();
      });

      document.addEventListener("mousemove", (e) => {
        if (!isDragging) return;
        const bar = thumb.parentElement;
        const barWidth = bar.offsetWidth;
        const { scrollWidth, clientWidth } = track;
        const maxScroll = scrollWidth - clientWidth;
        const ratio = clientWidth / scrollWidth;
        const thumbWidth = Math.max(ratio, 0.15);
        const movableBarWidth = barWidth * (1 - thumbWidth);
        const dx = e.clientX - startX;
        const scrollDelta = (dx / movableBarWidth) * maxScroll;
        track.scrollLeft = startScroll + scrollDelta;
      });

      document.addEventListener("mouseup", () => {
        isDragging = false;
      });

      updateThumb();
    });
  }

  // === DESKTOP ===

  const openDesktopMenu = (index) => {
    const dropdown = menuDropdowns[index];
    const toggle = menuDesktopToggles[index];
    if (!dropdown || !toggle) return;

    closeAllDesktopMenus();
    activeDesktopMenu = index;
    dropdown.hidden = false;
    toggle.setAttribute("aria-expanded", "true");

    const iconClosed = toggle.querySelector(".js-icon-closed");
    const iconOpen = toggle.querySelector(".js-icon-open");
    if (iconClosed) iconClosed.classList.add("hidden");
    if (iconOpen) iconOpen.classList.remove("hidden");

    window.setHeaderMenuActive?.(true);
    reinitIcons();
    requestAnimationFrame(initCarouselScrollbars);
  };

  const closeDesktopMenu = (index) => {
    const dropdown = menuDropdowns[index];
    const toggle = menuDesktopToggles[index];
    if (!dropdown || !toggle) return;

    dropdown.hidden = true;
    toggle.setAttribute("aria-expanded", "false");

    const iconClosed = toggle.querySelector(".js-icon-closed");
    const iconOpen = toggle.querySelector(".js-icon-open");
    if (iconClosed) iconClosed.classList.remove("hidden");
    if (iconOpen) iconOpen.classList.add("hidden");
  };

  const closeAllDesktopMenus = () => {
    menuDesktopToggles.forEach((_, i) => closeDesktopMenu(i));
    activeDesktopMenu = null;
    window.setHeaderMenuActive?.(false);
  };

  menuDesktopToggles.forEach((toggle, index) => {
    toggle.addEventListener("click", (e) => {
      e.preventDefault();
      activeDesktopMenu === index ? closeAllDesktopMenus() : openDesktopMenu(index);
    });
  });

  document.addEventListener("click", (e) => {
    if (activeDesktopMenu === null) return;
    if (!e.target.closest("[data-menu-desktop]") && !e.target.closest(".js-menu-dropdown")) {
      closeAllDesktopMenus();
    }
  });

  // === ACCORDION (event delegation) ===

  document.addEventListener("click", (e) => {
    const toggle = e.target.closest(".js-menu-accordion-toggle");
    if (!toggle) return;

    const isExpanded = toggle.getAttribute("aria-expanded") === "true";
    const currentLi = toggle.closest("li");
    const content = currentLi?.querySelector(".js-menu-accordion-content");
    if (!content) return;

    // Close siblings at the same level
    const parentUl = currentLi.parentElement;
    if (parentUl && !isExpanded) {
      parentUl.querySelectorAll(":scope > li").forEach((li) => {
        if (li === currentLi) return;
        const siblingToggle = li.querySelector(".js-menu-accordion-toggle");
        const siblingContent = li.querySelector(".js-menu-accordion-content");
        if (siblingToggle && siblingContent) {
          siblingToggle.setAttribute("aria-expanded", "false");
          siblingContent.hidden = true;
        }
      });
    }

    toggle.setAttribute("aria-expanded", String(!isExpanded));
    content.hidden = isExpanded;
    if (!isExpanded) reinitIcons();
  });

  // === ESC KEY ===

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      if (isMobileMenuOpen) closeMobileMenu();
      if (activeDesktopMenu !== null) closeAllDesktopMenus();
    }
  });

  // === HELPERS ===

  function reinitIcons() {
    setTimeout(() => {
      if (typeof lucide !== "undefined") lucide.createIcons();
    }, 50);
  }
};

// Script is loaded at end of body, DOM is ready
app();
menuSystem();
