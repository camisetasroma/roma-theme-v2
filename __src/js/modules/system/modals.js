export const modalSystem = () => {
  // Get existing DOM elements (from Twig template)
  const overlay = document.querySelector(".js-modal-overlay");
  if (!overlay) return;

  const contentArea = overlay.querySelector(".js-modal-content");
  const closeBtn = overlay.querySelector(".js-modal-close");
  let isOpen = false;
  let currentOnClose = null;

  // Close on overlay click (outside container)
  overlay.addEventListener("click", (e) => {
    if (e.target === overlay) closeModal();
  });

  // Close button
  if (closeBtn) {
    closeBtn.addEventListener("click", closeModal);
  }

  function openModal(options = {}) {
    const { content = "", onClose = null } = options;
    currentOnClose = onClose;

    // Set content (if provided)
    if (content && contentArea) {
      if (typeof content === "string") {
        contentArea.innerHTML = content;
      } else if (content instanceof HTMLElement) {
        contentArea.innerHTML = "";
        contentArea.appendChild(content);
      }
    }

    // Open modal
    isOpen = true;
    overlay.setAttribute("data-state", "open");
    document.body.style.overflow = "hidden";

    // Reinit icons in content
    if (typeof lucide !== "undefined") lucide.createIcons();
  }

  function closeModal() {
    if (!isOpen) return;

    isOpen = false;
    overlay.setAttribute("data-state", "closed");
    document.body.style.overflow = "";

    if (currentOnClose) {
      currentOnClose();
      currentOnClose = null;
    }

    // Clear content after animation
    setTimeout(() => {
      if (contentArea) contentArea.innerHTML = "";
    }, 200);
  }

  // ESC key handler
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && isOpen) closeModal();
  });

  // Expose global API
  window.openModal = openModal;
  window.closeModal = closeModal;
};