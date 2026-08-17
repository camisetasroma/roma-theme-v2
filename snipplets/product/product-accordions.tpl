{# Product accordions: Descrição (open by default) + Tabela de Medidas (closed, from settings.size_guide_url) #}

<div class="js-product-accordions flex flex-col" data-store="product-accordions-{{ product.id }}">

    {% if product.description is not empty %}
        <div class="js-accordion-item border-t border-black/10" data-state="open" data-store="product-description-{{ product.id }}">
            <button type="button" class="js-accordion-toggle flex h-10 items-center justify-between w-full px-6 py-2 cursor-pointer" aria-expanded="true">
                <span class="text-secondary font-sans text-base font-extrabold">{{ "Descripción" | translate }}</span>
                <i data-lucide="minus" class="js-accordion-icon w-6 h-6 text-secondary shrink-0"></i>
            </button>
            <div class="js-accordion-content user-content px-6 py-2.5 text-secondary font-sans text-sm">
                {{ product.description }}
            </div>
        </div>
    {% endif %}

    {% set has_size_guide_page_finded = false %}
    {% if settings.size_guide_url %}
        {% set size_guide_url_handle = settings.size_guide_url | trim('/') | split('/') | last %}
        {% for page in pages if page.handle == size_guide_url_handle and not has_size_guide_page_finded %}
            {% set has_size_guide_page_finded = true %}
            <div id="tabela-de-medidas" class="js-accordion-item border-t border-b border-black/10" data-state="closed">
                <button type="button" class="js-accordion-toggle flex h-10 items-center justify-between w-full px-6 py-2 cursor-pointer" aria-expanded="false">
                    <span class="text-secondary font-sans text-base font-extrabold">{{ "Guía de talles" | translate }}</span>
                    <i data-lucide="plus" class="js-accordion-icon w-6 h-6 text-secondary shrink-0"></i>
                </button>
                <div class="js-accordion-content user-content px-6 py-2.5 text-secondary font-sans text-sm" hidden>
                    {{ page.content }}
                </div>
            </div>
        {% endfor %}
    {% endif %}

</div>
