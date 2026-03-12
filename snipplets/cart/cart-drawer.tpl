{# Cart Drawer - slides in from right #}
<div
  class="js-cart-drawer fixed inset-0 z-80"
  data-state="closed"
>
  {# Transparent backdrop - captures clicks outside #}
  <div class="js-cart-drawer-backdrop absolute inset-0"></div>

  {# Drawer panel #}
  <div class="js-cart-drawer-panel absolute top-0 right-0 bottom-0 w-full max-w-105 flex flex-col bg-bg text-fg">

    {# Header #}
    <div class="flex items-center justify-between px-5 py-4 border-b border-black/8">
      <h2 class="font-heading text-lg font-semibold m-0">
        {{ "Carrinho" | translate }}
      </h2>
      <button
        type="button"
        class="js-cart-drawer-close cursor-pointer text-fg bg-transparent border-0 p-1"
        aria-label="{{ 'Fechar' | translate }}"
      >
        <i data-lucide="x" class="w-5 h-5"></i>
      </button>
    </div>

    {# Cart form - platform expects .js-ajax-cart-panel wrapping cart items for AJAX operations #}
    <form action="{{ store.cart_url }}" method="post" class="js-ajax-cart-panel flex-1 flex flex-col min-h-0" data-store="cart-form" data-component="cart">

      {# Items list - scrollable area #}
      <div class="js-ajax-cart-list flex-1 overflow-y-auto px-5 py-4">
        {% if cart.items %}
          {% for item in cart.items %}
            {# .js-cart-item + data-item-id required by platform for LS.removeItem/LS.changeQuantity #}
            <div class="js-cart-item flex gap-3 py-3 border-b border-black/6" data-item-id="{{ item.id }}" data-store="cart-item-{{ item.product.id }}" data-component="cart.line-item">
              {# Item image #}
              <a href="{{ item.url }}" class="shrink-0">
                <img
                  src="{{ item.featured_image | product_image_url('small') }}"
                  alt="{{ item.short_name }}"
                  class="w-16 h-16 object-cover rounded-lg"
                />
              </a>

              {# Item details #}
              <div class="flex-1 min-w-0 flex flex-col gap-1">
                <a href="{{ item.url }}" class="text-[0.8125rem] leading-tight text-fg no-underline line-clamp-2" data-component="name.short-name">
                  {{ item.short_name }}
                </a>
                {% if item.short_variant_name %}
                  <small class="text-xs text-secondary opacity-60 truncate" data-component="name.short-variant-name">
                    {{ item.short_variant_name }}
                  </small>
                {% endif %}
                <div class="flex items-center justify-between mt-auto">
                  {# Quantity controls - uses LS.minusQuantity/LS.plusQuantity with true for AJAX mode #}
                  <div class="flex items-center border border-black/12 rounded-md overflow-hidden">
                    <span
                      class="js-cart-quantity-btn w-7 h-7 flex items-center justify-center bg-transparent cursor-pointer text-fg"
                      onclick="LS.minusQuantity({{ item.id }}, true)"
                      data-component="quantity.minus"
                    >
                      <i data-lucide="minus" class="w-3.5 h-3.5"></i>
                    </span>
                    <input
                      type="number"
                      name="quantity[{{ item.id }}]"
                      value="{{ item.quantity }}"
                      class="js-cart-quantity-input w-8 text-center text-[0.8125rem] font-medium text-fg bg-transparent border-0 p-0 outline-none [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
                      data-item-id="{{ item.id }}"
                      data-component="quantity.value"
                    />
                    {# Spinner - required by platform to show loading during AJAX operations #}
                    <span class="js-cart-input-spinner cart-item-spinner" style="display:none">
                    </span>
                    <span
                      class="js-cart-quantity-btn w-7 h-7 flex items-center justify-center bg-transparent cursor-pointer text-fg"
                      onclick="LS.plusQuantity({{ item.id }}, true)"
                      data-component="quantity.plus"
                    >
                      <i data-lucide="plus" class="w-3.5 h-3.5"></i>
                    </span>
                  </div>

                  {# Price - platform auto-updates .js-cart-item-subtotal #}
                  <span class="js-cart-item-subtotal text-[0.8125rem] font-bold text-fg" data-line-item-id="{{ item.id }}" data-component="subtotal.value" data-component-value="{{ item.subtotal | money }}">
                    {{ item.subtotal | money }}
                  </span>
                </div>
              </div>

              {# Delete button - animated removal handled by cart-drawer.js #}
              <button
                type="button"
                class="js-cart-remove-btn shrink-0 self-start cursor-pointer text-fg opacity-50 bg-transparent border-0 p-0.5"
                data-remove-item-id="{{ item.id }}"
                aria-label="{{ 'Remover item' | translate }}"
                data-component="line-item.remove"
              >
                <i data-lucide="trash-2" class="w-4 h-4"></i>
              </button>
            </div>
          {% endfor %}
        {% endif %}
      </div>

      {# Empty cart - platform shows .js-empty-ajax-cart when cart becomes empty #}
      <div class="js-empty-ajax-cart flex flex-col items-center justify-center h-full gap-4 text-center px-5" {% if cart.items %}style="display:none"{% endif %}>
        <i data-lucide="shopping-cart" class="w-12 h-12 opacity-30 text-fg"></i>
        <p class="text-sm text-fg opacity-60 m-0">
          {{ "Seu carrinho está vazio" | translate }}
        </p>
        <a href="{{ store.products_url }}" class="text-sm text-fg underline">
          {{ "Ver produtos" | translate }}
        </a>
      </div>

      {# Hidden subtotal for platform JS calculations #}
      <div class="js-subtotal-price hidden" data-priceraw="{{ cart.total }}"></div>

      {# Footer - total + CTA (inside form so submit triggers checkout) #}
      <div class="js-cart-drawer-footer js-visible-on-cart-filled px-5 py-4 border-t border-black/8" {% if not cart.items %}style="display:none"{% endif %}>
        <div class="flex justify-between items-center mb-3">
          <span class="text-sm font-medium text-fg">
            {{ "Subtotal" | translate }}
          </span>
          <span class="js-ajax-cart-total js-cart-subtotal text-base font-bold text-fg" data-priceraw="{{ cart.subtotal }}">
            {{ cart.subtotal | money }}
          </span>
        </div>
        <input
          type="submit"
          name="go_to_checkout"
          value="{{ 'Finalizar compra' | translate }}"
          class="js-cart-drawer-checkout block w-full py-3 text-center bg-fg text-bg rounded-lg text-sm font-semibold no-underline transition-opacity duration-150 cursor-pointer border-0"
        />
      </div>

    </form>
  </div>
</div>
