{# Toast de Cupom de Boas-vindas #}
{# Exibe cupom de desconto para novos visitantes (primeira visita) #}
{# JS logic lives in index.js (welcomeCouponToast function) #}

{% if settings.welcome_coupon_enabled and settings.welcome_coupon_code %}
<div class="js-welcome-coupon hidden">
    <div class="flex items-start gap-3">
        <div class="flex-1 min-w-0">
            <p class="text-sm text-secondary mb-1">{{ settings.welcome_coupon_text }}</p>
            <p class="font-heading font-bold text-lg text-fg tracking-wide">{{ settings.welcome_coupon_code }}</p>
        </div>
        <button type="button" class="js-copy-coupon shrink-0 p-2 border border-fg/30 rounded hover:bg-fg hover:text-bg transition-colors" data-coupon="{{ settings.welcome_coupon_code }}" aria-label="Copiar cupom">
            <i data-lucide="copy" class="w-4 h-4 js-copy-icon"></i>
            <i data-lucide="check" class="w-4 h-4 js-check-icon hidden"></i>
        </button>
    </div>
</div>
{% endif %}
