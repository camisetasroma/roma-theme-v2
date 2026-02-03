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

const productCarousel = () => {
  const section = document.querySelector(".js-product-carousel");
  if (!section) return;

  const dropdown = section.querySelector(".js-carousel-dropdown");
  const dropdownTrigger = section.querySelector(".js-carousel-dropdown-trigger");
  const dropdownLabel = section.querySelector(".js-carousel-dropdown-label");
  const dropdownList = section.querySelector(".js-carousel-dropdown-list");
  const dropdownIcon = section.querySelector(".js-carousel-dropdown-icon");
  const dropdownOptions = section.querySelectorAll(".js-carousel-dropdown-option");
  const tabs = section.querySelectorAll(".js-carousel-tab");
  const paginationContainer = section.querySelector(".js-carousel-pagination");
  const prevBtn = section.querySelector(".js-carousel-prev");
  const nextBtn = section.querySelector(".js-carousel-next");

  // SVG for seed pagination dot
  const styles = getComputedStyle(document.documentElement);
  const activeColor = styles.getPropertyValue("--text-color").trim() || "#410911";
  const inactiveColor = "#C4C4C0";
  const seedSVG = (active) => `
    <svg xmlns="http://www.w3.org/2000/svg" width="11" height="8" viewBox="0 0 11 8" fill="none">
      <path d="M6.93294 6.9178C10.0118 6.33768 11.5457 4.64453 10.8236 2.44759C10.2482 0.697531 8.31108 -0.0463472 6.24753 0.00222694C4.0117 0.0549646 2.34216 1.16245 1.5248 2.83063C1.07947 3.73966 0.564497 5.41477 0.0330304 6.99968C-0.164895 7.58812 0.559 8.12244 1.34154 7.97533C2.63722 7.73523 5.76371 7.13846 6.93294 6.9178Z" fill="${active ? activeColor : inactiveColor}"/>
    </svg>`;

  // Controls container (seeds + arrows)
  const controlsContainer = section.querySelector(".js-carousel-controls");

  // Initialize Swiper instances
  const swipers = {};
  const realSlideCounts = {};
  let activeTab = "tab-1";
  let initCount = 0;

  function getActiveSwiper() {
    return swipers[activeTab];
  }

  // Show/hide controls (invisible but keeping space) when not needed
  function updateControlsVisibility(realCount) {
    if (!controlsContainer) return;
    // With infinite loop, always show controls if there are at least 2 items
    // Hide only when there's 1 or 0 items (nothing to scroll)
    const needsControls = realCount >= 2;
    controlsContainer.style.visibility = needsControls ? "visible" : "hidden";
  }

  // Update seed pagination (1 seed per real product)
  function updatePagination(swiper) {
    if (!paginationContainer || !swiper) return;
    const realCount = realSlideCounts[activeTab] || 0;
    const isLoop = swiper.params.loop;
    const currentIndex = isLoop ? swiper.realIndex : swiper.activeIndex;
    renderPagination(realCount, currentIndex);
  }

  // Update pagination with a specific index (used when switching tabs)
  function updatePaginationForIndex(index) {
    const realCount = realSlideCounts[activeTab] || 0;
    renderPagination(realCount, index);
  }

  // Render the pagination seeds
  function renderPagination(realCount, currentIndex) {
    if (!paginationContainer) return;

    let html = "";
    for (let i = 0; i < realCount; i++) {
      html += `<span class="cursor-pointer js-carousel-seed" data-index="${i}">${seedSVG(i === currentIndex)}</span>`;
    }
    paginationContainer.innerHTML = html;

    // Click listeners on seeds
    paginationContainer.querySelectorAll(".js-carousel-seed").forEach((seed) => {
      seed.addEventListener("click", () => {
        const idx = parseInt(seed.dataset.index);
        const sw = getActiveSwiper();
        if (!sw) return;
        if (sw.params.loop) {
          sw.slideToLoop(idx);
        } else {
          sw.slideTo(idx);
        }
      });
    });
  }

  // Init swipers for each tab (using setTimeout like the theme's createSwiper)
  const mobilePerView = 2.25;
  const desktopPerView = 3.25;

  for (let i = 1; i <= 3; i++) {
    const container = section.querySelector(`.js-swiper-product-carousel-${i}`);
    if (container) {
      const slideCount = container.querySelectorAll(".swiper-slide").length;
      realSlideCounts[`tab-${i}`] = slideCount;

      setTimeout(() => {
        // For loop to work smoothly, we need enough cloned slides
        // loopedSlides should be at least slidesPerView rounded up
        const loopSlides = Math.max(slideCount, Math.ceil(mobilePerView) + 1);

        swipers[`tab-${i}`] = new Swiper(container, {
          slidesPerView: mobilePerView,
          spaceBetween: 12,
          loop: true,
          loopedSlides: loopSlides,
          loopAdditionalSlides: 2,
          breakpoints: {
            768: {
              slidesPerView: desktopPerView,
              spaceBetween: 16,
            },
          },
          on: {
            slideChange: function () {
              if (`tab-${i}` === activeTab) {
                // realIndex already handles loop correctly
                const realIndex = this.realIndex % slideCount;
                updatePaginationForIndex(realIndex);
              }
            },
          },
        });

        initCount++;
        // After first tab swiper is ready, update UI
        if (i === 1 || (initCount === 1 && `tab-${i}` === activeTab)) {
          updatePagination(swipers[`tab-${i}`]);
          updateControlsVisibility(slideCount);
        }
      }, 0);
    }
  }

  // Switch to a given tab
  function switchTab(newTab) {
    tabs.forEach((tab) => {
      if (tab.dataset.tab === newTab) {
        tab.classList.remove("hidden");
      } else {
        tab.classList.add("hidden");
      }
    });
    activeTab = newTab;
    const swiper = getActiveSwiper();
    if (swiper) {
      swiper.update();
      // Reset to first slide when switching tabs
      if (swiper.params.loop) {
        swiper.slideToLoop(0, 0);
      } else {
        swiper.slideTo(0, 0);
      }
      // Force pagination to show first seed as active
      updatePaginationForIndex(0);
      updateControlsVisibility(realSlideCounts[activeTab] || 0);
    }
    if (typeof lucide !== "undefined") lucide.createIcons();
  }

  // Custom dropdown
  function closeDropdown() {
    if (!dropdownList) return;
    dropdownList.classList.add("hidden");
    if (dropdownIcon) dropdownIcon.style.transform = "";
    if (dropdownTrigger) dropdownTrigger.setAttribute("aria-expanded", "false");
  }

  function openDropdown() {
    if (!dropdownList) return;
    dropdownList.classList.remove("hidden");
    if (dropdownIcon) dropdownIcon.style.transform = "rotate(180deg)";
    if (dropdownTrigger) dropdownTrigger.setAttribute("aria-expanded", "true");
  }

  if (dropdownTrigger) {
    dropdownTrigger.addEventListener("click", () => {
      const isOpen = !dropdownList.classList.contains("hidden");
      isOpen ? closeDropdown() : openDropdown();
    });
  }

  dropdownOptions.forEach((option) => {
    option.addEventListener("click", () => {
      const newTab = option.dataset.value;
      if (dropdownLabel) dropdownLabel.textContent = option.textContent.trim();
      dropdownOptions.forEach((o) => o.removeAttribute("data-selected"));
      option.setAttribute("data-selected", "true");
      closeDropdown();
      switchTab(newTab);
    });
  });

  // Close dropdown when clicking outside
  document.addEventListener("click", (e) => {
    if (dropdown && !dropdown.contains(e.target)) {
      closeDropdown();
    }
  });

  // Navigation arrows
  if (prevBtn) {
    prevBtn.addEventListener("click", () => {
      const swiper = getActiveSwiper();
      if (swiper) swiper.slidePrev();
    });
  }

  if (nextBtn) {
    nextBtn.addEventListener("click", () => {
      const swiper = getActiveSwiper();
      if (swiper) swiper.slideNext();
    });
  }

  // Update controls visibility on resize (breakpoint may change)
  window.addEventListener("resize", () => {
    const swiper = getActiveSwiper();
    if (swiper) {
      updateControlsVisibility(realSlideCounts[activeTab] || 0);
    }
  });

  // Reinit icons for lazy loaded content
  if (typeof lucide !== "undefined") lucide.createIcons();
};

// Script is loaded at end of body, DOM is ready
app();
menuSystem();
productCarousel();
