{% if applied_filters %}

    {# Applied filters chips #}

    {% if has_applied_filters %}
        <div class="mb-4">
            <div class="text-secondary font-sans text-sm mb-2">{{ 'Filtrado por:' | translate }}</div>
            <div class="flex flex-wrap gap-2">
                {% for product_filter in product_filters %}
                    {% set is_size = product_filter.type == 'size' or product_filter.key == 'Talle' or product_filter.key == 'Tamanho' or product_filter.key == 'Size' %}
                    {% for value in product_filter.values %}
                        {% if value.selected %}
                            <button class="js-remove-filter flex items-center gap-1 [background:rgba(0,0,0,0.05)] px-2.5 py-1 rounded-lg text-secondary font-sans text-xs font-medium cursor-pointer hover:bg-black/10 transition-colors {% if is_size %}uppercase{% endif %}" data-filter-name="{{ product_filter.key }}" data-filter-value="{{ value.name }}">
                                {{ value.pill_label }}
                                <i data-lucide="x" class="w-3 h-3 text-secondary"></i>
                            </button>
                        {% endif %}
                    {% endfor %}
                {% endfor %}
                <a href="#" class="js-remove-all-filters text-secondary font-sans text-xs font-medium underline self-center">{{ 'Borrar filtros' | translate }}</a>
            </div>
        </div>
    {% endif %}
{% else %}
    {% if product_filters is not empty %}
        <div id="filters" data-store="filters-nav">
            {% for product_filter in product_filters %}
                {% if product_filter.type == 'price' %}

                    <div class="js-price-filter-wrapper mb-5">
                        {{ component(
                            'price-filter',
                            {'group_class': '', 'title_class': 'text-secondary font-heading text-sm font-semibold mb-3', 'button_class': 'js-price-filter-btn' }
                        ) }}
                    </div>

                {% else %}
                    {% if product_filter.has_products %}
                        <div class="mb-5" data-store="filters-group">
                            <h6 class="text-secondary font-heading text-sm font-semibold mb-3">{{ product_filter.name }}</h6>
                            <div class="flex flex-wrap gap-2">
                                {% set index = 0 %}
                                {% for value in product_filter.values %}
                                    {% if value.product_count > 0 %}
                                        {% set index = index + 1 %}
                                        {% if index == 9 and product_filter.values_with_products > 8 %}
                                            <div class="js-accordion-container flex flex-wrap gap-2" style="display: none;">
                                        {% endif %}
                                        {% set is_size = product_filter.type == 'size' or product_filter.key == 'Talle' or product_filter.key == 'Tamanho' or product_filter.key == 'Size' %}
                                        {% if value.selected %}
                                            <button class="js-remove-filter flex items-center gap-1 [background:rgba(0,0,0,0.12)] text-secondary px-2.5 py-1 rounded-lg font-sans text-xs font-medium cursor-pointer hover:bg-black/20 transition-colors {% if is_size %}uppercase{% endif %}" data-filter-name="{{ product_filter.key }}" data-filter-value="{{ value.name }}">
                                                {% if product_filter.type == 'color' and value.color_type == 'insta_color' %}
                                                    <span class="w-3 h-3 rounded-full inline-block shrink-0" style="background-color: {{ value.color_hexa }};border:1px solid color-mix(in srgb, var(--primary-color) 30%, transparent)"></span>
                                                {% endif %}
                                                {{ value.name }}
                                                <i data-lucide="x" class="w-3 h-3 text-secondary"></i>
                                            </button>
                                        {% else %}
                                            <button class="js-apply-filter flex items-center gap-1 [background:rgba(0,0,0,0.05)] text-secondary px-2.5 py-1 rounded-lg font-sans text-xs font-medium cursor-pointer hover:bg-black/10 transition-colors {% if is_size %}uppercase{% endif %}" data-filter-name="{{ product_filter.key }}" data-filter-value="{{ value.name }}">
                                                {% if product_filter.type == 'color' and value.color_type == 'insta_color' %}
                                                    <span class="w-3 h-3 rounded-full inline-block shrink-0" style="background-color: {{ value.color_hexa }};border:1px solid color-mix(in srgb, var(--primary-color) 15%, transparent)"></span>
                                                {% endif %}
                                                {{ value.name }}
                                            </button>
                                        {% endif %}
                                    {% endif %}
                                    {% if loop.last and product_filter.values_with_products > 8 %}
                                        </div>
                                        <div class="w-full">
                                            <a href="#" class="js-accordion-toggle text-secondary font-sans text-xs font-medium underline mt-1 inline-block">
                                                <span class="js-accordion-toggle-inactive">{{ 'Ver todos' | translate }}</span>
                                                <span class="js-accordion-toggle-active" style="display: none;">{{ 'Ver menos' | translate }}</span>
                                            </a>
                                        </div>
                                    {% endif %}
                                {% endfor %}
                            </div>
                        </div>
                    {% endif %}
                {% endif %}
            {% endfor %}
        </div>
    {% endif %}
{% endif %}