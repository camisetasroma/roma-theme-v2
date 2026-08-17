{# Right column of the PDP.

   Layout follows Figma node 131:3666 ("productOptions"): every block in the
   column is 16px apart (gap-4), the options block is inset 24px (lg:px-6) and
   the buy button 16px (handled inside product-sticky-buy-bar.tpl).
   Order is fixed by the design: breadcrumb → name → price → variants →
   quantity → shipping → buy button → progress → accordions. #}

<div class="flex flex-col gap-4 lg:pt-3">

    {# Product name, breadcrumbs and price #}

    <div class="flex flex-col gap-4 items-start lg:px-6">

        {% include 'snipplets/breadcrumbs.tpl' %}

        <h1 class="js-product-name text-secondary font-heading text-2xl font-extrabold leading-[120%]" data-store="product-name-{{ product.id }}">{{ product.name }}</h1>

        <div class="js-price-container flex flex-col gap-1" data-store="product-price-{{ product.id }}">
            <div class="flex items-center flex-wrap gap-1">
                <span id="price_display" class="js-price-display text-secondary font-sans text-xl font-extrabold leading-[120%]" {% if not product.display_price %}style="display:none;"{% endif %} data-product-price="{{ product.price }}">{% if product.display_price %}{{ product.price | money }}{% endif %}</span>
                <span id="compare_price_display" class="js-compare-price-display relative text-fg-muted font-sans text-xs font-medium leading-[120%]" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %}>{% if product.compare_at_price and product.display_price %}{{ product.compare_at_price | money }}{% endif %}<span class="absolute top-1/2 left-0 w-full h-px bg-fg-muted"></span></span>
            </div>

            {# Installments / pix highlights — Figma node 131:4244: two 10px green
               labels separated by a 4px dot, no pill background. #}

            {% set highlight_installments = product.get_max_installments(false) %}
            {% set has_highlight_installments = product.show_installments and product.display_price and highlight_installments and highlight_installments.installment > 1 %}
            {% set has_highlight_discount = product.maxPaymentDiscount.value > 0 and product.showMaxPaymentDiscount %}

            {% if has_highlight_installments or has_highlight_discount %}
                <div class="js-product-price-highlights flex items-center flex-wrap gap-[13px]">
                    {% if has_highlight_installments %}
                        <span class="font-sans text-[10px] font-medium text-highlight">{{ highlight_installments.installment }}x {{ 'Sem Juros' | translate }}</span>
                    {% endif %}
                    {% if has_highlight_installments and has_highlight_discount %}
                        <span class="size-1 rounded-full bg-highlight shrink-0"></span>
                    {% endif %}
                    {% if has_highlight_discount %}
                        <span class="font-sans text-[10px] font-medium text-highlight">{{ product.maxPaymentDiscount.value }}% {{ 'OFF no pix' | translate }}</span>
                    {% endif %}
                </div>
            {% endif %}

            {{ component('price-discount-disclaimer', {
                container_classes: 'font-sans text-[10px] text-fg-muted',
            }) }}
            {{ component('price-without-taxes', {
                    container_classes: 'font-sans text-[10px] text-fg-muted',
                })
            }}
            {{ component('payment-discount-price', {
                    visibility_condition: settings.payment_discount_price,
                    location: 'product',
                    container_classes: 'font-sans text-xs font-semibold',
                })
            }}
        </div>

        {{ component('subscriptions/subscription-price', {
            subscription_classes: {
                container: 'flex flex-col gap-1',
                prices_container: 'flex items-center gap-2',
                price_compare: 'text-fg-muted font-sans text-xs font-medium leading-[120%] line-through',
                price_with_subscription: 'text-secondary font-sans text-xl font-extrabold leading-[120%]',
                discount_container: 'font-sans text-xs font-semibold',
                price_without_taxes_container: 'font-sans text-[10px] text-fg-muted',
            },
        }) }}

        {{ component('promotions-details', {
            promotions_details_classes: {
                container: 'js-product-promo-container flex flex-col gap-2',
                promotion_title: 'text-secondary font-sans text-sm font-bold',
                valid_scopes: 'font-sans text-xs text-fg-muted mb-0',
                categories_combinable: 'font-sans text-xs text-fg-muted mb-0',
                not_combinable: 'font-sans text-[10px] text-fg-muted mb-0',
                progressive_discounts_table: 'w-full font-sans text-xs',
                progressive_discounts_hidden_table: 'table-body-inverted',
                progressive_discounts_show_more_link: 'text-secondary font-sans text-xs underline cursor-pointer',
                progressive_discounts_show_more_icon: 'icon-inline',
                progressive_discounts_hide_icon: 'icon-inline icon-flip-vertical',
                progressive_discounts_promotion_quantity: 'font-normal lowercase'
            },
            svg_sprites: false,
            custom_control_show: include("snipplets/svg/chevron-down.tpl", { svg_custom_class: "icon-inline icon-w-14 icon-md ml-2" }),
            custom_control_hide: include("snipplets/svg/chevron-up.tpl", { svg_custom_class: "icon-inline icon-w-14 icon-md ml-2" }),
        }) }}

        {# Product installments detail (opens the payment methods modal) #}

        {% set installments_info = product.installments_info_from_any_variant %}
        {% set hasDiscount = product.maxPaymentDiscount.value > 0 %}
        {% set show_payments_info = product.show_installments and product.display_price and installments_info %}

        {% if show_payments_info or hasDiscount %}

            <div data-toggle="#installments-modal" data-modal-url="modal-fullscreen-payments" class="js-modal-open js-fullscreen-modal-open js-product-payments-container flex flex-col gap-2" {% if not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>

                {# Max Payment Discount #}

                {% set hideDiscountContainer = not (hasDiscount and product.showMaxPaymentDiscount) %}
                {% set hideDiscountDisclaimer = not product.showMaxPaymentDiscountNotCombinableDisclaimer %}

                <div class="js-product-discount-container font-sans text-xs" {% if hideDiscountContainer %}style="display: none;"{% endif %}>
                    <span><strong class="text-accent font-bold">{{ product.maxPaymentDiscount.value }}% {{'de descuento' | translate }}</strong> {{'pagando con' | translate }} {{ product.maxPaymentDiscount.paymentProviderName }}</span>
                    <div class="js-product-discount-disclaimer font-sans text-[10px] text-fg-muted mt-1" {% if hideDiscountDisclaimer %}style="display: none;"{% endif %}>
                        {{ "No acumulable con otras promociones" | translate }}
                    </div>
                </div>

                {# Installments #}

                {% if show_payments_info %}
                    {% set max_installments_without_interests = product.get_max_installments(false) %}
                    {% set installments_without_interests = max_installments_without_interests and max_installments_without_interests.installment > 1 %}
                    {% set installment_text_weigth = installments_without_interests ? 'font-bold' : '' %}
                    {{ component('installments', {'location' : 'product_detail', container_classes: { installment: "product-detail-installments font-sans text-xs " ~ installment_text_weigth}}) }}
                {% endif %}

                <div class="flex flex-wrap items-center gap-2">
                    {% set has_payment_logos = settings.payments %}
                    {% if has_payment_logos %}
                      <ul class="flex flex-wrap items-center gap-1 list-none m-0 p-0">
                        {% for payment in settings.payments %}
                            {# Payment methods flags #}
                            {% if store.country == 'BR' %}
                              {% if payment in ['visa', 'mastercard'] %}
                                <li class="flex items-center">
                                  {{ payment | payment_new_logo | img_tag('',{class: 'card-img card-img-small lazyload'}) }}
                                </li>
                              {% endif %}
                            {% else %}
                                {% if payment in ['visa', 'amex', 'mastercard'] %}
                                  <li class="flex items-center">
                                    {{ payment | payment_new_logo | img_tag('',{class: 'card-img card-img-small lazyload'}) }}
                                  </li>
                                {% endif %}
                            {% endif %}
                        {% endfor %}
                          <li class="flex items-center">
                            {% include "snipplets/svg/credit-card-blank.tpl" with {svg_custom_class: "icon-inline icon-w-18 icon-2x " ~ card_icon_color ~ ""} %}
                          </li>
                      </ul>
                    {% endif %}
                    <a id="btn-installments" class="text-secondary font-sans text-xs underline cursor-pointer" {% if not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
                        {{ "Ver medios de pago" | translate }}
                    </a>
                </div>
            </div>

        {% endif %}

        {# Product availability #}

        {% set show_product_quantity = product.available and product.display_price %}

        {# Free shipping minimum message #}

        {% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}
        {% set has_product_free_shipping = product.free_shipping %}

        {% if not product.is_non_shippable and show_product_quantity and (has_free_shipping or has_product_free_shipping) %}
            <div class="js-free-shipping-minimum-message free-shipping-message flex items-start gap-2 font-sans text-xs">
                <i data-lucide="truck" class="w-4 h-4 text-accent shrink-0 mt-px"></i>
                <span>
                    <strong class="text-accent font-bold">{{ "Envío gratis" | translate }} </strong>
                    <span {% if has_product_free_shipping %}style="display: none;"{% else %}class="js-shipping-minimum-label"{% endif %}>
                        {{ "superando los" | translate }} <span>{{ cart.free_shipping.min_price_free_shipping.min_price }}</span>
                    </span>
                    {% if not has_product_free_shipping %}
                        <span class="js-free-shipping-discount-not-combinable block font-sans text-[10px] text-fg-muted mt-1">
                            {{ "No acumulable con otras promociones" | translate }}
                        </span>
                    {% endif %}
                </span>
            </div>
        {% endif %}

    </div>

    {# Product form, includes: Variants, Quantity, Shipping calculator and CTA #}

    <form id="product_form" class="js-product-form flex flex-col gap-4" method="post" action="{{ store.cart_url }}" data-store="product-form-{{ product.id }}">
        <input type="hidden" name="add_to_cart" value="{{product.id}}" />

        <div class="flex flex-col gap-4 items-start lg:px-6">

            {% if product.variations %}
                {% include "snipplets/product/product-variants.tpl" with {show_size_guide: true} %}
            {% endif %}

            {% if product.available and product.display_price %}
                {% include "snipplets/product/product-quantity.tpl" %}
            {% endif %}

            {{ component('subscriptions/subscription-selector', {
                subscription_classes: {
                    container: 'radio-button-container box p-0 w-full',

                    radio_button: 'radio-button-item',
                    radio_button_text: 'flex flex-wrap items-center',
                    radio_button_icon: 'radio-button-icons',
                    purchase_option_info_container: 'flex-1',
                    purchase_option_price: 'text-right font-bold',
                    purchase_option_single_frequency: 'mt-2 pt-1 font-sans text-xs opacity-80',
                    purchase_option_discount: 'label label-accent font-sans text-[10px] px-2 py-1 ml-1',

                    dropdown_container: 'form-group font-sans text-xs mt-2 mb-0',
                    dropdown_button: 'form-select position-relative',
                    dropdown_icon: 'form-select-icon icon-inline icon-w-14',
                    dropdown_options: 'form-select-options',
                    dropdown_option: 'form-select-option flex flex-wrap',
                    dropdown_option_info: 'flex-1 pr-4',
                    dropdown_option_price: 'font-bold',
                    dropdown_option_discount: 'text-accent mt-1 font-bold',

                    cart_alert: 'subscription-btn-alert full-width-container text-center mb-4 pb-2',
                    shipping_message: 'mt-2 mb-4',
                    shipping_message_title: 'font-bold ml-1',
                    shipping_message_text: 'font-sans text-xs mt-2 ml-4',

                    legal_message: 'font-sans text-[10px] text-center mb-3',
                    legal_link: 'font-sans text-[10px] inline-block btn-link btn-link-primary p-0',
                    legal_modal: 'bottom modal-centered-small modal-centered transition-soft',
                    legal_modal_header: 'modal-header flex flex-wrap items-center',
                    legal_modal_title: 'flex-1',
                    legal_modal_close_button: 'mr-3 pb-0 order-first',
                    legal_modal_body: 'mb-4',
                    legal_modal_details_title: 'font-sans text-sm font-bold mb-2',
                    legal_modal_details_paragraph: 'font-sans text-xs pb-4 mb-0',
                    legal_modal_details_link: 'font-sans text-xs inline-block btn-link btn-link-primary p-0'
                },
                svg_sprites: false,

                dropdown_icon: true,
                dropdown_custom_icon: include("snipplets/svg/chevron-down.tpl", { svg_custom_class: "icon-inline icon-sm svg-icon-text" }),

                shipping_message_icon: true,
                shipping_message_custom_icon: include("snipplets/svg/truck.tpl", { svg_custom_class: "icon-inline icon-lg icon-w-18 svg-icon-text" }),

                legal_modal_close_custom_icon: include("snipplets/svg/times.tpl", { svg_custom_class: "icon-inline svg-icon-text" }),
            }) }}

            {# Shipping calculator — Figma places it BEFORE the buy button
               (node 532:3266, right above node 131:4257). #}

            {% set show_product_fulfillment = settings.shipping_calculator_product_page and (store.has_shipping or store.branches) and not product.free_shipping and not product.is_non_shippable %}

            {% if show_product_fulfillment %}

                <div id="product-shipping-container" class="product-shipping-calculator w-full" {% if not product.display_price or not product.has_stock %}style="display:none;"{% endif %} data-shipping-url="{{ store.shipping_calculator_url }}">

                    {# Shipping Calculator #}

                    {% if store.has_shipping %}
                        {% include "snipplets/product/product-shipping-calculator.tpl" with {'shipping_calculator_variant' : product.selected_or_first_available_variant} %}
                    {% endif %}

                    {% if store.branches %}

                        {# Link for branches #}
                        {% include "snipplets/shipping/branches.tpl" with {'product_detail': true} %}
                    {% endif %}
                </div>
            {% endif %}

        </div>

        {# Add to cart CTA: fixed bar on mobile/tablet, in-flow inside the right column from lg: on #}

        {% include 'snipplets/product/product-sticky-buy-bar.tpl' %}

        {# Free shipping visibility message #}

        {% set free_shipping_minimum_label_changes_visibility = has_free_shipping and cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

        {% set include_product_free_shipping_min_wording = cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

        {% if not product.is_non_shippable and show_product_quantity and has_free_shipping and not has_product_free_shipping %}

            <div class="flex flex-col gap-2 lg:px-6">

                {# Free shipping add to cart message #}

                {% if include_product_free_shipping_min_wording %}

                    {% include "snipplets/shipping/shipping-free-rest.tpl" with {'product_detail': true} %}

                {% endif %}

                {# Free shipping achieved message #}

                <div class="js-product-form-free-shipping-message {% if free_shipping_minimum_label_changes_visibility %}js-free-shipping-message{% endif %} text-accent font-sans text-xs font-bold" {% if not cart.free_shipping.cart_has_free_shipping %}style="display: none;"{% endif %}>
                    {{ "¡Genial! Tenés envío gratis" | translate }}
                </div>

            </div>

        {% endif %}
    </form>

    {# Product payments details #}

    {% include 'snipplets/product/product-payment-details.tpl' %}

    {# Product accordions: description + size guide #}

    {% include 'snipplets/product/product-accordions.tpl' %}

    {# Product share — below the accordions, per user request #}

    <div class="px-4 lg:px-6">
        {% include 'snipplets/social/social-share.tpl' %}
    </div>

</div>
