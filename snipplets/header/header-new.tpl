{# Site Overlay #}
<div class="js-overlay site-overlay" style="display: none;"></div>

{# New Header #}
<header
    class="js-new-header fixed top-0 left-0 right-0 z-50 flex flex-col w-full transition-all duration-300"
    data-state="transparent"
    data-store="head"
>
    {# Advertising Bar #}
    {% if settings.ad_bar and settings.ad_text %}
        {% snipplet "header/header-advertising-new.tpl" %}
    {% endif %}

    {# Main Header Container #}
    <div class="flex items-center justify-between w-full px-4 md:px-16 py-5.5 md:py-4">

        {# Mobile: Hamburger | Desktop: Logo #}
        <div class="flex items-center gap-4 flex-1 md:flex-none">
            {# Hamburger - Mobile only #}
            <button class="nav-link md:hidden p-1" aria-label="Menu">
                <i data-lucide="menu" class="w-5 h-5"></i>
            </button>

            {# Logo - Desktop only (left aligned) #}
            <div class="hidden md:block">
                <a href="/">
                    {% if settings.logo_active_svg %}
                        <div class="logo-text text-2xl font-heading font-bold m-0 transition-colors duration-300">
                            {{ settings.logo_active_svg | raw }}
                        </div>
                    {% elseif "logo_active.png" | has_custom_image %}
                        <img 
                            src="{{ 'images/empty-placeholder.png' | static_url }}"
                            data-src="{{ "logo_active.png" | static_url }}"
                            class="lazyload transition-all duration-300 h-8"
                            alt="{{ store.name }} - Menu Logo" 
                        />
                    {% endif %}
                </a>
            </div>
        </div>

        {# Mobile: Logo (center) | Desktop: Navigation (center) #}
        <div class="flex items-center justify-center flex-1">
            {# Logo - Mobile only (centered) #}
            <div class="md:hidden">
                <a href="/">
                    {% if settings.logo_active_svg %}
                        <div class="logo-text text-xl font-heading font-bold m-0 transition-colors duration-300">
                            {{ settings.logo_active_svg | raw }}
                        </div>
                    {% elseif "logo_active.png" | has_custom_image %}
                        <img 
                            src="{{ 'images/empty-placeholder.png' | static_url }}"
                            data-src="{{ "logo_active.png" | static_url }}"
                            class="lazyload transition-all duration-300 h-8"
                            alt="{{ store.name }} - Menu Logo" 
                        />
                    {% endif %}
                </a>
            </div>

            {# Navigation - Desktop only #}
            <nav class="hidden md:flex items-center gap-8">
                <a href="#" class="nav-link flex items-center gap-1 text-sm font-medium transition-colors duration-300">
                    Produtos
                    <i data-lucide="minus" class="w-3 h-3"></i>
                </a>
                <a href="#" class="nav-link text-sm font-medium transition-colors duration-300">
                    Sobre
                </a>
                <a href="#" class="nav-link text-sm font-medium transition-colors duration-300">
                    Suporte
                </a>
                <a href="#" class="nav-link text-sm font-medium transition-colors duration-300">
                    Personalize
                </a>
            </nav>
        </div>

        {# Utilities - Right #}
        <div class="flex items-center justify-end gap-4 md:gap-6 flex-1 md:flex-none">
            {# Buscar #}
            <a href="#" class="nav-link text-sm font-medium transition-colors duration-300 flex items-center gap-1">
                <i data-lucide="search" class="w-5 h-5 md:hidden"></i>
                <span class="hidden md:inline">Buscar</span>
            </a>
            {# Login #}
            <a href="{{ store.customer_login_url }}" class="nav-link text-sm font-medium transition-colors duration-300 flex items-center gap-1">
                <i data-lucide="user" class="w-5 h-5 md:hidden"></i>
                <span class="hidden md:inline">Login</span>
            </a>
            {# Carrinho #}
            <a href="{{ store.cart_url }}" class="nav-link text-sm font-medium transition-colors duration-300 flex items-center gap-1">
                <i data-lucide="shopping-cart" class="w-5 h-5 md:hidden"></i>
                <span class="hidden md:inline">Carrinho</span>
                <span class="js-cart-widget-amount hidden md:inline">({{ cart.items_count }})</span>
            </a>
        </div>
    </div>
</header>

{# Spacer para compensar header fixed - oculto quando hero_banner é primeira seção #}
{% set hero_banner_first = settings.home_order_position_0 == 'hero_banner' and 'hero_banner_desktop.jpg' | has_custom_image %}
<div class="js-header-spacer h-25 md:h-30 {% if template == 'home' and hero_banner_first %}hidden{% endif %}"></div>
