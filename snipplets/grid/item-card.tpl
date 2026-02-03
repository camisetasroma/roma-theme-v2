{# Product Carousel Item - Miniature Card #}

<div class="{{ item_class | default('') }} flex flex-col justify-center items-start"
     data-product-id="{{ product.id }}"
     data-store="product-item-{{ product.id }}">

    {# Product Image Container #}
    <div class="flex flex-col items-start relative w-full overflow-hidden rounded-sm">

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

        {# Quick Shop Button - bottom right #}
        <button class="flex w-8 h-8 justify-center items-center gap-2.5 shrink-0 [background:rgba(0,0,0,0.05)] rounded-lg absolute bottom-2 right-2 z-10"
                aria-label="{{ 'Agregar al carrito' | translate }}">
            <i data-lucide="shopping-cart" class="w-4 h-4 text-secondary"></i>
        </button>
    </div>

    {# Product Info Container #}
    <div class="flex flex-col items-start gap-1.5 shrink-0 self-stretch p-2">
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
