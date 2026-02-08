export const welcomeCouponToast = () => {
  const el = document.querySelector(".js-welcome-coupon");
  if (!el) return;

  const STORAGE_KEY = "roma_welcome_coupon_shown";

  try {
    if (localStorage.getItem(STORAGE_KEY) === "true") return;
    localStorage.setItem(STORAGE_KEY, "true");
  } catch (e) {}

  setTimeout(() => {
    if (typeof window.showToast !== "function") return;

    window.showToast({
      content: el.innerHTML,
      duration: 0,
      onReady: (toastEl) => {
        const copyBtn = toastEl.querySelector(".js-copy-coupon");
        if (!copyBtn) return;

        copyBtn.addEventListener("click", (e) => {
          e.preventDefault();
          e.stopPropagation();

          const coupon = copyBtn.dataset.coupon;
          const copyIcon = copyBtn.querySelector(".js-copy-icon");
          const checkIcon = copyBtn.querySelector(".js-check-icon");

          const showFeedback = () => {
            if (copyIcon) copyIcon.classList.add("hidden");
            if (checkIcon) checkIcon.classList.remove("hidden");
            setTimeout(() => {
              if (copyIcon) copyIcon.classList.remove("hidden");
              if (checkIcon) checkIcon.classList.add("hidden");
            }, 2000);
          };

          if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(coupon).then(showFeedback).catch(() => {
              fallbackCopy(coupon, showFeedback);
            });
          } else {
            fallbackCopy(coupon, showFeedback);
          }
        });
      }
    });
  }, 1500);

  function fallbackCopy(text, callback) {
    const textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.style.cssText = "position:fixed;opacity:0;pointer-events:none";
    document.body.appendChild(textarea);
    textarea.select();
    try { document.execCommand("copy"); callback(); } catch (e) {}
    document.body.removeChild(textarea);
  }
};