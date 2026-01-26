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

  // Detectar scroll
  function handleScroll() {
    const scrollY = window.scrollY || window.pageYOffset;
    const wasScrolled = isScrolled;
    isScrolled = scrollY > SCROLL_THRESHOLD;

    if (wasScrolled !== isScrolled) {
      updateHeaderState();
    }
  }

  // Event listeners
  window.addEventListener("scroll", handleScroll, { passive: true });

  // Verificar estado inicial
  handleScroll();

  // Expor função para controle externo (menus)
  window.setHeaderMenuActive = function (active) {
    isMenuActive = active;
    updateHeaderState();
  };
};

app()
