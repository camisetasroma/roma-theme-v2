export const categoryDropdown = () => {
  const dropdown = document.querySelector(".js-category-dropdown");
  if (!dropdown) return;

  const trigger = dropdown.querySelector(".js-category-dropdown-trigger");
  const list = dropdown.querySelector(".js-category-dropdown-list");
  const icon = dropdown.querySelector(".js-category-dropdown-icon");
  if (!trigger || !list) return;

  function open() {
    list.hidden = false;
    trigger.setAttribute("aria-expanded", "true");
    if (icon) icon.style.transform = "rotate(180deg)";
  }

  function close() {
    list.hidden = true;
    trigger.setAttribute("aria-expanded", "false");
    if (icon) icon.style.transform = "";
  }

  function toggle() {
    if (list.hidden) {
      open();
    } else {
      close();
    }
  }

  trigger.addEventListener("click", toggle);

  document.addEventListener("click", function (e) {
    if (!dropdown.contains(e.target)) {
      close();
    }
  });
};
