export const toastSystem = () => {
  const container = document.querySelector(".js-toast-container");
  if (!container) return;

  const activeToasts = [];

  const updateContainerPosition = () => {
    const header = document.querySelector(".js-new-header");
    const headerHeight = header ? header.offsetHeight : 0;
    container.style.top = headerHeight + "px";
  };

  updateContainerPosition();
  window.addEventListener("resize", updateContainerPosition);

  const removeToast = (toast) => {
    const index = activeToasts.indexOf(toast);
    if (index > -1) activeToasts.splice(index, 1);
    if (toast.parentNode) toast.parentNode.removeChild(toast);
  };

  const closeToast = (toast) => {
    if (!toast || !toast.parentNode) return;
    if (toast.dataset.state === "exiting") return;

    clearTimeout(toast._dismissTimer);
    toast.dataset.state = "exiting";

    toast.addEventListener("transitionend", () => removeToast(toast), { once: true });

    setTimeout(() => removeToast(toast), 400);
  };

  const showToast = ({ message, icon, duration = 4000 } = {}) => {
    if (!message) return;

    updateContainerPosition();

    const toast = document.createElement("div");
    toast.dataset.state = "entering";
    Object.assign(toast.style, {
      display: "flex",
      alignItems: "center",
      gap: "12px",
      width: "241px",
      minHeight: "77px",
      padding: "12px 16px",
      borderRadius: "8px",
      border: "1px solid var(--color-fg-muted)",
      backdropFilter: "blur(4px)",
      WebkitBackdropFilter: "blur(4px)",
      backgroundColor: "color-mix(in srgb, var(--background-color) 70%, transparent)",
    });

    const iconMarkup = icon
      ? '<i data-lucide="' + icon + '" style="flex-shrink:0;width:20px;height:20px;color:var(--primary-color)"></i>'
      : "";

    toast.innerHTML =
      '<div style="display:flex;align-items:center;gap:12px;flex:1">' +
        iconMarkup +
        '<span style="font-size:0.875rem;line-height:1.375;color:var(--primary-color)">' + escapeHtml(message) + "</span>" +
      "</div>" +
      '<button type="button" class="js-toast-close" style="flex-shrink:0;cursor:pointer;color:var(--primary-color);background:none;border:none;padding:0" aria-label="Close">' +
        '<i data-lucide="x" style="width:16px;height:16px"></i>' +
      "</button>";

    container.appendChild(toast);

    if (typeof lucide !== "undefined") {
      lucide.createIcons();
    }

    toast.querySelector(".js-toast-close").addEventListener("click", () => closeToast(toast));

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        toast.dataset.state = "visible";
      });
    });

    activeToasts.push(toast);

    toast._dismissTimer = setTimeout(() => closeToast(toast), duration);

    return toast;
  };

  const closeAllToasts = () => {
    [...activeToasts].forEach((toast) => closeToast(toast));
  };

  window.showToast = showToast;
  window.closeToast = closeToast;
  window.closeAllToasts = closeAllToasts;
};

function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}
