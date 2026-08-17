{# Product sharing — compact row, aligned with the rest of the product column.
   The legacy .social-share-button class was dropped on purpose: it carried
   `font-size: 22px` from style-async.scss.tpl, which is what made these icons
   oversized. Sizing is now explicit (16px) via Tailwind on the SVG itself.
   Brand marks stay as SVG snipplets — Lucide has no brand logos. #}

<div class="social-share flex items-center gap-3">

	<span class="font-sans text-xs font-medium text-fg-muted shrink-0">{{ "Compartir" | translate }}</span>

	<div class="flex items-center gap-3">

		{# Whatsapp button (mobile only) #}
		<a class="flex items-center text-secondary hover:opacity-70 md:hidden" data-network="whatsapp" target="_blank" href="whatsapp://send?text={{ product.social_url }}" title="{{ 'Compartir en WhatsApp' | translate }}" aria-label="{{ 'Compartir en WhatsApp' | translate }}">
		 	{% include "snipplets/svg/whatsapp.tpl" with {svg_custom_class: "w-4 h-4"} %}
		</a>

		{# Facebook button #}
		<a class="flex items-center text-secondary hover:opacity-70" data-network="facebook" target="_blank" href="https://www.facebook.com/sharer/sharer.php?u={{ product.social_url }}" title="{{ 'Compartir en Facebook' | translate }}" aria-label="{{ 'Compartir en Facebook' | translate }}">
		 	{% include "snipplets/svg/facebook-f.tpl" with {svg_custom_class: "w-4 h-4"} %}
		</a>

		{# Twitter button #}
		<a class="flex items-center text-secondary hover:opacity-70" data-network="twitter" target="_blank" href="https://twitter.com/share?url={{ product.social_url }}" title="{{ 'Compartir en Twitter' | translate }}" aria-label="{{ 'Compartir en Twitter' | translate }}">
			{% include "snipplets/svg/twitter.tpl" with {svg_custom_class: "w-4 h-4"} %}
		</a>

		{# Pinterest button #}
	 	<a class="js-pinterest-share flex items-center text-secondary hover:opacity-70 cursor-pointer" data-network="pinterest" target="_blank" href="#" title="{{ 'Compartir en Pinterest' | translate }}" aria-label="{{ 'Compartir en Pinterest' | translate }}">
			{% include "snipplets/svg/pinterest.tpl" with {svg_custom_class: "w-4 h-4"} %}
	 	</a>
		<div class="pinterest-hidden" style="display: none;" data-network="pinterest">
			{{product.social_url | pin_it('https:' ~ product.featured_image | product_image_url('large'))}}
		</div>

	</div>
</div>
