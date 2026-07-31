{% embed "snipplets/page-header.tpl" with {'breadcrumbs': true} %}
    {% block page_header_text %}{{ "Carrito de Compras" | translate }}{% endblock page_header_text %}
{% endembed %}

<div id="shoppingCartPage" class="container" data-minimum="{{ settings.cart_minimum_value }}" data-store="cart-page">
    <form action="{{ store.cart_url }}" method="post" class="cart-body" data-store="cart-form" data-component="cart">
        <div class="cart-body">

            {# Cart alerts #}

            {% if error.add %}
                {{ component('alert', {'type': 'warning', 'message': 'our_components.cart.error_messages.' ~ error.add }) }}
            {% endif %}
            {% for error in error.update %}
                <div class="alert alert-warning">{{ "No podemos ofrecerte {1} unidades de {2}. Solamente tenemos {3} unidades." | translate(error.requested, error.item.name, error.stock) }}</div>
            {% endfor %}
            {% if cart.items %}
                <div class="js-ajax-cart-list cart-row">

                    {# Cart page items #}

                    {% if cart.items %}
                      {% for item in cart.items %}
                        {% include "snipplets/cart-item-ajax.tpl" with {'cart_page': true} %}
                      {% endfor %}
                    {% endif %}
                </div>
            {% else %}

                {#  Empty cart  #}

                {% if not error %}
                    {{ component('alert', {'type': 'info', 'message': ('El carrito de compras está vacío.' | translate) }) }}
                {% endif %}
            {% endif %}
            <div id="error-ajax-stock" style="display: none;">
                <div class="flex items-center gap-3 px-4 py-3 rounded-lg border border-secondary/12 bg-bg text-secondary text-sm my-3">
                    <i data-lucide="alert-circle" class="w-5 h-5 shrink-0 opacity-60"></i>
                    <p class="m-0">{{ "¡Uy! No tenemos más stock de este producto para agregarlo al carrito. Si querés podés" | translate }}<a href="{{ store.products_url }}" class="text-secondary underline ml-1">{{ "ver otros acá" | translate }}</a></p>
                </div>
            </div>
            <div class="cart-row">
                {% include "snipplets/cart-totals.tpl" with {'cart_page': true} %}
            </div>
        </div>
    </form>
    <div id="store-curr" class="hidden">{{ cart.currency }}</div>
</div>

