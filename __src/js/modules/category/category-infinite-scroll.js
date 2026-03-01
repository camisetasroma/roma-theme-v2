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

  function escHtml(str) {
    var div = document.createElement("div");
    div.textContent = str || "";
    return div.innerHTML;
  }

  function parseMoney(str) {
    if (!str) return 0;
    return parseFloat(str.replace(/[^\d,]/g, "").replace(",", ".")) || 0;
  }

  function extractProducts(doc) {
    var products = [];

    // The fetched page renders with our new category.tpl (item-card.tpl format)
    var categoryGrid = doc.querySelector(".js-category-grid");
    if (categoryGrid) {
      // item-card.tpl cards: direct children with data-product-id
      var cards = categoryGrid.querySelectorAll("[data-product-id]");
      cards.forEach(function (card) {
        var id = card.dataset.productId;
        if (!id) return;

        // item-card.tpl structure: first <a> is image link, second <a> is name link
        var links = card.querySelectorAll("a[href]");
        var url = links.length > 0 ? links[0].getAttribute("href") : "";

        // Name: second <a> inside the info container
        var nameEl = links.length > 1 ? links[1] : links[0];
        var name = nameEl ? nameEl.textContent.trim() : "";

        // Image
        var imgEl = card.querySelector("img");
        var imgSrc = imgEl
          ? imgEl.dataset.src || imgEl.getAttribute("src") || ""
          : "";
        var imgAlt = imgEl ? imgEl.getAttribute("alt") || "" : "";

        // Price: span with font-extrabold
        var priceEl = card.querySelector("span.text-secondary.font-extrabold");
        if (!priceEl) {
          // Fallback: find by class pattern in compiled CSS
          var spans = card.querySelectorAll("span");
          for (var s = 0; s < spans.length; s++) {
            if (spans[s].className.indexOf("font-extrabold") !== -1) {
              priceEl = spans[s];
              break;
            }
          }
        }
        var price = priceEl ? priceEl.textContent.trim() : "";

        // Compare price: span with text-fg-muted that contains a price
        var comparePrice = "";
        var mutedSpans = card.querySelectorAll("span.text-fg-muted, span.relative");
        for (var m = 0; m < mutedSpans.length; m++) {
          var txt = mutedSpans[m].textContent.trim();
          if (txt && txt.match(/[\d,.]/)) {
            comparePrice = txt;
            break;
          }
        }

        // Badges/labels: spans inside the badge container (first absolute div)
        // We skip these for loaded items - discount badge is computed from prices

        products.push({
          id: id,
          name: name,
          price: price,
          comparePrice: comparePrice,
          showPrice: price.length > 0,
          url: url,
          imgSrc: imgSrc,
          imgAlt: imgAlt,
        });
      });

      return products;
    }

    // Fallback: old item.tpl format (js-product-table)
    var oldGrid = doc.querySelector(".js-product-table");
    if (oldGrid) {
      var items = oldGrid.querySelectorAll(".js-item-product");
      items.forEach(function (item) {
        var id = item.dataset.productId;
        if (!id) return;

        var nameEl = item.querySelector(".js-item-name");
        var priceEl = item.querySelector(".js-price-display");
        var comparePriceEl = item.querySelector(".js-compare-price-display");
        var linkEl = item.querySelector("a.item-link");
        var imgEl = item.querySelector(".js-item-image");

        var compareText = "";
        if (
          comparePriceEl &&
          comparePriceEl.style.display !== "none"
        ) {
          compareText = comparePriceEl.textContent.trim();
        }

        products.push({
          id: id,
          name: nameEl ? nameEl.textContent.trim() : "",
          price: priceEl ? priceEl.textContent.trim() : "",
          comparePrice: compareText,
          showPrice: !item.classList.contains("no-price"),
          url: linkEl ? linkEl.getAttribute("href") : "",
          imgSrc: imgEl
            ? imgEl.dataset.src || imgEl.getAttribute("src") || ""
            : "",
          imgAlt: imgEl ? imgEl.getAttribute("alt") || "" : "",
        });
      });
    }

    return products;
  }

  function renderCard(product) {
    var badgesHtml = "";

    if (product.comparePrice && product.showPrice) {
      var current = parseMoney(product.price);
      var compare = parseMoney(product.comparePrice);
      if (compare > 0 && current > 0) {
        var discount = Math.round(((compare - current) / compare) * 100);
        badgesHtml +=
          '<span class="flex items-center justify-center [background:rgba(0,0,0,0.05)] px-2 py-0.5 rounded text-secondary font-sans text-[10px] font-semibold">-' +
          discount +
          "%</span>";
      }
    }

    var priceHtml = "";
    if (product.showPrice && product.price) {
      priceHtml = '<div class="flex items-center gap-2">';
      priceHtml +=
        '<span class="text-secondary font-sans text-base font-extrabold leading-[120%]">' +
        escHtml(product.price) +
        "</span>";
      if (product.comparePrice) {
        priceHtml +=
          '<span class="relative text-fg-muted font-sans text-base leading-[120%]">' +
          escHtml(product.comparePrice) +
          '<span class="absolute top-1/2 left-0 w-full h-px bg-fg-muted"></span></span>';
      }
      priceHtml += "</div>";
    }

    return (
      '<div class="flex flex-col justify-center items-start" data-product-id="' +
      escHtml(product.id) +
      '" data-store="product-item-' +
      escHtml(product.id) +
      '">' +
      '<div class="flex flex-col items-start relative w-full overflow-hidden rounded-sm">' +
      '<div class="flex items-start content-start gap-1.25 flex-wrap absolute top-0 left-0 px-4 py-2 z-10">' +
      badgesHtml +
      "</div>" +
      '<a href="' +
      escHtml(product.url) +
      '" title="' +
      escHtml(product.name) +
      '" class="block w-full">' +
      '<img src="' +
      escHtml(product.imgSrc) +
      '" class="w-full h-auto object-cover" alt="' +
      escHtml(product.imgAlt) +
      '" />' +
      "</a>" +
      '<button class="flex w-8 h-8 justify-center items-center gap-2.5 shrink-0 [background:rgba(0,0,0,0.05)] rounded-lg absolute bottom-2 right-2 z-10" aria-label="Agregar al carrito">' +
      '<i data-lucide="shopping-cart" class="w-4 h-4 text-secondary"></i>' +
      "</button>" +
      "</div>" +
      '<div class="flex flex-col items-start gap-1.5 shrink-0 self-stretch p-2">' +
      '<a href="' +
      escHtml(product.url) +
      '" title="' +
      escHtml(product.name) +
      '" class="self-stretch text-secondary font-sans text-[13px] font-medium leading-[120%] no-underline line-clamp-2 min-h-[calc(2*13px*1.2)]">' +
      escHtml(product.name) +
      "</a>" +
      priceHtml +
      "</div>" +
      "</div>"
    );
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

        var products = extractProducts(doc);

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
          // No grid in response = something wrong, stop
          isLast = true;
          nextUrl = "";
        }

        if (products.length > 0) {
          var cardsHtml = "";
          products.forEach(function (product) {
            cardsHtml += renderCard(product);
          });
          grid.insertAdjacentHTML("beforeend", cardsHtml);

          if (typeof lucide !== "undefined") {
            lucide.createIcons();
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
