{# Buy bar. Figma "addCartContainer" node 52:1686 (mobile, 393x116) and node
   131:4254 inside "Desktop - 3" (131:1503).

   One component, responsive positioning: fixed at the bottom of the viewport
   with a blurred backdrop up to lg:, in-flow inside the 564px right column
   from lg: on (positioning lives in app.css, "PRODUCT STICKY BUY BAR STYLES").

   Mobile layout follows the Figma: price + payment highlights on the left and
   an auto-width "Comprar" button on the right, on the SAME row, with the
   promo progress bars underneath. From lg: the price and highlights are
   rendered by product-form.tpl's header block instead, so only the button
   remains and it spans the column. #}

<div class="js-product-sticky-buy-bar flex flex-col gap-3 px-6 py-4 border-t border-secondary/20 lg:border-t-0 lg:px-4 lg:py-0 lg:mb-4" data-store="product-sticky-buy-bar-{{ product.id }}">

    {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
    {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

    {# Figma priceInfosContainer (52:1637): price block and CTA on one row. #}

    <div class="flex items-center justify-between gap-3">

        {% if product.display_price %}
            <div class="flex flex-col gap-1 lg:hidden">
                <div class="flex items-start gap-1">
                    <span class="js-sticky-price-display text-secondary font-sans text-lg font-extrabold leading-[120%]">{{ product.price | money }}</span>
                    <span class="js-sticky-compare-price-display relative text-fg-muted font-sans text-xs font-medium leading-[120%]" {% if not product.compare_at_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %}>{% if product.compare_at_price %}{{ product.compare_at_price | money }}{% endif %}<span class="absolute top-1/2 left-0 w-full h-px bg-fg-muted"></span></span>
                </div>

                {# Installments / pix highlights — same treatment as the header
                   block in product-form.tpl (Figma 14:1084): 10px green labels
                   separated by a 4px dot, no pill background. #}

                {% set sticky_highlight_installments = product.get_max_installments(false) %}
                {% set sticky_has_highlight_installments = product.show_installments and sticky_highlight_installments and sticky_highlight_installments.installment > 1 %}
                {% set sticky_has_highlight_discount = product.maxPaymentDiscount.value > 0 and product.showMaxPaymentDiscount %}

                {% if sticky_has_highlight_installments or sticky_has_highlight_discount %}
                    <div class="flex items-center flex-wrap gap-[13px]">
                        {% if sticky_has_highlight_installments %}
                            <span class="font-sans text-[10px] font-medium leading-[120%] text-highlight">{{ sticky_highlight_installments.installment }}x {{ 'Sem Juros' | translate }}</span>
                        {% endif %}
                        {% if sticky_has_highlight_installments and sticky_has_highlight_discount %}
                            <span class="size-1 rounded-full bg-highlight shrink-0"></span>
                        {% endif %}
                        {% if sticky_has_highlight_discount %}
                            <span class="font-sans text-[10px] font-medium leading-[120%] text-highlight">{{ product.maxPaymentDiscount.value }}% {{ 'OFF no pix' | translate }}</span>
                        {% endif %}
                    </div>
                {% endif %}
            </div>
        {% endif %}

        {# data-text-cart / data-text-nostock let product-add-to-cart.js flip the CTA
           when the selected variant combination is sold out, without hardcoding a
           string in JS. Only the 'cart' state is ever flipped — 'contact', 'catalog'
           and the server-rendered 'nostock' keep their own behaviour. #}

        <button type="submit" class="js-product-sticky-buy-btn flex items-center justify-center shrink-0 h-10 p-2 rounded-lg bg-secondary text-bg font-sans text-base font-semibold tracking-[0.08px] leading-[150%] cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed lg:w-full {{ state }}" {% if state == 'nostock' %}disabled{% endif %} data-state="{{ state }}" data-text-cart="{{ texts['cart'] | translate }}" data-text-nostock="{{ texts['nostock'] | translate }}" data-store="product-buy-button" data-component="product.add-to-cart">
            {{ texts[state] | translate }}
        </button>

    </div>

    {% snipplet "cart/cart-drawer-progress-bars.tpl" %}

</div>
