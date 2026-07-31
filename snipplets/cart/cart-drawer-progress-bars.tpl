{# Progress bar: Free Shipping #}
{% if settings.cart_free_shipping_bar and cart.free_shipping.min_price_free_shipping.min_price_raw %}
  {% set fs_min = cart.free_shipping.min_price_free_shipping.min_price_raw %}
  {% set fs_subtotal = cart.subtotal %}

  {% if cart.free_shipping.cart_has_free_shipping or fs_subtotal >= fs_min %}
    {% set fs_progress = 100 %}
    {% set fs_completed = true %}
  {% else %}
    {% set fs_progress = (fs_subtotal * 100) / fs_min %}
    {% set fs_completed = false %}
    {% if fs_progress > 100 %}
      {% set fs_progress = 100 %}
    {% endif %}
    {% set fs_remaining = fs_min - fs_subtotal %}
  {% endif %}

  <div class="flex flex-col gap-1 mb-3">
    <div class="flex justify-between items-center text-xs text-secondary">
      {% if fs_completed %}
        <span class="font-medium">{{ "¡Tenés envío gratis!" | translate }}</span>
      {% else %}
        <span>{{ "Faltam {1} para frete grátis" | translate(fs_remaining | money) }}</span>
      {% endif %}
      <i data-lucide="truck" class="w-3.5 h-3.5 opacity-60"></i>
    </div>
    <div class="h-1.5 rounded-full bg-secondary/10 overflow-hidden">
      <div class="h-full rounded-full transition-all duration-300 {% if fs_completed %}js-cart-progress-complete{% endif %}" style="width: {{ fs_progress }}%; background-color: var(--accent-color)"></div>
    </div>
  </div>
{% endif %}

{# Progress bar: Progressive Discounts #}
{% if settings.cart_discount_bar and settings.cart_discount_tier_1_qty %}
  {% set total_items = cart.items_count %}
  {% set t1_qty = settings.cart_discount_tier_1_qty * 1 %}
  {% set t1_pct = settings.cart_discount_tier_1_pct * 1 %}
  {% set t2_qty = settings.cart_discount_tier_2_qty ? settings.cart_discount_tier_2_qty * 1 : 0 %}
  {% set t2_pct = settings.cart_discount_tier_2_pct ? settings.cart_discount_tier_2_pct * 1 : 0 %}
  {% set t3_qty = settings.cart_discount_tier_3_qty ? settings.cart_discount_tier_3_qty * 1 : 0 %}
  {% set t3_pct = settings.cart_discount_tier_3_pct ? settings.cart_discount_tier_3_pct * 1 : 0 %}

  {# Find the next target tier and current progress #}
  {% set discount_completed = false %}
  {% set target_qty = t1_qty %}
  {% set target_pct = t1_pct %}

  {% if total_items >= t1_qty %}
    {% if t2_qty > 0 %}
      {% set target_qty = t2_qty %}
      {% set target_pct = t2_pct %}
      {% if total_items >= t2_qty %}
        {% if t3_qty > 0 %}
          {% set target_qty = t3_qty %}
          {% set target_pct = t3_pct %}
          {% if total_items >= t3_qty %}
            {% set discount_completed = true %}
            {% set achieved_pct = t3_pct %}
          {% endif %}
        {% else %}
          {% set discount_completed = true %}
          {% set achieved_pct = t2_pct %}
        {% endif %}
      {% endif %}
    {% elseif t3_qty > 0 %}
      {% set target_qty = t3_qty %}
      {% set target_pct = t3_pct %}
      {% if total_items >= t3_qty %}
        {% set discount_completed = true %}
        {% set achieved_pct = t3_pct %}
      {% endif %}
    {% else %}
      {% set discount_completed = true %}
      {% set achieved_pct = t1_pct %}
    {% endif %}
  {% endif %}

  {% if discount_completed %}
    {% set discount_progress = 100 %}
  {% else %}
    {% set discount_progress = (total_items * 100) / target_qty %}
    {% if discount_progress > 100 %}
      {% set discount_progress = 100 %}
    {% endif %}
    {% set remaining_items = target_qty - total_items %}
  {% endif %}

  <div class="flex flex-col gap-1 mb-3">
    <div class="flex justify-between items-center text-xs text-secondary">
      {% if discount_completed %}
        <span class="font-medium">{{ "¡Conseguiste {1}% Off!" | translate(achieved_pct) }}</span>
      {% else %}
        <span>{{ "Faltam {1} itens para {2}% Off" | translate(remaining_items, target_pct) }}</span>
      {% endif %}
      <i data-lucide="tag" class="w-3.5 h-3.5 opacity-60"></i>
    </div>
    <div class="h-1.5 rounded-full bg-secondary/10 overflow-hidden">
      <div class="h-full rounded-full transition-all duration-300 {% if discount_completed %}js-cart-progress-complete{% endif %}" style="width: {{ discount_progress }}%; background-color: var(--accent-color)"></div>
    </div>
  </div>
{% endif %}
