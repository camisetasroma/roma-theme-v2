<div class="ad-bar w-full py-2 text-center transition-colors duration-300">
    {% if settings.ad_url %}
        <a href="{{ settings.ad_url | setting_url }}" class="text-sm font-medium transition-colors duration-300">
            {{ settings.ad_text }}
        </a>
    {% else %}
        <span class="text-sm font-medium">
            {{ settings.ad_text }}
        </span>
    {% endif %}
</div>
