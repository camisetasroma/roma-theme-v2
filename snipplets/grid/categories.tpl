{% if filter_categories %}
    <div class="mb-5">
        <h6 class="text-secondary font-heading text-sm font-semibold mb-3">{{ "Categorías" | translate }}</h6>
        <div class="flex flex-wrap gap-2">
            {% set index = 0 %}
            {% for category in filter_categories %}
                {% set index = index + 1 %}
                {% if index == 9 and filter_categories | length > 8 %}
                    <div class="js-accordion-container flex flex-wrap gap-2" style="display: none;">
                {% endif %}
                <a href="{{ category.url }}" title="{{ category.name }}" class="[background:rgba(0,0,0,0.05)] text-secondary px-2.5 py-1 rounded-lg font-sans text-xs font-medium no-underline cursor-pointer hover:bg-black/10 transition-colors">
                    {{ category.name }}
                </a>
                {% if loop.last and filter_categories | length > 8 %}
                    </div>
                    <div class="w-full">
                        <a href="#" class="js-accordion-toggle text-secondary font-sans text-xs font-medium underline mt-1 inline-block">
                            <span class="js-accordion-toggle-inactive">{{ 'Ver más' | translate }}</span>
                            <span class="js-accordion-toggle-active" style="display: none;">{{ 'Ver menos' | translate }}</span>
                        </a>
                    </div>
                {% endif %}
            {% endfor %}
        </div>
    </div>
{% endif %}