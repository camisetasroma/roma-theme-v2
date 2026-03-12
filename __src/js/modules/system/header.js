export const headerAnimations = () => {
  const header = document.querySelector(".js-new-header");
  if (!header) return;

  const advertisingBar = document.querySelector(".js-advertising-bar");
  const adBarHeight = advertisingBar ? advertisingBar.offsetHeight : 0;
  const SCROLL_THRESHOLD = 50;
  const initialState = header.dataset.initialState || "transparent";
  let isMenuActive = false;

  function updateHeaderState(scrollY) {
    const shouldBeActive = scrollY > SCROLL_THRESHOLD || isMenuActive;
    header.setAttribute(
      "data-state",
      shouldBeActive ? "active" : initialState,
    );

    // Simulate scroll on advertising bar - moves up with page scroll
    // Skip when overlay is active (body lock makes scrollY unreliable)
    if (!isMenuActive && advertisingBar && adBarHeight > 0) {
      const translateY = Math.min(scrollY, adBarHeight);
      advertisingBar.style.transform = `translateY(-${translateY}px)`;
      advertisingBar.style.marginBottom = `-${translateY}px`;
    }
  }

  function handleScroll() {
    const scrollY = window.scrollY || window.pageYOffset;
    updateHeaderState(scrollY);
  }

  window.addEventListener("scroll", handleScroll, { passive: true });
  handleScroll();

  window.setHeaderMenuActive = function (active) {
    isMenuActive = active;
    updateHeaderState(window.scrollY || window.pageYOffset);
  };
};

export const advertisingCarousel = () => {
  const carousel = document.querySelector(".js-ad-carousel");
  if (!carousel) return;

  const slides = carousel.querySelectorAll(".js-ad-slide");
  if (slides.length < 2) return;

  let currentSlide = 0;
  const INTERVAL = 4000; // 4 seconds - reasonable reading time

  function showSlide(index) {
    slides.forEach((slide, i) => {
      if (i === index) {
        slide.classList.remove("opacity-0");
        slide.classList.add("opacity-100");
      } else {
        slide.classList.remove("opacity-100");
        slide.classList.add("opacity-0");
      }
    });
  }

  function nextSlide() {
    currentSlide = (currentSlide + 1) % slides.length;
    showSlide(currentSlide);
  }

  // Start the rotation
  setInterval(nextSlide, INTERVAL);
};