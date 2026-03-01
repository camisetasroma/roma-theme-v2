//System
import { advertisingCarousel, headerAnimations } from "./modules/system/header";
import { menuSystem } from "./modules/system/menu";
import { searchSystem } from "./modules/system/search";
import { toastSystem } from "./modules/system/toast";

headerAnimations();
advertisingCarousel();
menuSystem();
searchSystem();
toastSystem();

//Category
import { categoryDropdown } from "./modules/category/category-dropdown";
import { categoryInfiniteScroll } from "./modules/category/category-infinite-scroll";

categoryDropdown();
categoryInfiniteScroll();

//Home
import { heroBanner2Carousel } from "./modules/home/hero-banner-2-carousel";
import { productCarousel } from "./modules/home/product-carousel";

productCarousel();
heroBanner2Carousel();