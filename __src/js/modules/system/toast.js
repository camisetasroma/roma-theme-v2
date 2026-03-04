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

  const showToast = ({ message, icon, duration = 4000, product } = {}) => {
    if (!message && !product) return;

    updateContainerPosition();

    const toast = document.createElement("div");
    toast.dataset.state = "entering";

    const isProduct = !!product;

    Object.assign(toast.style, {
      display: "flex",
      alignItems: isProduct ? "flex-start" : "center",
      gap: "12px",
      minHeight: "77px",
      padding: "12px 16px",
      borderRadius: "8px",
      backdropFilter: "blur(4px)",
      WebkitBackdropFilter: "blur(4px)",
      backgroundColor: "color-mix(in srgb, var(--background-color) 70%, transparent)",
      border: "1px solid rgba(0, 0, 0, 0.1)",
    });

    if (isProduct) {
      toast.style.maxWidth = "320px";
      toast.style.width = "auto";
    } else {
      toast.style.width = "241px";
      toast.style.border = "1px solid var(--color-fg-muted)";
    }

    if (isProduct) {
      var imageMarkup = product.image
        ? '<img src="' + escapeHtml(product.image) + '" alt="' + escapeHtml(product.name || "") + '" style="width:56px;height:56px;object-fit:cover;border-radius:6px;flex-shrink:0">'
        : "";

      var nameMarkup = product.name
        ? '<span style="font-size:0.8125rem;line-height:1.3;color:var(--text-color);display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden">' + escapeHtml(product.name) + "</span>"
        : "";

      var priceMarkup = product.price
        ? '<span style="font-size:0.8125rem;font-weight:700;color:var(--text-color)">' + escapeHtml(product.price) + "</span>"
        : "";

      var quantityMarkup = product.quantity
        ? '<span style="font-size:0.75rem;color:var(--text-color);opacity:0.6">' + escapeHtml("Qtd: " + product.quantity) + "</span>"
        : "";

      toast.innerHTML =
        imageMarkup +
        '<div style="display:flex;flex-direction:column;gap:4px;flex:1;min-width:0">' +
          nameMarkup +
          priceMarkup +
          quantityMarkup +
        "</div>" +
        '<button type="button" class="js-toast-close" style="flex-shrink:0;cursor:pointer;color:var(--text-color);background:none;border:none;padding:0;margin-top:2px" aria-label="Close">' +
          '<i data-lucide="x" style="width:14px;height:14px"></i>' +
        "</button>";
    } else {
      var iconMarkup = icon
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
    }

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
