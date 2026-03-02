export const modalSystem = () => {
  const container = document.querySelector(".js-gaius-modal-container");
  if (!container) return;

  let currentModal = null;
  let savedOverflow = "";

  const lockScroll = () => {
    savedOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
  };

  const unlockScroll = () => {
    document.body.style.overflow = savedOverflow;
  };

  const closeModal = () => {
    if (!currentModal) return;

    container.dataset.state = "closed";
    unlockScroll();

    const content = container.querySelector(".js-gaius-modal-content");
    if (content) {
      const cleanup = () => {
        container.innerHTML = "";
        currentModal = null;
      };
      content.addEventListener("transitionend", cleanup, { once: true });
      setTimeout(cleanup, 400);
    } else {
      container.innerHTML = "";
      currentModal = null;
    }
  };

  const openModal = ({ title, content, size } = {}) => {
    if (currentModal) {
      container.innerHTML = "";
      currentModal = null;
    }

    const sizeClass = size === "lg" ? "max-width:640px" : size === "sm" ? "max-width:360px" : "max-width:480px";

    const overlay = document.createElement("div");
    overlay.className = "js-gaius-modal-overlay";

    const modalContent = document.createElement("div");
    modalContent.className = "js-gaius-modal-content";
    modalContent.style.cssText = sizeClass;

    const headerMarkup = title
      ? '<div style="display:flex;align-items:center;justify-content:space-between;padding:16px 20px;border-bottom:1px solid color-mix(in srgb, var(--primary-color) 15%, transparent)">' +
          '<h2 style="font-family:var(--font-headings);font-size:1.125rem;font-weight:600;color:var(--primary-color);margin:0">' + escapeHtml(title) + "</h2>" +
          '<button type="button" class="js-gaius-modal-close" style="cursor:pointer;color:var(--primary-color);background:none;border:none;padding:4px" aria-label="Close">' +
            '<i data-lucide="x" style="width:20px;height:20px"></i>' +
          "</button>" +
        "</div>"
      : '<button type="button" class="js-gaius-modal-close" style="position:absolute;top:12px;right:12px;cursor:pointer;color:var(--primary-color);background:none;border:none;padding:4px;z-index:1" aria-label="Close">' +
          '<i data-lucide="x" style="width:20px;height:20px"></i>' +
        "</button>";

    const bodyMarkup = '<div style="padding:20px">' + (content || "") + "</div>";

    modalContent.innerHTML = headerMarkup + bodyMarkup;

    container.innerHTML = "";
    container.appendChild(overlay);
    container.appendChild(modalContent);

    if (typeof lucide !== "undefined") {
      lucide.createIcons();
    }

    overlay.addEventListener("click", closeModal);
    modalContent.querySelector(".js-gaius-modal-close").addEventListener("click", closeModal);

    lockScroll();
    currentModal = modalContent;

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        container.dataset.state = "open";
      });
    });
  };

  const handleKeydown = (e) => {
    if (e.key === "Escape" && currentModal) {
      closeModal();
    }
  };

  document.addEventListener("keydown", handleKeydown);

  window.openModal = openModal;
  window.closeModal = closeModal;
};

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}
