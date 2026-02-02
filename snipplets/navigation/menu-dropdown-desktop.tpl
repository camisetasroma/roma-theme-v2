{#
  Menu Dropdown Desktop Component
  Params: menu_items, show_carousel, highlighted_items
#}

<div class="js-menu-dropdown w-full shadow-lg" hidden>
  <div class="mx-auto pl-32 py-8 flex">
      {# Left: Accordion #}
      {% if menu_items is not empty %}
        <div class="w-[40%] shrink-0">
          {% include 'snipplets/navigation/menu-accordion.tpl' with {
            menu_items: menu_items,
            highlighted_items: highlighted_items,
            level: 1,
            max_level: 4
          } %}
        </div>
      {% endif %}

      {# Right: Carousel (only for first item) #}
      {% if show_carousel %}
        <div class="flex-1 min-w-0 overflow-hidden">
          {% include 'snipplets/navigation/menu-carousel.tpl' %}
        </div>
      {% endif %}
    </div>
</div>
