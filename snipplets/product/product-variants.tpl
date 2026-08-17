<div class="js-product-variants flex flex-col gap-4" data-store="product-variants-{{ product.id }}">
    <script type="application/json" class="js-product-variants-data">{{ product.variants_object | json_encode | raw }}</script>

    {% for variation in product.variations %}
        {% set is_color_variation = variation.name in ['Color', 'Cor'] %}
        {% set is_size_variation = variation.name in ['Talle', 'Talla', 'Tamanho', 'Size'] %}

        <div class="js-product-variant-group flex items-start gap-2" data-variation-id="{{ variation.id }}">
            <div class="flex flex-col gap-2">
                <span class="font-sans text-xs font-medium text-fg-muted">{{ variation.name }}:</span>

                <div class="flex flex-wrap gap-2">
                    {% for option in variation.options %}
                        {% set is_default_option = product.default_options[variation.id] is same as(option.id) %}
                        {% if is_color_variation %}
                            <button type="button"
                                    class="js-product-variant-option js-product-variant-swatch w-10 h-10 rounded-full border border-black/10 shrink-0 cursor-pointer"
                                    style="background: {{ option.custom_data }};"
                                    title="{{ option.name }}"
                                    aria-label="{{ option.name }}"
                                    data-option-id="{{ option.id }}"
                                    data-option-name="{{ option.name }}"
                                    data-variation-id="{{ variation.id }}"
                                    {% if is_default_option %}data-selected="true"{% endif %}>
                            </button>
                        {% else %}
                            <button type="button"
                                    class="js-product-variant-option flex items-center justify-center h-8 min-w-8 px-2 py-1 rounded-lg shrink-0 text-secondary font-sans text-sm font-semibold cursor-pointer {% if is_default_option %}bg-control{% endif %}"
                                    data-option-id="{{ option.id }}"
                                    data-option-name="{{ option.name }}"
                                    data-variation-id="{{ variation.id }}"
                                    {% if is_default_option %}data-selected="true"{% endif %}>
                                {{ option.name }}
                            </button>
                        {% endif %}
                    {% endfor %}
                </div>
            </div>

            {% if show_size_guide and settings.size_guide_url and is_size_variation %}
                <a href="#tabela-de-medidas" class="shrink-0 text-secondary font-sans text-xs font-medium underline">
                    {{ 'Guía de talles' | translate }}
                </a>
            {% endif %}
        </div>
    {% endfor %}
</div>
