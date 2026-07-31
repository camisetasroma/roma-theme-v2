export const categorySorting = () => {
  const dropdowns = document.querySelectorAll(".js-category-sorting");
  if (!dropdowns.length) return;

  dropdowns.forEach((dropdown) => {
    const trigger = dropdown.querySelector(".js-category-sorting-trigger");
    const list = dropdown.querySelector(".js-category-sorting-list");
    const icon = dropdown.querySelector(".js-category-sorting-icon");
    const options = dropdown.querySelectorAll(".js-category-sorting-option");
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

    options.forEach((option) => {
      option.addEventListener("click", function () {
        const sortValue = option.dataset.sortValue;
        if (!sortValue) return;

        const url = new URL(window.location.href);
        url.searchParams.set("sort_by", sortValue);
        window.location.href = url.toString();
      });
    });
  });
};
