{% raw %}@charset "UTF-8":

/*============================================================================
critical-css.tpl

    -This file contains all the theme critical styles wich will be loaded inline before the rest of the site
    -Rest of styling can be found in:
    	--static/css/style-async.css.tpl --> For non critical styles witch will be loaded asynchronously
      --static/css/style-colors.scss.tpl --> For color and font styles related to config/settings.txt

==============================================================================*/

/*============================================================================
  Table of Contents

  #External CSS libraries and plugins
    // Swiper 4.4.2
  #Critical path helpers
  #Components
    // Wrappers
    // Placeholders and preloaders
    // Buttons
    // Links
    // Headings
    // Titles and breadcrumbs
    // Texts
    // Icons
    // Sliders
    // Lists
    // Tables
    // Notifications
    // Images
    // Forms
    // Video
  #Header and nav
    // Ad Bar
    // Logo
    // Cart widget and search
  #Home page
    // Welcome message
  #Banners
    // Home banners
    // Informative banners
  #Product grid
    // Category header
    // Grid item
    // Labels
  #Product detail
  	// Image
  #Cart detail
    // Shipping Calculator
  #Contact page
    // Data contact
  #Blog
  #Media queries
    // Min width 768px
      //// Components
      //// Banners
      //// Home
      //// Product detail
      //// Helper classes
  
  #Helper classes
    // Margin and padding
    // Text
    // Align
    // Position
    // Image
    // Visibility
    // Float
    // Width

==============================================================================*/

/*============================================================================
  #External CSS libraries and plugins
==============================================================================*/
  
