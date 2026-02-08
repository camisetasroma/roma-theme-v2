export const toastSystem = () => {
  const toastContainer = document.querySelector(".js-toast-container");
  if (!toastContainer) return;

  const toasts = new Map();
  let toastIdCounter = 0;
  const MAX_VISIBLE_TOASTS = 4;
  const DEFAULT_DURATION = 5000;

  // Position below header dynamically
  function updateContainerPosition() {
    const header = document.querySelector(".js-new-header");
    const headerHeight = header ? header.offsetHeight : 0;
    toastContainer.style.top = (headerHeight + 16) + "px";
  }

  // Initial position and listeners
  updateContainerPosition();
  window.addEventListener("scroll", updateContainerPosition, { passive: true });
  window.addEventListener("resize", updateContainerPosition, { passive: true });

  function showToast(options = {}) {
    const {
      content = "",
      duration = DEFAULT_DURATION,
      onClose = null,
      onReady = null
    } = options;

    const toastId = ++toastIdCounter;

    // Create toast element (this part stays dynamic as each toast is unique)
    const toast = document.createElement("div");
    toast.className = "js-toast";
    toast.setAttribute("data-toast-id", toastId);
    toast.setAttribute("data-state", "hidden");
    toast.innerHTML = `
      <button class="js-toast-close" type="button" aria-label="Fechar notificação">
        <i data-lucide="x" class="w-4 h-4"></i>
      </button>
      <div class="js-toast-content"></div>
    `;

    const contentArea = toast.querySelector(".js-toast-content");
    if (typeof content === "string") {
      contentArea.innerHTML = content;
    } else if (content instanceof HTMLElement) {
      contentArea.appendChild(content);
    }

    // Store toast data
    toasts.set(toastId, { element: toast, onClose, timerId: null });

    // Limit visible toasts
    if (toasts.size > MAX_VISIBLE_TOASTS) {
      const oldestId = toasts.keys().next().value;
      closeToast(oldestId);
    }

    // Add to container
    toastContainer.appendChild(toast);

    // Reinit icons
    if (typeof lucide !== "undefined") lucide.createIcons();

    // Show toast with animation
    requestAnimationFrame(() => {
      toast.setAttribute("data-state", "visible");
    });

    // Close button
    toast.querySelector(".js-toast-close").addEventListener("click", () => {
      closeToast(toastId);
    });

    // Swipe to dismiss
    setupSwipeGesture(toast, toastId);

    // Auto dismiss
    if (duration > 0) {
      const timerId = setTimeout(() => closeToast(toastId), duration);
      toasts.get(toastId).timerId = timerId;
    }

    if (onReady) onReady(toast);

    return toastId;
  }

  function setupSwipeGesture(toast, toastId) {
    let startX = 0;
    let currentX = 0;
    let isDragging = false;
    let hasMoved = false;

    const onStart = (e) => {
      if (e.target.closest("button, a, input, textarea, select, [role='button']")) return;
      if (toast.getAttribute("data-state") === "dismissed") return;

      isDragging = true;
      hasMoved = false;
      startX = e.type === "touchstart" ? e.touches[0].clientX : e.clientX;
      currentX = startX;
    };

    const onMove = (e) => {
      if (!isDragging) return;
      currentX = e.type === "touchmove" ? e.touches[0].clientX : e.clientX;
      const deltaX = currentX - startX;
      if (deltaX > 5) {
        if (!hasMoved) {
          hasMoved = true;
          toast.setAttribute("data-state", "swiping");
        }
        toast.style.transform = `translateX(${deltaX}px)`;
      }
    };

    const onEnd = () => {
      if (!isDragging) return;
      isDragging = false;

      if (!hasMoved) return;

      if (toast.getAttribute("data-state") === "dismissed") return;
      if (!toasts.has(toastId)) return;

      const deltaX = currentX - startX;

      if (deltaX > 100) {
        closeToast(toastId);
      } else {
        toast.style.transform = "";
        toast.setAttribute("data-state", "visible");
      }
    };

    // Touch events on the toast element
    toast.addEventListener("touchstart", onStart, { passive: true });
    toast.addEventListener("touchmove", onMove, { passive: true });
    toast.addEventListener("touchend", onEnd);

    // Mouse: mousedown on toast, move/up scoped to toast via capture
    toast.addEventListener("mousedown", onStart);
    toast.addEventListener("mousemove", onMove);
    toast.addEventListener("mouseup", onEnd);
  }

  function closeToast(toastId) {
    const toastData = toasts.get(toastId);
    if (!toastData) return;

    const { element, onClose, timerId } = toastData;

    if (timerId) clearTimeout(timerId);

    element.setAttribute("data-state", "dismissed");

    setTimeout(() => {
      element.remove();
      toasts.delete(toastId);
      if (onClose) onClose();
    }, 300);
  }

  function closeAllToasts() {
    toasts.forEach((_, toastId) => closeToast(toastId));
  }

  // Expose global API
  window.showToast = showToast;
  window.closeToast = closeToast;
  window.closeAllToasts = closeAllToasts;
};