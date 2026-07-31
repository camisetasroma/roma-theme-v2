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
      let cleaned = false;
      const cleanup = () => {
        if (cleaned) return;
        cleaned = true;
        if (contentSourceEl) {
          const body = content.querySelector(".js-gaius-modal-body");
          if (body) {
            contentSourceEl.innerHTML = body.innerHTML;
          }
          contentSourceEl = null;
        }
        container.innerHTML = "";
        currentModal = null;
      };
      const onTransitionEnd = (e) => {
        if (e.target !== content) return;
        content.removeEventListener("transitionend", onTransitionEnd);
        cleanup();
      };
      content.addEventListener("transitionend", onTransitionEnd);
      setTimeout(cleanup, 400);
    } else {
      container.innerHTML = "";
      currentModal = null;
    }
  };

  let contentSourceEl = null;

  const openModal = ({ title, content, contentSelector, size, mode } = {}) => {
    if (currentModal) {
      if (contentSourceEl) {
        const body = container.querySelector(".js-gaius-modal-body");
        if (body) {
          contentSourceEl.innerHTML = body.innerHTML;
        }
        contentSourceEl = null;
      }
      container.innerHTML = "";
      currentModal = null;
    }

    const isDrawer = mode === "drawer";

    const overlay = document.createElement("div");
    overlay.className = "js-gaius-modal-overlay";

    const modalContent = document.createElement("div");
    modalContent.className = isDrawer
      ? "js-gaius-modal-content js-gaius-modal-drawer"
      : "js-gaius-modal-content";

    if (!isDrawer) {
      const sizeClass = size === "lg" ? "max-width:640px" : size === "sm" ? "max-width:360px" : "max-width:480px";
      modalContent.style.cssText = sizeClass;
    }

    const headerMarkup = title
      ? '<div style="display:flex;align-items:center;justify-content:space-between;padding:16px 20px">' +
          '<h2 style="font-family:var(--font-headings);font-size:1.125rem;font-weight:600;color:var(--text-color);margin:0">' + escapeHtml(title) + "</h2>" +
          '<button type="button" class="js-gaius-modal-close" style="cursor:pointer;color:var(--text-color);background:none;border:none;padding:4px" aria-label="Close">' +
            '<i data-lucide="x" style="width:20px;height:20px"></i>' +
          "</button>" +
        "</div>"
      : '<button type="button" class="js-gaius-modal-close" style="position:absolute;top:12px;right:12px;cursor:pointer;color:var(--text-color);background:none;border:none;padding:4px;z-index:1" aria-label="Close">' +
          '<i data-lucide="x" style="width:20px;height:20px"></i>' +
        "</button>";

    let bodyContent = content || "";
    contentSourceEl = null;

    if (contentSelector) {
      const sourceEl = document.querySelector(contentSelector);
      if (sourceEl) {
        contentSourceEl = sourceEl;
        bodyContent = sourceEl.innerHTML;
        sourceEl.innerHTML = "";
      }
    }

    const bodyMarkup = '<div class="js-gaius-modal-body" style="padding:20px;overflow-y:auto">' + bodyContent + "</div>";

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
