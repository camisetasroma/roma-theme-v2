//System
import { advertisingCarousel, headerAnimations } from "./modules/system/header";
import { menuSystem } from "./modules/system/menu";
import { modalSystem } from "./modules/system/modals";
import { toastSystem } from "./modules/system/toasts";
import { searchSystem } from "./modules/system/search";

headerAnimations();
advertisingCarousel();
menuSystem();
modalSystem();
toastSystem();
searchSystem();

//Home
import { heroBanner2Carousel } from "./modules/home/hero-banner-2-carousel";
import { productCarousel } from "./modules/home/product-carousel";
import { welcomeCouponToast } from "./modules/home/welcome-coupon-toast";

welcomeCouponToast();
productCarousel();
heroBanner2Carousel();