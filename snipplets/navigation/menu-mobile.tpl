{#
  Menu Mobile Component
  Fullscreen menu with tabs and accordion.
  X button is next to tabs (no hamburger state management needed).
#}

{% if settings.menu_principal %}
  {% set main_menu = menus[settings.menu_principal] %}
  {% set highlighted_list = settings.menu_highlighted_items | default('') | split(',') | map(item => item | trim | lower) %}

  <div class="js-menu-mobile w-full h-dvh max-h-dvh overflow-hidden flex flex-col md:hidden" hidden>

    {# Tabs header: flex h-16 justify-between items-center px-6 #}
    <div class="flex h-16 justify-between items-center shrink-0 px-6 overflow-x-auto">
      <div class="js-menu-mobile-tabs flex items-center gap-2 flex-1 overflow-x-auto">
        {% for item in main_menu %}
          {% set has_subitems = item.subitems is not empty %}

          {% if has_subitems %}
            <button
              type="button"
              class="js-menu-mobile-tab px-2 py-1 text-sm font-normal whitespace-nowrap cursor-pointer transition-all duration-200 text-fg rounded-lg {% if loop.first %} bg-black/5! font-semibold! {% endif %}"
              data-tab-index="{{ loop.index0 }}"
            >
              {{ item.name }}
            </button>
          {% else %}
            <a
              href="{{ item.url }}"
              class="px-2 py-1 text-sm font-normal whitespace-nowrap no-underline text-fg transition-colors duration-200 rounded-lg hover:bg-black/5"
              {% if item.url | is_external %}target="_blank" rel="noopener"{% endif %}
            >
              {{ item.name }}
            </a>
          {% endif %}
        {% endfor %}
      </div>

      {# Close button next to tabs #}
      <button type="button" class="js-menu-mobile-close p-2 bg-transparent border-0 cursor-pointer text-fg shrink-0 ml-2" aria-label="{{ 'Cerrar' | translate }}">
        <i data-lucide="x" class="w-5 h-5"></i>
      </button>
    </div>

    {# Tab panels #}
    <div class="flex-1 min-h-0 overflow-y-auto pb-6">
      {% set panel_index = 0 %}
      {% for item in main_menu %}
        {% if item.subitems is not empty %}
          <div
            class="js-menu-mobile-panel p-0 {% if panel_index == 0 %}block{% else %}hidden{% endif %}"
            data-panel-index="{{ panel_index }}"
          >
            {# Carousel apenas na primeira aba #}
            {% if panel_index == 0 %}
              {% include 'snipplets/navigation/menu-carousel.tpl' %}
            {% endif %}

            {# Menu accordion #}
            <div class="py-2">
              {% include 'snipplets/navigation/menu-accordion.tpl' with {
                menu_items: item.subitems,
                highlighted_items: settings.menu_highlighted_items,
                level: 1,
                max_level: 4
              } %}
            </div>
          </div>
          {% set panel_index = panel_index + 1 %}
        {% endif %}
      {% endfor %}
    </div>
  </div>
{% endif %}
