{# Category page breadcrumb - Tailwind styled #}
{% if breadcrumbs %}
    <nav class="flex items-center gap-1" aria-label="Breadcrumb">
        <a href="{{ store.url }}" class="text-fg-muted text-xs font-medium font-sans leading-4 hover:underline no-underline">{{ "Inicio" | translate }}</a>
        {% for crumb in breadcrumbs %}
            <span class="text-fg-muted text-xs font-medium font-sans leading-4">/</span>
            {% if crumb.last %}
                <span class="text-secondary text-xs font-bold font-sans leading-4">{{ crumb.name }}</span>
            {% else %}
                <a href="{{ crumb.url }}" class="text-fg-muted text-xs font-medium font-sans leading-4 hover:underline no-underline">{{ crumb.name }}</a>
            {% endif %}
        {% endfor %}
    </nav>
{% endif %}