{# /* // Bootstrap Grid v4.1.3 - REMOVIDO - Usando Tailwind CSS */ #}

{# /* // Swiper 4.4.2 */ #}

.swiper-container{width:100%;margin:0 auto;position:relative;overflow:hidden;list-style:none;padding:0;z-index:1}.swiper-container-no-flexbox .swiper-slide{float:left}.swiper-container-vertical>.swiper-wrapper{-webkit-box-orient:vertical;-webkit-box-direction:normal;-webkit-flex-direction:column;-ms-flex-direction:column;flex-direction:column}.swiper-wrapper{position:relative;width:100%;height:100%;z-index:1;display:-webkit-box;display:-webkit-flex;display:-ms-flexbox;display:flex;-webkit-transition-property:-webkit-transform;transition-property:-webkit-transform;-o-transition-property:transform;transition-property:transform;transition-property:transform,-webkit-transform;-webkit-box-sizing:content-box;box-sizing:content-box}.swiper-container-android .swiper-slide,.swiper-wrapper{-webkit-transform:translate3d(0,0,0);transform:translate3d(0,0,0)}.swiper-container-multirow>.swiper-wrapper{-webkit-flex-wrap:wrap;-ms-flex-wrap:wrap;flex-wrap:wrap}.swiper-container-free-mode>.swiper-wrapper{-webkit-transition-timing-function:ease-out;-o-transition-timing-function:ease-out;transition-timing-function:ease-out;margin:0 auto}.swiper-slide{-webkit-flex-shrink:0;-ms-flex-negative:0;flex-shrink:0;width:100%;height:100%;position:relative;-webkit-transition-property:-webkit-transform;transition-property:-webkit-transform;-o-transition-property:transform;transition-property:transform;transition-property:transform,-webkit-transform}.swiper-slide-invisible-blank{visibility:hidden}.swiper-container-autoheight,.swiper-container-autoheight .swiper-slide{height:auto}.swiper-container-autoheight .swiper-wrapper{-webkit-box-align:start;-webkit-align-items:flex-start;-ms-flex-align:start;align-items:flex-start;-webkit-transition-property:height,-webkit-transform;transition-property:height,-webkit-transform;-o-transition-property:transform,height;transition-property:transform,height;transition-property:transform,height,-webkit-transform}.swiper-container-3d{-webkit-perspective:1200px;perspective:1200px}.swiper-container-3d .swiper-cube-shadow,.swiper-container-3d .swiper-slide,.swiper-container-3d .swiper-slide-shadow-bottom,.swiper-container-3d .swiper-slide-shadow-left,.swiper-container-3d .swiper-slide-shadow-right,.swiper-container-3d .swiper-slide-shadow-top,.swiper-container-3d .swiper-wrapper{-webkit-transform-style:preserve-3d;transform-style:preserve-3d}.swiper-container-3d .swiper-slide-shadow-bottom,.swiper-container-3d .swiper-slide-shadow-left,.swiper-container-3d .swiper-slide-shadow-right,.swiper-container-3d .swiper-slide-shadow-top{position:absolute;left:0;top:0;width:100%;height:100%;pointer-events:none;z-index:10}.swiper-container-3d .swiper-slide-shadow-left{background-image:-webkit-gradient(linear,right top,left top,from(rgba(0,0,0,.5)),to(rgba(0,0,0,0)));background-image:-webkit-linear-gradient(right,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:-o-linear-gradient(right,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:linear-gradient(to left,rgba(0,0,0,.5),rgba(0,0,0,0))}.swiper-container-3d .swiper-slide-shadow-right{background-image:-webkit-gradient(linear,left top,right top,from(rgba(0,0,0,.5)),to(rgba(0,0,0,0)));background-image:-webkit-linear-gradient(left,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:-o-linear-gradient(left,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:linear-gradient(to right,rgba(0,0,0,.5),rgba(0,0,0,0))}.swiper-container-3d .swiper-slide-shadow-top{background-image:-webkit-gradient(linear,left bottom,left top,from(rgba(0,0,0,.5)),to(rgba(0,0,0,0)));background-image:-webkit-linear-gradient(bottom,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:-o-linear-gradient(bottom,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:linear-gradient(to top,rgba(0,0,0,.5),rgba(0,0,0,0))}.swiper-container-3d .swiper-slide-shadow-bottom{background-image:-webkit-gradient(linear,left top,left bottom,from(rgba(0,0,0,.5)),to(rgba(0,0,0,0)));background-image:-webkit-linear-gradient(top,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:-o-linear-gradient(top,rgba(0,0,0,.5),rgba(0,0,0,0));background-image:linear-gradient(to bottom,rgba(0,0,0,.5),rgba(0,0,0,0))}.swiper-container-wp8-horizontal,.swiper-container-wp8-horizontal>.swiper-wrapper{-ms-touch-action:pan-y;touch-action:pan-y}.swiper-container-wp8-vertical,.swiper-container-wp8-vertical>.swiper-wrapper{-ms-touch-action:pan-x;touch-action:pan-x}.swiper-button-next,.swiper-button-prev{position:absolute;top:50%;z-index:10;width:30px;height:40px;margin-top:-20px;line-height:40px;color:#fff;text-align:center;cursor:pointer}.swiper-button-next.swiper-button-disabled,.swiper-button-prev.swiper-button-disabled{opacity:.35;cursor:auto;pointer-events:none}.swiper-button-prev,.swiper-container-rtl .swiper-button-next{left:10px;right:auto}.swiper-button-next,.swiper-container-rtl .swiper-button-prev{right:10px;left:auto}.swiper-button-lock{display:none}.swiper-pagination{position:absolute;text-align:center;-webkit-transition:.3s opacity;-o-transition:.3s opacity;transition:.3s opacity;-webkit-transform:translate3d(0,0,0);transform:translate3d(0,0,0);z-index:10}.swiper-pagination.swiper-pagination-hidden{opacity:0}.swiper-container-horizontal>.swiper-pagination-bullets,.swiper-pagination-custom,.swiper-pagination-fraction{bottom:20px;left:0;width:100%}.swiper-pagination-bullets-dynamic{overflow:hidden;font-size:0}.swiper-pagination-bullets-dynamic .swiper-pagination-bullet{-webkit-transform:scale(.33);-ms-transform:scale(.33);transform:scale(.33);position:relative}.swiper-pagination-bullets-dynamic .swiper-pagination-bullet-active{-webkit-transform:scale(1);-ms-transform:scale(1);transform:scale(1)}.swiper-pagination-bullets-dynamic .swiper-pagination-bullet-active-main{-webkit-transform:scale(1);-ms-transform:scale(1);transform:scale(1)}.swiper-pagination-bullets-dynamic .swiper-pagination-bullet-active-prev{-webkit-transform:scale(.66);-ms-transform:scale(.66);transform:scale(.66)}.swiper-pagination-bullets-dynamic .swiper-pagination-bullet-active-prev-prev{-webkit-transform:scale(.33);-ms-transform:scale(.33);transform:scale(.33)}.swiper-pagination-bullets-dynamic .swiper-pagination-bullet-active-next{-webkit-transform:scale(.66);-ms-transform:scale(.66);transform:scale(.66)}.swiper-pagination-bullets-dynamic .swiper-pagination-bullet-active-next-next{-webkit-transform:scale(.33);-ms-transform:scale(.33);transform:scale(.33)}.swiper-pagination-bullet{width:8px;height:8px;display:inline-block;border-radius:100%;background:#000;opacity:.2}button.swiper-pagination-bullet{border:none;margin:0;padding:0;-webkit-box-shadow:none;box-shadow:none;-webkit-appearance:none;-moz-appearance:none;appearance:none}.swiper-pagination-clickable .swiper-pagination-bullet{cursor:pointer}.swiper-pagination-bullet-active{opacity:1;background:#007aff}.swiper-container-vertical>.swiper-pagination-bullets{right:10px;top:50%;-webkit-transform:translate3d(0,-50%,0);transform:translate3d(0,-50%,0)}.swiper-container-vertical>.swiper-pagination-bullets .swiper-pagination-bullet{margin:6px 0;display:block}.swiper-container-vertical>.swiper-pagination-bullets.swiper-pagination-bullets-dynamic{top:50%;-webkit-transform:translateY(-50%);-ms-transform:translateY(-50%);transform:translateY(-50%);width:8px}.swiper-container-vertical>.swiper-pagination-bullets.swiper-pagination-bullets-dynamic .swiper-pagination-bullet{display:inline-block;-webkit-transition:.2s top,.2s -webkit-transform;transition:.2s top,.2s -webkit-transform;-o-transition:.2s transform,.2s top;transition:.2s transform,.2s top;transition:.2s transform,.2s top,.2s -webkit-transform}.swiper-container-horizontal>.swiper-pagination-bullets .swiper-pagination-bullet{margin:0 4px}.swiper-container-horizontal>.swiper-pagination-bullets.swiper-pagination-bullets-dynamic{left:50%;-webkit-transform:translateX(-50%);-ms-transform:translateX(-50%);transform:translateX(-50%);white-space:nowrap}.swiper-container-horizontal>.swiper-pagination-bullets.swiper-pagination-bullets-dynamic .swiper-pagination-bullet{-webkit-transition:.2s left,.2s -webkit-transform;transition:.2s left,.2s -webkit-transform;-o-transition:.2s transform,.2s left;transition:.2s transform,.2s left;transition:.2s transform,.2s left,.2s -webkit-transform}.swiper-container-horizontal.swiper-container-rtl>.swiper-pagination-bullets-dynamic .swiper-pagination-bullet{-webkit-transition:.2s right,.2s -webkit-transform;transition:.2s right,.2s -webkit-transform;-o-transition:.2s transform,.2s right;transition:.2s transform,.2s right;transition:.2s transform,.2s right,.2s -webkit-transform}.swiper-pagination-progressbar{background:rgba(0,0,0,.25);position:absolute}.swiper-pagination-progressbar .swiper-pagination-progressbar-fill{background:#007aff;position:absolute;left:0;top:0;width:100%;height:100%;-webkit-transform:scale(0);-ms-transform:scale(0);transform:scale(0);-webkit-transform-origin:left top;-ms-transform-origin:left top;transform-origin:left top}.swiper-container-rtl .swiper-pagination-progressbar .swiper-pagination-progressbar-fill{-webkit-transform-origin:right top;-ms-transform-origin:right top;transform-origin:right top}.swiper-container-horizontal>.swiper-pagination-progressbar,.swiper-container-vertical>.swiper-pagination-progressbar.swiper-pagination-progressbar-opposite{width:100%;height:4px;left:0;top:0}.swiper-container-horizontal>.swiper-pagination-progressbar.swiper-pagination-progressbar-opposite,.swiper-container-vertical>.swiper-pagination-progressbar{width:4px;height:100%;left:0;top:0}.swiper-pagination-white .swiper-pagination-bullet-active{background:#fff}.swiper-pagination-progressbar.swiper-pagination-white{background:rgba(255,255,255,.25)}.swiper-pagination-progressbar.swiper-pagination-white .swiper-pagination-progressbar-fill{background:#fff}.swiper-pagination-black .swiper-pagination-bullet-active{background:#000}.swiper-pagination-progressbar.swiper-pagination-black{background:rgba(0,0,0,.25)}.swiper-pagination-progressbar.swiper-pagination-black .swiper-pagination-progressbar-fill{background:#000}.swiper-pagination-lock{display:none}.swiper-lazy-preloader{width:42px;height:42px;position:absolute;left:50%;top:50%;margin-left:-21px;margin-top:-21px;z-index:10;-webkit-transform-origin:50%;-ms-transform-origin:50%;transform-origin:50%;-webkit-animation:swiper-preloader-spin 1s steps(12,end) infinite;animation:swiper-preloader-spin 1s steps(12,end) infinite}.swiper-lazy-preloader:after{display:block;content:'';width:100%;height:100%;background-image:url("data:image/svg+xml;charset=utf-8,%3Csvg%20viewBox%3D'0%200%20120%20120'%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20xmlns%3Axlink%3D'http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink'%3E%3Cdefs%3E%3Cline%20id%3D'l'%20x1%3D'60'%20x2%3D'60'%20y1%3D'7'%20y2%3D'27'%20stroke%3D'%236c6c6c'%20stroke-width%3D'11'%20stroke-linecap%3D'round'%2F%3E%3C%2Fdefs%3E%3Cg%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(30%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(60%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(90%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(120%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(150%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.37'%20transform%3D'rotate(180%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.46'%20transform%3D'rotate(210%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.56'%20transform%3D'rotate(240%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.66'%20transform%3D'rotate(270%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.75'%20transform%3D'rotate(300%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.85'%20transform%3D'rotate(330%2060%2C60)'%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E");background-position:50%;background-size:100%;background-repeat:no-repeat}.swiper-lazy-preloader-white:after{background-image:url("data:image/svg+xml;charset=utf-8,%3Csvg%20viewBox%3D'0%200%20120%20120'%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20xmlns%3Axlink%3D'http%3A%2F%2Fwww.w3.org%2F1999%2Fxlink'%3E%3Cdefs%3E%3Cline%20id%3D'l'%20x1%3D'60'%20x2%3D'60'%20y1%3D'7'%20y2%3D'27'%20stroke%3D'%23fff'%20stroke-width%3D'11'%20stroke-linecap%3D'round'%2F%3E%3C%2Fdefs%3E%3Cg%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(30%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(60%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(90%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(120%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.27'%20transform%3D'rotate(150%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.37'%20transform%3D'rotate(180%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.46'%20transform%3D'rotate(210%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.56'%20transform%3D'rotate(240%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.66'%20transform%3D'rotate(270%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.75'%20transform%3D'rotate(300%2060%2C60)'%2F%3E%3Cuse%20xlink%3Ahref%3D'%23l'%20opacity%3D'.85'%20transform%3D'rotate(330%2060%2C60)'%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E")}@-webkit-keyframes swiper-preloader-spin{100%{-webkit-transform:rotate(360deg);transform:rotate(360deg)}}@keyframes swiper-preloader-spin{100%{-webkit-transform:rotate(360deg);transform:rotate(360deg)}}.swiper-container-fade.swiper-container-free-mode .swiper-slide{-webkit-transition-timing-function:ease-out;-o-transition-timing-function:ease-out;transition-timing-function:ease-out}.swiper-container-fade .swiper-slide{pointer-events:none;-webkit-transition-property:opacity;-o-transition-property:opacity;transition-property:opacity}.swiper-container-fade .swiper-slide .swiper-slide{pointer-events:none}.swiper-container-fade .swiper-slide-active,.swiper-container-fade .swiper-slide-active .swiper-slide-active{pointer-events:auto}

/*============================================================================
  #Critical path helpers
==============================================================================*/

/* Hidden general content until rest of styling loads */
.visible-when-content-ready{
	visibility: hidden!important;
}
.display-when-content-ready{
	display: none!important;
}

/*============================================================================
  #Components
==============================================================================*/

{# /* // Wrappers */ #}

body{
  margin: 0;
  font-size: 12px;
}

{# /* // Placeholders and preloaders */ #}

.placeholder-line-medium{
  height: 25px;
}
.placeholder-icon{
  position: absolute;
  top: 50%;
  left: 50%;
  width: 20%;
  transform: translate(-50%, -50%);
  -webkit-transform: translate(-50%, -50%);
  -ms-transform: translate(-50%, -50%);
} 
.placeholder-full-height{
  position: relative;
  height: 100%;
}
.home-placeholder-icons{
  position: absolute;
  top: calc(50% - 75px);;
}
.product-placeholder-container{
  position: relative;
  max-height: 900px;
  margin-bottom: 20px;
  overflow: hidden;
}
.placeholder-shine{
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0.5;
  -moz-animation: placeholder-shine 1.5s infinite;
  -webkit-animation: placeholder-shine 1.5s infinite;
  animation: placeholder-shine 1.5s infinite;
}
@keyframes placeholder-shine {
  0%{
    opacity: 0.1;
  }
  50% {
    opacity: 0.5;
  }
  100% {
    opacity: 0.1;
  }
}
.placeholder-fade{
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0.1;
  -moz-animation: placeholder-fade 1.5s infinite;
  -webkit-animation: placeholder-fade 1.5s infinite;
  animation: placeholder-fade 1.5s infinite;
}
@keyframes placeholder-fade {
  0%{
    opacity: 0.1;
  }
  50% {
    opacity: 0.2;
  }
  100% {
    opacity: 0.1;
  }
}
.blur-up {
  position: absolute;
  top: 0;
  -webkit-filter: blur(2px);
  filter: blur(2px);
  -moz-filter: blur(2px);
  -ms-filter: blur(2px);
  -o-filter: blur(2px);
  transition: opacity .2s, -webkit-filter .2s;
}
.blur-up-big {
  -webkit-filter: blur(6px);
  filter: blur(6px);
  -moz-filter: blur(6px);
  -ms-filter: blur(6px);
  -o-filter: blur(6px);
  transition: filter .2s, -webkit-filter .2s;
}
.blur-up-huge {
  -webkit-filter: blur(8px);
  filter: blur(8px);
  -moz-filter: blur(8px);
  -ms-filter: blur(8px);
  -o-filter: blur(8px);
  transition: filter .2s, -webkit-filter .2s;
}
.blur-up.lazyloaded,
.blur-up-big.lazyloaded,
.blur-up-huge.lazyloaded,
.blur-up.swiper-lazy-loaded,
.blur-up-big.swiper-lazy-loaded,
.blur-up-huge.swiper-lazy-loaded {
  -webkit-filter: none;
  filter: none;
  -moz-filter: none;
  -ms-filter: none;
  -o-filter: none;
}
.preloader-bg-img,
.product-slider-image.blur-up{
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  -webkit-filter: blur(4px);
  filter: blur(4px);
  -moz-filter: blur(4px);
  -ms-filter: blur(4px);
  -o-filter: blur(4px);
  transition: filter .2s, -webkit-filter .2s, opacity .2s;
  /* Avoid strange image behaviour on filters in IOS */
  -webkit-perspective: 1000;
  -webkit-backface-visibility: hidden;
}
.product-slider-image.blur-up{
  left: 50%;
  width: auto;
}
.swiper-lazy-loaded + .preloader-bg-img,
.lazyloaded + .blur-up{
  opacity: 0;
  -webkit-filter: none;
  filter: none;
  -moz-filter: none;
  -ms-filter: none;
  -o-filter: none;
}
.fade-in {
  opacity: 0;
  transition: opacity .2s;
}
.fade-in.lazyloaded,
.fade-in.swiper-lazy-loaded {
  opacity: 1;
}
.lazyloaded + .blur-up {
  opacity: 0;
  pointer-events: none;
}

.lazyloaded + .placeholder-shine,
.lazyloaded + .placeholder-fade,
.swiper-lazy-loaded + .placeholder-fade,
.lazyloaded + .item-image-secondary + .placeholder-fade{
  display: none;
}

.spinner-ellipsis {
  position: relative;
  display: inline-block;
  width: 64px;
  height: 40px;
}
.spinner-ellipsis .point {
  position: absolute;
  top: 15px;
  width: 11px;
  height: 11px;
  border-radius: 50%;
  animation-timing-function: cubic-bezier(0, 1, 1, 0);
}
.spinner-ellipsis .point:nth-child(1) {
  left: 6px;
  animation: spinner-ellipsis1 0.6s infinite;
}
.spinner-ellipsis .point:nth-child(2) {
  left: 6px;
  animation: spinner-ellipsis2 0.6s infinite;
}
.spinner-ellipsis .point:nth-child(3) {
  left: 26px;
  animation: spinner-ellipsis2 0.6s infinite;
}
.spinner-ellipsis .point:nth-child(4) {
  left: 45px;
  animation: spinner-ellipsis3 0.6s infinite;
}
@keyframes spinner-ellipsis1 {
  0% {
    transform: scale(0);
  }
  100% {
    transform: scale(1);
  }
}
@keyframes spinner-ellipsis3 {
  0% {
    transform: scale(1);
  }
  100% {
    transform: scale(0);
  }
}
@keyframes spinner-ellipsis2 {
  0% {
    transform: translate(0, 0);
  }
  100% {
    transform: translate(19px, 0);
  }
}

{# /* // Animations */ #}

.transition-up {
  opacity: 0;
}

{# /* // Buttons */ #}

.btn-whatsapp {
  position: fixed;
  bottom: 10px;
  right: 10px;
  z-index: 100;
  color: white;
  background-color:#4dc247;
  box-shadow: 2px 2px 6px rgba(0,0,0,0.4);
  border-radius: 50%;
}

.btn-whatsapp svg{
  width: 45px;
  height: 45px;
  padding: 10px;
  fill: white;
  vertical-align:middle;
}

{# /* // Links */ #}

a {
  text-decoration: none;
}

{# /* // Headings */ #}

.page-header-text {
  margin: .5rem 0 0 0;
  font-size: 12px;
  text-align: center;
}

{# /* // Icons */ #}

.icon-inline {
  display: inline-block;
  font-size: inherit;
  height: 1em;
  overflow: visible;
  vertical-align: -.125em;
}

.icon-xs {
  font-size: .75em;
}
.icon-md {
  font-size: .875em; 
}
.icon-lg {
  font-size: 1.33333em;
  line-height: .75em;
  vertical-align: -.0667em; 
}
.icon-2x {
  font-size: 2em;  
}
.icon-3x {
  font-size: 3em; 
}
.icon-4x {
  font-size: 4em;  
}
.icon-5x {
  font-size: 5em;  
}
.icon-6x {
  font-size: 6em;  
}
.icon-7x {
  font-size: 7em; 
}
.icon-8x {
  font-size: 8em;  
}
.icon-9x {
  font-size: 9em;  
}

.icon-inline.icon-lg{
  vertical-align: -.225em
}
.icon-inline.icon-w {
  text-align: center;
  width: 1.25em
}
.icon-inline.icon-w-1{
  width:.0625em
}
.icon-inline.icon-w-2{
  width:.125em
}
.icon-inline.icon-w-3{
  width:.1875em
}
.icon-inline.icon-w-4{
  width:.25em
}
.icon-inline.icon-w-5{
  width:.3125em
}
.icon-inline.icon-w-6{
  width:.375em
}
.icon-inline.icon-w-7{
  width:.4375em
}
.icon-inline.icon-w-8{
  width:.5em
}
.icon-inline.icon-w-9{
  width:.5625em
}
.icon-inline.icon-w-10{
  width:.625em
}
.icon-inline.icon-w-11{
  width:.6875em
}
.icon-inline.icon-w-12{
  width:.75em
}
.icon-inline.icon-w-13{
  width:.8125em
}
.icon-inline.icon-w-14{
  width:.875em
}
.icon-inline.icon-w-15{
  width:.9375em
}
.icon-inline.icon-w-16{
  width:1em
}
.icon-inline.icon-w-17{
  width:1.0625em
}
.icon-inline.icon-w-18{
  width:1.125em
}
.icon-inline.icon-w-19{
  width:1.1875em
}
.icon-inline.icon-w-20{
  width:1.25em
}
.icon-spin{
  -webkit-animation:icon-spin 2s infinite linear;
  animation:icon-spin 2s infinite linear
}
@-webkit-keyframes icon-spin {
  0% {
    -webkit-transform: rotate(0);
    transform: rotate(0)
  }
  100% {
    -webkit-transform: rotate(360deg);
    transform: rotate(360deg)
  }
}

@keyframes icon-spin {
  0% {
    -webkit-transform: rotate(0);
    transform: rotate(0)
  }
  100% {
    -webkit-transform: rotate(360deg);
    transform: rotate(360deg)
  }
}

{# /* // Sliders */ #}

.section-slider {
  height: 100vh;
}
.nube-slider-home {
  height: 100%;
}
.swiper-wrapper.disabled {
  transform: translate3d(0px, 0, 0) !important;
}
.slide-container{
  overflow: hidden;
}
.slider-slide {
  height: 100%;
  background-position: center;
  background-size: cover; 
  overflow: hidden;
}
.slider-image {
  position: relative;
  z-index: 1;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.swiper-pagination-fraction{
  position: absolute;
  left: 50%;
  width: auto;
  padding: 5px;
  transform: translateX(-50%);
  font-size: 18px;
  background: #00000045;
  color: #ffffff85;
}

.swiper-text {
  position: absolute;
  z-index: 1;
  top: 50%;
  bottom: auto;
  left: 50%;
  width: 92%;
  padding: 0 25px;
  text-align: center;
  transform: translate(-50%,-50%);
}
.swiper-title {
  font-size: 36px;
}

{# /* // Lists */ #}

.list {
  padding: 0;
  margin: 0;
  list-style-type: none;
}

.list-unstyled{
  padding: 0;
  margin: 0;
  list-style-type: none;
}

.list-inline li{
  display: inline-flex;
}

{# /* // Tables */ #}

.table{
  width: 100%;
  border-collapse: collapse;
  border-spacing: 0;
}
.table thead th{
  padding: 8px;
}
.table thead th:first-of-type{
  padding-left: 0;
}
.table td{
  padding: 8px;
  text-align: left;
}

{# /* // Notifications */ #}

.notification{
  padding: 10px;
  text-align: center;
}
.notification-floating {
  position: absolute;
  top: 100%;
  right: 15px;
  z-index: 2000;
  width: calc(100% - 30px);
  margin-top: -20px;
}
.notification-fixed {
  position: fixed;
  right: 0;
  left: 15px;
}
.notification-close {
  position: absolute;
  top: 20px;
  right: 20px;
  padding: 0 5px;
}
.notification-floating .notification {
  box-shadow: 0 0 5px 0 rgba(0, 0, 0, .1), 0 2px 3px 0 rgba(0, 0, 0, .06);
}
.notification-fixed-bottom {
  position: fixed;
  bottom: 0;
  left: 0;
  z-index: 999;
  width: 100%;
}

.notification-fixed-bottom-right {
  position: fixed;
  top: initial;
  bottom: 0;
  right: 0;
  z-index: 999;
  width: 100%;
}

{# /* // Images */ #}

/* Used for images that have a placeholder before it loads. The image container should have a padding-bottom inline with the result of (image height/ image width) * 100 */
.img-absolute {
  position: absolute;
  left: 0;
  width: 100%;
  height: auto;
  vertical-align: middle;
  text-indent: -9999px;
  z-index: 1;
}

.img-absolute-centered{
  left: 50%;
  transform: translateX(-50%)!important;
  -webkit-transform: translateX(-50%)!important;
  -ms-transform: translateX(-50%)!important;
}

.card-img{
  margin: 0 5px 5px 0;
  border: 1px solid #00000012;
}
.card-img-small{
  height: 25px;
}
.card-img-medium{
  height: 35px;
}
.card-img-big{
  height: 50px;
}
.card-img-square-container {
  position: relative;
  width: 100%;
  padding-top: 100%;
}
.card-img-square {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.card-img-pill {
  position: absolute;
  bottom: 0;
  left: 0;
  z-index: 999;
}

{# /* // Forms */ #}

.form-group {
  position: relative;
  width: 100%;
}
.form-group .form-select-icon,
.form-select .form-select-icon{
  position: absolute;
  bottom: 12px;
  right: 0;
  pointer-events: none;
}
.form-select .form-select-icon {
  top: 50%;
  bottom: initial;
  transform: translateY(-50%);
  -webkit-transform: translateY(-50%);
  -ms-transform: translateY(-50%);
}
.form-row {
  width: auto;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  -ms-flex-wrap: wrap;
  flex-wrap: wrap;
  margin-right: -5px;
  margin-left: -5px;
  clear: both;
}

.form-row > .col,
.form-row > [class*=col-]{
  padding-right: 5px;
  padding-left: 5px;
}

.form-label {
  display: block;
  font-size: 10px;
  text-transform: uppercase;
}

.form-toggle-eye {
  position: absolute;
  top: 20px;
  right: 2px;
  display: inline-block;
  padding: 10px;
  font-size: 16px;
  background: none;
  border: 0;
}

.radio-button {
  margin-bottom: 0;
  -webkit-tap-highlight-color: rgba(0,0,0,0);
  cursor: pointer;
}

.radio-button.disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.radio-button.disabled input[type="radio"] {
  cursor: not-allowed;
}

.radio-button-content {
  position: relative;
  width: 100%;
  float: left;
  padding: 15px; 
  clear: both;
  box-sizing: border-box;
}

.radio-button-icons-container {
  position: absolute;
  top: 14px;
  left: 10px;
}

.radio-button-icons {
  position: relative;
  float: left;
}

.radio-button-icon {
  width: 16px;
  height: 16px;
  border-radius: 50%;
}

.radio-button input[type="radio"] {
  display: none;
}

.radio-button input[type="radio"] + .radio-button-content .unchecked {
  float: left;
}

.radio-button input[type="radio"] + .radio-button-content .checked {
  position: absolute;
  top: 8px;
  left: 8px;
  width: 0;
  height: 0;      
  -webkit-transform: translate(-50%,-50%);
  -ms-transform: translate(-50%,-50%);
  -moz-transform: translate(-50%,-50%);
  -o-transform: translate(-50%,-50%);
  transform: translate(-50%,-50%);
  -webkit-transition: all 0.2s;
  -ms-transition: all 0.2s;
  -moz-transition: all 0.2s;
  -o-transition: all 0.2s;
  transition: all 0.2s;
}

.radio-button input[type="radio"]:checked + .radio-button-content .checked {
  width: 8px;
  height: 8px;
}

.radio-button-label {
  width: 100%;
  float: left;
  padding-left: 30px;
}

.radio-button-item:last-of-type .radio-button {
  margin-bottom: 0;
}

{# /* // Video */ #}

.embed-responsive {
  position: relative;
  display: block;
  height: 0;
  padding: 0;
  overflow: hidden;
}
.embed-responsive.embed-responsive-16by9 {
  padding-bottom: 56.25%;
}
.embed-responsive .embed-responsive-item,
.embed-responsive embed,
.embed-responsive  iframe,
.embed-responsive  object,
.embed-responsive  video {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: 0;
}
.video-player {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1;
  width: 100%;
  height: 100%;
  cursor: pointer;
}
.video-player-icon {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 60px;
  height: 60px;
  margin: -30px 0 0 -30px;
  padding: 0;
  font-size: 60px;
  line-height: 30px;
  text-align: center;
  pointer-events: none;
}
.video-image {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 100%;
  height: auto;
  transform: translate(-50%, -50%);
  -webkit-transform: translate(-50%, -50%);
  -ms-transform: translate(-50%, -50%);
}

/*============================================================================
  #Header and nav
==============================================================================*/

.head-main {
  position: relative;
  z-index: 1040;  
  -webkit-backface-visibility: hidden;
  -webkit-transform: scale(1);
}

.head-fix {
  position: sticky;
  top:0;
  width: 100%;
} 

.head-transparent-fixed {
  position: fixed;
}

.head-absolute{
  position: absolute;
  width: 100%;
}

.nav-dropdown-content {
  visibility: hidden;
  opacity: 0;
  transition: visibility 0s linear .3s, opacity .3s linear;
}

{# /* // Ad Bar */ #}

.section-advertising {
  padding: 5px 0;
}

{# /* // Logo */ #}

.logo-text-container {
  max-width: 450px;
  margin: auto;
  padding: 5px;
  text-align: center;
}

.logo-img-container {
  max-width: 450px;
  margin: auto;
  text-align: center;
}
.logo-img{
  width: auto;
  height: auto;
  margin: 15px 0;
  vertical-align: middle;
  max-width: 40vw;
  max-height: 80px;
}

{# /* // Cart widget and search */ #}

.utilities-item {
  display: inline-block;
  padding: 15px 4px;
  font-size: 18px;
}    

.cart-widget-amount {
  display: inline-block;
  font-size: 14px;
}
    
   

/*============================================================================
  #Home Page
==============================================================================*/

{# /* // Welcome message */ #}

.section-welcome-home {
  padding: 70px 0;
  text-align: center;
}

.welcome-title {
  margin-bottom: 15px;
  text-transform: uppercase;
}
.welcome-text {
  line-height: 18px;
}

/*============================================================================
  #Banners
==============================================================================*/

{# /* // Home banners */ #}

.textbanner {
  position: relative;
  margin-bottom: 20px;
  overflow: hidden;
}
.textbanner-link {
  display: block;
  width: 100%;
  height: 100%;
}
.textbanner-image {
  position: relative;
  padding-top: 100%;
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
}
.textbanner-image-background {
  position: absolute;
  top: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.textbanner-image-empty:after {
  position: absolute;
  top: 0;
  width: 100%;
  height: 100%;
  content: '';
}
.textbanner-text {  
  position: relative;
  padding: 0 5% 45px 5%;
  text-align: center;
}
.textbanner-text.over-image {
  position: absolute;
  top: 50%;
  left: 50%;
  z-index: 9;
  width: 100%;
  color: #fff;
  transform: translate(-50%, -50%);
}
.textbanner-title {
  margin-bottom: 15px;
  line-height: 34px;
}
.textbanner-paragraph {
  display: -webkit-box;
  margin-bottom: 15px;
  line-height: 18px;
  overflow: hidden;
  text-overflow: ellipsis;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
}

{# /* // Informative banners */ #}

.section-informative-banners {
  padding: 50px 0;
  text-align: center;
}

.service-icon {
  margin: 10px 0;
}

.service-item .service-icon-big {
  font-size: 30px;
}

.service-title {
  margin: 0 0 5px 0;
}

.service-pagination {
  position: relative;
  margin-top: 5px;
}

/*============================================================================
  #Product grid
==============================================================================*/

{# /* // Category controls */ #}

.category-controls-sticky-detector {
  height: 1px;
}

.category-controls {
  position: sticky;
  z-index: 100;
  padding: 15px 0;
}

{# /* // Category header */ #}

.filter-link {
  display: inline-block;
  width: 100%;
  padding: 10px 0;
}

{# /* // Grid item */ #}

.item {
  margin-bottom: 50px;
  text-align: center;
}
.item-image {
  position: relative;
  overflow: hidden;
  max-height: 500px;
}
.item-image img{
  height: 100%;
  width: auto;
  max-height: 500px;
}
.item-image-slide img{
  max-width: 100%;
  object-fit: contain;
  object-position: top;
}
.item-thumbnail {
  display: block;
  width: 100%;
}
.item-image:not(.product-item-image-secondary).lazyloaded {
  z-index: 9;
  opacity: 1;
}
.item-image-secondary,
.item-image-secondary.fade-in.lazyloaded  {
  display: none;
  opacity: 0;
}
.product-item-secondary-images-loaded:not(.product-item-secondary-images-disabled):hover .item-image-featured{
  opacity: 0;
  transition-delay: .05s;
}
.product-item-secondary-images-loaded:not(.product-item-secondary-images-disabled):hover .item-image-featured ~ .item-image-secondary {
  opacity: 1;
}
.item-colors {
  position: absolute;
  bottom: 0;
  z-index: 9;
  width: 100%;
  padding: 5px 0;
}
.item-colors-bullet {
  display: inline-block;
  min-width: 18px;
  height: 18px;
  margin: 0 3px;
  font-size: 10px;
  text-transform: uppercase;
  line-height: 19px;
  vertical-align: top;
  border-radius: 18px;
  cursor: pointer;
  opacity: 0.8;
  -webkit-transition: all 0.4s ease;
  -ms-transition: all 0.4s ease;
  -moz-transition: all 0.4s ease;
  -o-transition: all 0.4s ease;
  transition: all 0.4s ease;
}
.item-colors-bullet:hover,
.item-colors-bullet.selected {
  opacity: 1;
}
.item-name {
  font-size: 11px;
  line-height: 15px;
  text-transform: uppercase;
  letter-spacing: 1px;
  text-overflow: ellipsis;
  overflow: hidden;
  -webkit-line-clamp: 2;
  display: -webkit-box;
  -webkit-box-orient: vertical;
}
.item-price-container { 
  margin-bottom: 10px;
  font-size: 12px;
}
.item-installments { 
  font-size: 10px;
}
.item-product-reduced .item-image {
  height: 145px;
}
.item-product-reduced .item-image img {
  width: 100%;
  height: 145px;
  object-fit: cover;
}

.item-more-images-message {
  position: absolute;
  top: 10px;
  right: 15px;
  z-index: 1;
  opacity: 0;
  text-transform: uppercase;
  transform: initial;
  transition: all 0.2s ease;
}

{# /* // Labels */ #}

.labels {
  position: absolute;
  top: 0;
  z-index: 9;
}

.label {
  width: fit-content;
  margin-bottom: 10px;
  padding: 5px 10px; 
  font-size: 12px;
  text-align: left;
}

/*============================================================================
  #Product detail
==============================================================================*/

{# /* // Image */ #}

.nube-slider-product {
  max-height: 900px;
  overflow: hidden;
}

.product-slider-image {
  width: auto;
  height: 100%;
  max-width: 100%;
  max-height: 900px;
}

.product-video-container {
  display: block;
  width: 100%;
  height: 100%;
}
.product-video {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  -webkit-box-align: center;
  -ms-flex-align: center;
  align-items: center;
}
.product-video .embed-responsive {
  width: 100%;
  height: 100%;
  padding-bottom: 0;
}
.product-video .video-image{
  width: auto;
  height: 100%;
}

/*============================================================================
  #Cart detail
==============================================================================*/

{# /* // Shipping Calculator */ #}

.free-shipping-title {
  position: relative;
  width: 100%;
  height: 55px;
}
.shipping-calculator-head.with-zip {
  height: 65px;
}
.shipping-calculator-head.with-zip.with-free-shipping {
  height: 110px;
}
.shipping-calculator-head.with-form {
  height: 110px;
}
.shipping-calculator-head.with-form + .shipping-spinner-container {
  margin-top: -20px;
}
.shipping-calculator-head.with-error {
  height: 155px;
}

/*============================================================================
  #Contact page
==============================================================================*/

{# /* // Data contact */ #}

.contact-info {
  margin-top: 0;
  padding-left: 0;
}

.contact-icon {
  display: block;
  margin: 0 auto 10px auto;
}

.contact-item {
  list-style: none;
}

.contact-link {
  list-style: none;
}

/*============================================================================
#Blog
==============================================================================*/

.post-item-image-container {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.post-item-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.post-item-title,
.post-item-summary {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.5em;
}

.post-content,
.post-content p {
  font-size: 16px;
  line-height: 1.8rem;
}

.post-content img {
  max-width: 100%;
  height: auto;
}

.post-content h1,
.post-content h2,
.post-content h3,
.post-content h4,
.post-content h5,
.post-content h6 {
  margin: 2rem 0 1rem 0;
  line-height: initial;
}

.post-content h1,
.post-content .h1 {
  font-size: 28px;
}

.post-content h2,
.post-content .h2 {
  font-size: 24px;
}

.post-content h3,
.post-content .h3 {
  font-size: 20px;
}

.post-content h4,
.post-content .h4 {
  font-size: 18px;
}

.post-content h5,
.post-content .h5 {
  font-size: 16px;
}

.post-content h6,
.post-content .h6 {
  font-size: 14px;
}


/*============================================================================
  #Media queries
==============================================================================*/

{# /* // Min width 768px */ #}

@media (min-width: 768px) { 

  {# /* //// Nav */ #}

  .logo-img {
    max-width: 320px;
  }

  {# /* //// Placeholders */ #}

  .blur-up {
    -webkit-filter: blur(4px);
    filter: blur(4px);
    -moz-filter: blur(4px);
    -ms-filter: blur(4px);
    -o-filter: blur(4px);
    transition: filter .5s, -webkit-filter .2s;
  }

  {# /* //// Components */ #}

  .container-narrow {
    max-width: 680px;
  }
  
  .h1-md {
    font-size: 28px;
    font-weight: 700;
  }

  .h2-md {
    font-size: 24px;
    font-weight: 700;
  }

  .h3-md {
    font-size: 20px;
    font-weight: 700;
  }

  .h4-md {
    font-size: 18px;
    font-weight: 700;
  }

  .h5-md {
    font-size: 16px;
    font-weight: 700;
  }

  .h6-md {
    font-size: 14px;
    font-weight: 700;
  }

  .font-md-normal {
    font-size: 14px;
  }


  {# /* //// Banners */ #}

  {# /* Home Banners */ #}

  .textbanner-text {  
    padding: 30px 20%;
  }

  {# /* //// Home */ #}

  {# /* //// Product grid */ #}

  .category-controls {
    position: relative;
    padding: 0;
  }

  .item-colors {
    padding: 10px 0;
  }

  .item-product-reduced .item-image,
  .item-product-reduced .item-image img {
    height: 180px;
  }

  .item-slider-controls-container {
    opacity: 0;
    transition: opacity .2s ease;
  }
  .item-slider-controls-container.swiper-button-disabled {
    opacity: 0;
    cursor: auto;
  }
  .item-image:hover .item-slider-controls-container:not(.swiper-button-disabled) {
    opacity: 1;
  }


  {# /* //// Product detail */ #}

  .product-video .video-image,
  .product-video .embed-responsive {
    width: 100%;
    height: auto;
  }

  .product-video .embed-responsive {
    padding-bottom: 56.25%;
  }

  {# /* //// Helper classes */ #}

  {# /* // Float */ #}

  .float-md-left{float:left!important}.float-md-right{float:right!important}.float-md-none{float:none!important}

  {# /* // Position */ #}

  .position-relative-md{position:relative!important;}.position-sticky-md{position:sticky!important;position:-webkit-sticky!important;}
}

{% endraw %}