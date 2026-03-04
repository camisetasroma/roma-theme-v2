export const categoryInfiniteScroll = () => {
  const grid = document.querySelector(".js-category-grid");
  if (!grid) return;

  const loadMoreContainer = document.querySelector(".js-category-load-more");
  const loadMoreBtn = document.querySelector(".js-category-load-more-btn");
  const spinner = document.querySelector(".js-category-scroll-spinner");
  if (!loadMoreContainer || !loadMoreBtn || !spinner) return;

  let loading = false;
  let isLast = grid.dataset.isLast === "true";
  let nextUrl = grid.dataset.nextUrl || "";

  if (isLast || !nextUrl) {
    loadMoreContainer.hidden = true;
    return;
  }

  function extractCardHtmls(doc) {
    var cards = [];
    var categoryGrid = doc.querySelector(".js-category-grid");
    if (!categoryGrid) return cards;

    var existingIds = {};
    grid.querySelectorAll("[data-product-id]").forEach(function (el) {
      existingIds[el.dataset.productId] = true;
    });

    categoryGrid.querySelectorAll("[data-product-id]").forEach(function (card) {
      var id = card.dataset.productId;
      if (id && !existingIds[id]) {
        cards.push(card.outerHTML);
      }
    });

    return cards;
  }

  function showLoading() {
    loadMoreContainer.hidden = true;
    spinner.hidden = false;
  }

  function hideLoading() {
    spinner.hidden = true;
  }

  function finish() {
    hideLoading();
    loadMoreContainer.hidden = true;
    observer.disconnect();
  }

  var fetchedUrls = {};

  function loadMore() {
    if (loading || isLast || !nextUrl) {
      if (isLast) finish();
      return;
    }
    if (fetchedUrls[nextUrl]) {
      isLast = true;
      finish();
      return;
    }
    loading = true;
    fetchedUrls[nextUrl] = true;
    showLoading();

    var currentFetchUrl = nextUrl;

    fetch(currentFetchUrl)
      .then(function (response) {
        if (!response.ok) throw new Error("fetch failed");
        return response.text();
      })
      .then(function (html) {
        var doc = new DOMParser().parseFromString(html, "text/html");

        // Determine next page state from response
        var responseGrid = doc.querySelector(".js-category-grid");
        if (responseGrid) {
          var responseIsLast = responseGrid.dataset.isLast === "true";
          var responseNextUrl = responseGrid.dataset.nextUrl || "";

          if (responseIsLast || !responseNextUrl || responseNextUrl === currentFetchUrl) {
            isLast = true;
            nextUrl = "";
          } else {
            nextUrl = responseNextUrl;
          }
        } else {
          isLast = true;
          nextUrl = "";
        }

        var cardHtmls = extractCardHtmls(doc);

        if (cardHtmls.length > 0) {
          grid.insertAdjacentHTML("beforeend", cardHtmls.join(""));

          if (typeof lucide !== "undefined") {
            lucide.createIcons();
          }
          if (typeof window.initQuickbuyDropdowns === "function") {
            window.initQuickbuyDropdowns();
          }
        } else {
          isLast = true;
        }

        loading = false;

        if (isLast) {
          finish();
        } else {
          hideLoading();
          loadMoreContainer.hidden = false;
        }
      })
      .catch(function () {
        loading = false;
        hideLoading();
        loadMoreContainer.hidden = false;
      });
  }

  loadMoreBtn.addEventListener("click", loadMore);

  var observer = new IntersectionObserver(
    function (entries) {
      if (entries[0].isIntersecting && !loading && !isLast) {
        loadMore();
      }
    },
    { rootMargin: "400px" },
  );
  observer.observe(loadMoreContainer);
};
