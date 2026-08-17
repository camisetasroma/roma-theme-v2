{# Product quantity #}

{% if not quickshop %}
    <div class="flex flex-wrap items-end gap-4" data-component="product.quantity">
        <div class="flex flex-col gap-2 w-fit">
{% endif %}
            <span class="font-sans text-xs font-medium text-fg-muted">{{ 'Cantidad' | translate }}:</span>
            {# data-max-stock carries the server-side stock of the first available
               variant (empty string = unlimited stock on Nuvemshop). It is only the
               initial value: product-add-to-cart.js recomputes the limit from
               product.variants_object every time the selected variant changes. #}

            {% embed "snipplets/forms/form-input.tpl" with{type_number: true, input_value: '1', input_name: 'quantity' ~ item.id, input_custom_class: 'js-quantity-input h-8 min-w-8 w-10 px-2 py-1 rounded-lg bg-control border-0 text-center text-secondary font-sans text-sm font-semibold outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none', input_label: false, input_append_content: true, input_group_custom_class: 'js-quantity flex items-center gap-2 w-fit', form_control_container_custom_class: 'contents', input_min: '1', input_data_attr: 'max-stock', input_data_val: product.selected_or_first_available_variant.stock, input_aria_label: 'Cambiar cantidad' | translate, data_component: 'adding-amount.value' } %}
    {% block input_prepend_content %}
        <button type="button" class="js-quantity-down flex w-8 h-8 justify-center items-center shrink-0 bg-control rounded-lg cursor-pointer" data-component="product.quantity.minus" aria-label="{{ 'Cambiar cantidad' | translate }}">
            <i data-lucide="minus" class="w-3 h-3 text-secondary"></i>
        </button>
    {% endblock input_prepend_content %}
    {% block input_append_content %}
        <button type="button" class="js-quantity-up flex w-8 h-8 justify-center items-center shrink-0 bg-control rounded-lg cursor-pointer aria-disabled:opacity-40 aria-disabled:cursor-not-allowed" data-component="product.quantity.plus" aria-label="{{ 'Cambiar cantidad' | translate }}" data-stock-limit-label="{{ 'Cantidad máxima disponible' | translate }}">
            <i data-lucide="plus" class="w-3 h-3 text-secondary"></i>
        </button>
    {% endblock input_append_content %}
{% endembed %}
{% if not quickshop %}
        </div>
        {% if settings.last_product %}
            <div class="{% if product.variations %}js-last-product {% endif %}"{% if product.selected_or_first_available_variant.stock != 1 %} style="display: none;"{% endif %}>
                <span class="text-accent font-sans text-sm font-bold">
                    {{ settings.last_product_text }}
                </span>
            </div>
        {% endif %}
    </div>
{% endif %}
