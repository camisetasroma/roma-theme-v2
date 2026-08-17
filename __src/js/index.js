//System
import { advertisingCarousel, headerAnimations } from "./modules/system/header";
import { menuSystem } from "./modules/system/menu";
import { searchSystem } from "./modules/system/search";
import { toastSystem } from "./modules/system/toast";
import { modalSystem } from "./modules/system/modal";
import { itemCardQuickbuy } from "./modules/system/item-card-quickbuy";
import { cartDrawerSystem } from "./modules/system/cart-drawer";

headerAnimations();
advertisingCarousel();
menuSystem();
searchSystem();
toastSystem();
modalSystem();
itemCardQuickbuy();
cartDrawerSystem();

//Category
import { categoryDropdown } from "./modules/category/category-dropdown";
import { categoryInfiniteScroll } from "./modules/category/category-infinite-scroll";
import { categoryFilters } from "./modules/category/category-filters";
import { categorySorting } from "./modules/category/category-sorting";

categoryDropdown();
categoryInfiniteScroll();
categoryFilters();
categorySorting();

//Home
import { heroBanner2Carousel } from "./modules/home/hero-banner-2-carousel";
import { productCarousel } from "./modules/home/product-carousel";

productCarousel();
heroBanner2Carousel();

//Product
import { productGallery } from "./modules/product/product-gallery";
import { productGalleryZoom } from "./modules/product/product-gallery-zoom";
import { productVariants } from "./modules/product/product-variants";
import { productAddToCart } from "./modules/product/product-add-to-cart";
import { productAccordion } from "./modules/product/product-accordion";

productGallery();
productGalleryZoom();
productVariants();
productAddToCart();
productAccordion();