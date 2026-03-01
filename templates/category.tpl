{% set has_filters_available = products and has_filters_enabled and (filter_categories is not empty or product_filters is not empty) %}
{% set show_help = not has_products %}
{% paginate by 12 %}

{# Determine if we are in a child category (breadcrumbs has parent + current) #}
{% set is_child_category = breadcrumbs | length > 1 %}

{# Build sibling categories from main menu when on a child category #}
{# Strategy: find the current category URL among menu subitems, then collect its siblings #}
{% set sibling_categories = [] %}
{% if is_child_category and settings.menu_principal %}
    {% set current_url = category.url %}
    {% set parent_name = breadcrumbs[breadcrumbs | length - 2].name %}
    {% set main_menu = menus[settings.menu_principal] %}
    {% for item in main_menu %}
        {# Check if this top-level item is the parent (match by name) #}
        {% if item.name == parent_name and item.subitems is not empty %}
            {% for sub in item.subitems %}
                {% set sibling_categories = sibling_categories | merge([sub]) %}
            {% endfor %}
        {% elseif item.subitems is not empty %}
            {# Check second level - subitems might be the parent #}
            {% for sub in item.subitems %}
                {% if sub.name == parent_name and sub.subitems is not empty %}
                    {% for subsub in sub.subitems %}
                        {% set sibling_categories = sibling_categories | merge([subsub]) %}
                    {% endfor %}
                {% endif %}
            {% endfor %}
        {% endif %}
    {% endfor %}
{% endif %}

{# Determine which categories to show in dropdown #}
{% set dropdown_categories = sibling_categories is not empty ? sibling_categories : filter_categories %}
{% set has_dropdown = dropdown_categories is not empty or is_child_category %}

{# Parent URL for "Todos" link #}
{% set parent_url = is_child_category ? breadcrumbs[breadcrumbs | length - 2].url : category.url %}

{% if not show_help %}

    {# Category Header Bar #}
    <section class="px-4 md:px-16 py-4" style="background-color: var(--background-color)">
        <div class="flex items-center gap-3 mb-2">
            {# Title: if child category, show parent name; otherwise show current category name #}
            {% if is_child_category %}
                <h1 class="text-secondary font-heading text-[32px] font-extrabold leading-[80%] m-0">
                    {{ breadcrumbs[breadcrumbs | length - 2].name }}
                </h1>
            {% else %}
                <h1 class="text-secondary font-heading text-[32px] font-extrabold leading-[80%] m-0">
                    {{ category.name }}
                </h1>
            {% endif %}

            {# Category Dropdown - matches home-product-carousel.tpl style #}
            {% if has_dropdown %}
                <div class="js-category-dropdown relative">
                    <button
                        class="js-category-dropdown-trigger flex h-8 items-center gap-1 [background:rgba(0,0,0,0.05)] px-3 py-1 rounded-lg text-secondary font-sans text-sm font-medium cursor-pointer"
                        type="button"
                        aria-expanded="false"
                    >
                        <span class="js-category-dropdown-label">
                            {% if is_child_category %}
                                {{ category.name }}
                            {% else %}
                                {{ "Todos" | translate }}
                            {% endif %}
                        </span>
                        <i data-lucide="chevron-down" class="js-category-dropdown-icon w-4 h-4 text-secondary transition-transform duration-200"></i>
                    </button>
                    <ul class="js-category-dropdown-list absolute top-full left-0 mt-1 min-w-max [background:rgba(255,255,246,0.7)] backdrop-blur-sm rounded-lg shadow-md overflow-hidden z-20" hidden>
                        <li>
                            <a href="{{ parent_url }}" class="block whitespace-nowrap px-3 py-2 text-secondary font-sans text-base cursor-pointer hover:bg-black/5 no-underline">
                                {{ "Todos" | translate }}
                            </a>
                        </li>
                        {% for cat in dropdown_categories %}
                            <li>
                                <a href="{{ cat.url }}" class="block whitespace-nowrap px-3 py-2 text-secondary font-sans text-base cursor-pointer hover:bg-black/5 no-underline">
                                    {{ cat.name }}
                                </a>
                            </li>
                        {% endfor %}
                    </ul>
                </div>
            {% endif %}
        </div>

        {# Breadcrumb #}
        {% include 'snipplets/navigation/breadcrumb-category.tpl' %}

        {% if has_filters_available %}
            {# Filter trigger button #}
            <div class="flex items-center gap-3 mt-3">
                <a href="#" class="js-modal-open flex items-center gap-1.5 [background:rgba(0,0,0,0.05)] px-3 py-1.5 rounded-lg text-secondary font-sans text-sm font-medium no-underline cursor-pointer hover:bg-black/10 transition-colors" data-toggle="#nav-filters">
                    <i data-lucide="sliders-horizontal" class="w-4 h-4 text-secondary"></i>
                    {{ 'Filtrar' | translate }}
                </a>
            </div>

            {# Applied filters chips #}
            {% if has_applied_filters %}
                <div class="flex flex-wrap items-center gap-2 mt-3">
                    <span class="text-secondary font-sans text-sm">{{ 'Filtrado por:' | translate }}</span>
                    {% for product_filter in product_filters %}
                        {% for value in product_filter.values %}
                            {% if value.selected %}
                                <button class="js-remove-filter flex items-center gap-1 [background:rgba(0,0,0,0.05)] px-2.5 py-1 rounded-lg text-secondary font-sans text-xs font-medium cursor-pointer hover:bg-black/10 transition-colors" data-filter-name="{{ product_filter.key }}" data-filter-value="{{ value.name }}">
                                    {{ value.pill_label }}
                                    <i data-lucide="x" class="w-3 h-3 text-secondary"></i>
                                </button>
                            {% endif %}
                        {% endfor %}
                    {% endfor %}
                    <a href="#" class="js-remove-all-filters text-secondary font-sans text-xs font-medium underline">{{ 'Borrar filtros' | translate }}</a>
                </div>
            {% endif %}
            {% embed "snipplets/modal.tpl" with{modal_id: 'nav-filters', modal_class: 'filters modal-docked-small', modal_position: 'left', modal_transition: 'slide', modal_width: 'full'} %}
                {% block modal_head %}
                    {{'Filtros' | translate }}
                {% endblock %}
                {% block modal_body %}
                    {% if filter_categories is not empty %}
                        {% snipplet "grid/categories.tpl" %}
                    {% endif %}
                    {% if product_filters is not empty %}
                        {% snipplet "grid/filters.tpl" %}
                    {% endif %}
                    <div class="js-filters-overlay filters-overlay" style="display: none;">
                        <div class="filters-updating-message">
                            <h3 class="js-applying-filter" style="display: none;">{{ 'Aplicando filtro...' | translate }}</h3>
                            <h3 class="js-removing-filter" style="display: none;">{{ 'Borrando filtro...' | translate }}</h3>
                        </div>
                    </div>
                {% endblock %}
            {% endembed %}
        {% endif %}
    </section>

    {# Product Grid + Pagination #}
    <section class="px-4 md:px-16 pb-8" style="background-color: var(--background-color)">
        {% if products %}
            <div class="js-category-grid grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 md:gap-x-4 md:gap-y-4"
                 data-next-url="{{ pages.next }}"
                 data-is-last="{{ pages.is_last ? 'true' : 'false' }}">
                {% for product in products %}
                    {% include 'snipplets/grid/item-card.tpl' %}
                {% endfor %}
            </div>
            {# Custom load more / infinite scroll #}
            {% if not pages.is_last %}
                <div class="js-category-load-more flex justify-center mt-6 mb-6">
                    <button type="button" class="js-category-load-more-btn text-secondary font-sans text-sm font-medium cursor-pointer [background:rgba(0,0,0,0.05)] px-6 py-2 rounded-lg hover:bg-black/10 transition-colors">
                        {{ 'Mostrar más productos' | translate }}
                    </button>
                </div>
                <div class="js-category-scroll-spinner flex justify-center py-4" hidden>
                    <i data-lucide="loader-2" class="w-6 h-6 text-secondary animate-spin"></i>
                </div>
            {% endif %}
        {% else %}
            <p class="text-center text-fg-muted py-8">
                {{(has_filters_enabled ? "No tenemos resultados para tu búsqueda. Por favor, intentá con otros filtros." : "Próximamente") | translate}}
            </p>
        {% endif %}
    </section>

{% elseif show_help %}
    {% include 'snipplets/defaults/show_help_category.tpl' %}
{% endif %}
