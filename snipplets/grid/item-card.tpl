{# Product Carousel Item - Miniature Card #}

<div class="{{ item_class | default('') }} flex flex-col justify-start items-start"
     data-product-id="{{ product.id }}"
     data-store="product-item-{{ product.id }}"
     data-product-name="{{ product.name }}"
     data-product-image="{{ product.featured_image | product_image_url('small') }}"
     {% if product.display_price %}data-product-price="{{ product.price | money }}"{% endif %}>
    <script class="js-quickbuy-variants-data" type="application/json">{{ product.variants_object | json_encode | raw }}</script>

    {# Product Image Container #}
    <div class="flex flex-col items-start relative w-full rounded-sm">

        {# Product Badges - top left #}
        <div class="flex items-start content-start gap-1.25 flex-wrap absolute top-0 left-0 px-4 py-2 z-10">
            {% if product.compare_at_price and product.display_price %}
                {% set discount_percentage = ((product.compare_at_price - product.price) * 100 / product.compare_at_price) | round %}
                <span class="flex items-center justify-center [background:rgba(0,0,0,0.05)] px-2 py-0.5 rounded text-secondary font-sans text-[10px] font-semibold">
                    -{{ discount_percentage }}%
                </span>
            {% endif %}
            {% for label in product.labels %}
                <span class="flex items-center justify-center [background:rgba(0,0,0,0.05)] px-2 py-0.5 rounded text-secondary font-sans text-[10px] font-semibold">
                    {{ label }}
                </span>
            {% endfor %}
        </div>

        {# Product Image #}
        <a href="{{ product.url }}" title="{{ product.name }}" class="block w-full">
            <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                 data-src="{{ product.featured_image | product_image_url('medium') }}"
                 data-srcset="{{ product.featured_image | product_image_url('large') }} 480w"
                 class="lazyload w-full h-auto object-cover"
                 alt="{{ product.featured_image.alt }}" />
        </a>

        {# Quick Buy - Desktop: overlay at bottom of image #}
        <div class="js-quickbuy-container hidden md:flex items-center justify-end flex-wrap gap-1 absolute bottom-0 left-0 right-0 px-2 py-2 z-10">
            {% if product.variations %}
                {% for variation in product.variations %}
                    <div class="js-quickbuy-dropdown relative" data-variation-id="{{ variation.id }}">
                        <button type="button"
                                class="js-quickbuy-dropdown-trigger flex h-8 items-center gap-1 px-3 py-1 rounded-lg [background:rgba(0,0,0,0.05)] text-secondary font-sans text-sm font-medium cursor-pointer"
                                aria-expanded="false">
                            <span class="js-quickbuy-dropdown-label block max-w-16 truncate">{% for option in variation.options %}{% if loop.first %}{{ option.name }}{% endif %}{% endfor %}</span>
                            <i data-lucide="chevron-up" class="js-quickbuy-dropdown-icon w-4 h-4 text-secondary shrink-0 transition-transform duration-200"></i>
                        </button>
                        <ul class="js-quickbuy-dropdown-list absolute bottom-full left-0 mb-1 min-w-max bg-bg rounded-lg shadow-md overflow-hidden z-20" hidden>
                            {% for option in variation.options %}
                                <li class="js-quickbuy-dropdown-option px-3 py-2 text-secondary font-sans text-base cursor-pointer hover:bg-black/5"
                                    data-option-id="{{ option.id }}"
                                    data-option-name="{{ option.name }}"
                                    {% if loop.first %}data-selected="true"{% endif %}>
                                    {{ option.name }}
                                </li>
                            {% endfor %}
                        </ul>
                    </div>
                {% endfor %}
            {% endif %}
            <button type="button"
                    class="js-quickbuy-add-btn flex w-8 h-8 justify-center items-center shrink-0 [background:rgba(0,0,0,0.05)] rounded-lg cursor-pointer"
                    aria-label="{{ 'Agregar al carrito' | translate }}">
                <i data-lucide="plus" class="w-4 h-4 text-secondary"></i>
            </button>
        </div>
    </div>

    {# Quick Buy - Mobile: below image in normal flow (hidden in carousels) #}
    <div class="js-quickbuy-container flex md:hidden items-center flex-wrap gap-1 w-full py-1.5">
        {% if product.variations %}
            {% for variation in product.variations %}
                <div class="js-quickbuy-dropdown relative" data-variation-id="{{ variation.id }}">
                    <button type="button"
                            class="js-quickbuy-dropdown-trigger flex h-8 items-center gap-1 px-3 py-1 rounded-lg [background:rgba(0,0,0,0.05)] text-secondary font-sans text-sm font-medium cursor-pointer"
                            aria-expanded="false">
                        <span class="js-quickbuy-dropdown-label block max-w-16 truncate">{% for option in variation.options %}{% if loop.first %}{{ option.name }}{% endif %}{% endfor %}</span>
                        <i data-lucide="chevron-up" class="js-quickbuy-dropdown-icon w-4 h-4 text-secondary shrink-0 transition-transform duration-200"></i>
                    </button>
                    <div class="js-quickbuy-dropdown-list absolute bottom-full left-0 mb-1 bg-bg/70 backdrop-blur-sm rounded-lg shadow-md p-2 flex flex-wrap gap-2 z-20" hidden>
                        {% for option in variation.options %}
                            <button type="button"
                                    class="js-quickbuy-pill flex items-center justify-center px-2 py-1 rounded text-secondary font-sans text-[13px] font-semibold cursor-pointer {% if loop.first %}[background:rgba(0,0,0,0.15)]{% else %}[background:rgba(0,0,0,0.05)]{% endif %}"
                                    data-option-id="{{ option.id }}"
                                    data-option-name="{{ option.name }}"
                                    {% if loop.first %}data-selected="true"{% endif %}>
                                {{ option.name }}
                            </button>
                        {% endfor %}
                    </div>
                </div>
            {% endfor %}
        {% endif %}
        <button type="button"
                class="js-quickbuy-add-btn flex w-8 h-8 justify-center items-center shrink-0 [background:rgba(0,0,0,0.05)] rounded-lg cursor-pointer"
                aria-label="{{ 'Agregar al carrito' | translate }}">
            <i data-lucide="plus" class="w-4 h-4 text-secondary"></i>
        </button>
    </div>

    {# Product Info Container #}
    <div class="flex flex-col items-start gap-1.5 shrink-0 self-stretch py-2">
        {# Product Name #}
        <a href="{{ product.url }}" title="{{ product.name }}" class="self-stretch text-secondary font-sans text-[13px] font-medium leading-[120%] no-underline line-clamp-2 min-h-[calc(2*13px*1.2)]">
            {{ product.name }}
        </a>

        {# Price Container #}
        {% if product.display_price %}
            <div class="flex items-center gap-2">
                {# Current Price #}
                <span class="text-secondary font-sans text-base font-extrabold leading-[120%]">
                    {{ product.price | money }}
                </span>

                {# Compare/Original Price (strikethrough) #}
                {% if product.compare_at_price %}
                    <span class="relative text-fg-muted font-sans text-base leading-[120%]">
                        {{ product.compare_at_price | money }}
                        <span class="absolute top-1/2 left-0 w-full h-px bg-fg-muted"></span>
                    </span>
                {% endif %}
            </div>
        {% endif %}
    </div>
</div>
