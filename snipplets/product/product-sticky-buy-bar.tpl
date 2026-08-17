{# Sticky buy bar: fixed bottom-0 on mobile/tablet, in-flow inside the right column from lg: on #}

<div class="js-product-sticky-buy-bar flex flex-col gap-3 p-4 lg:px-4 lg:py-0 lg:mb-4" data-store="product-sticky-buy-bar-{{ product.id }}">

    {% if product.display_price %}
        <div class="flex items-center flex-wrap gap-2 lg:hidden">
            <span class="js-sticky-price-display text-secondary font-sans text-2xl font-extrabold leading-[120%]">{{ product.price | money }}</span>
            <span class="js-sticky-compare-price-display relative text-fg-muted font-sans text-base leading-[120%]" {% if not product.compare_at_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %}>{% if product.compare_at_price %}{{ product.compare_at_price | money }}{% endif %}<span class="absolute top-1/2 left-0 w-full h-px bg-fg-muted"></span></span>
        </div>
    {% endif %}

    {% set sticky_max_installments_without_interests = product.get_max_installments(false) %}
    {% set sticky_installments_without_interests = sticky_max_installments_without_interests and sticky_max_installments_without_interests.installment > 1 %}
    {% set sticky_has_payment_discount = product.maxPaymentDiscount.value > 0 %}

    {% if sticky_installments_without_interests or sticky_has_payment_discount %}
        <div class="flex items-center flex-wrap gap-2 lg:hidden">
            {% if sticky_installments_without_interests %}
                <span class="flex items-center justify-center bg-control px-2 py-1 rounded text-secondary font-sans text-xs font-semibold">{{ sticky_max_installments_without_interests.installment }}x {{ 'Sem Juros' | translate }}</span>
            {% endif %}
            {% if sticky_has_payment_discount %}
                <span class="flex items-center justify-center bg-control px-2 py-1 rounded text-secondary font-sans text-xs font-semibold">{{ product.maxPaymentDiscount.value }}% {{ 'OFF no pix' | translate }}</span>
            {% endif %}
        </div>
    {% endif %}

    {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
    {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

    {# data-text-cart / data-text-nostock let product-add-to-cart.js flip the CTA
       when the selected variant combination is sold out, without hardcoding a
       string in JS. Only the 'cart' state is ever flipped — 'contact', 'catalog'
       and the server-rendered 'nostock' keep their own behaviour. #}

    <button type="submit" class="js-product-sticky-buy-btn flex items-center justify-center w-full h-10 p-2 rounded-lg bg-fg text-bg font-sans text-base font-semibold cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed {{ state }}" {% if state == 'nostock' %}disabled{% endif %} data-state="{{ state }}" data-text-cart="{{ texts['cart'] | translate }}" data-text-nostock="{{ texts['nostock'] | translate }}" data-store="product-buy-button" data-component="product.add-to-cart">
        {{ texts[state] | translate }}
    </button>

    {% snipplet "cart/cart-drawer-progress-bars.tpl" %}

</div>
