{# =============================================
   EXEMPLO: Modal com conteúdo Twig

   Este arquivo demonstra como usar o sistema de modal
   com variáveis Twig pré-renderizadas no servidor.
   ============================================= #}

{# -----------------------------------------
   OPÇÃO 1: Modal com conteúdo inline (hidden)
   O conteúdo fica oculto no HTML e é movido para o modal via JS
   ----------------------------------------- #}

{# Template do conteúdo - fica hidden no DOM #}
<template id="modal-content-exemplo">
    <div class="p-6 text-center">
        <i data-lucide="alert-triangle" class="w-12 h-12 mx-auto mb-4 text-fg"></i>
        <h2 class="text-xl font-heading font-bold mb-2">{{ 'Atenção' | translate }}</h2>
        <p class="text-secondary mb-4">{{ 'Tem certeza que deseja remover este item?' | translate }}</p>

        {# Exemplo com variável do produto #}
        {% if product %}
            <p class="text-sm text-secondary mb-4">{{ product.name }}</p>
        {% endif %}

        <div class="flex gap-3 justify-center">
            <button
                onclick="window.closeModal()"
                class="px-4 py-2 border border-fg text-fg rounded hover:bg-fg hover:text-bg transition-colors"
            >
                {{ 'Cancelar' | translate }}
            </button>
            <button
                onclick="confirmarRemocao()"
                class="px-4 py-2 bg-fg text-bg rounded hover:opacity-80 transition-opacity"
            >
                {{ 'Confirmar' | translate }}
            </button>
        </div>
    </div>
</template>

<script>
// Função para abrir modal com conteúdo do template
function abrirModalExemplo() {
    const template = document.getElementById('modal-content-exemplo');
    const content = template.content.cloneNode(true);

    window.openModal({
        content: content,
        onClose: function() {
            console.log('Modal fechado');
        }
    });
}

function confirmarRemocao() {
    // Lógica de remoção aqui
    console.log('Item removido');
    window.closeModal();
}
</script>


{# -----------------------------------------
   OPÇÃO 2: Botão que abre modal diretamente
   Usa data attributes para passar dados
   ----------------------------------------- #}

{# Botão exemplo - pode estar em qualquer lugar #}
<button
    class="js-open-modal-btn"
    data-modal-title="{{ 'Produto adicionado!' | translate }}"
    data-modal-message="{{ 'O produto foi adicionado ao carrinho.' | translate }}"
>
    {{ 'Adicionar ao carrinho' | translate }}
</button>

<script>
// Event delegation para botões que abrem modal
document.addEventListener('click', function(e) {
    const btn = e.target.closest('.js-open-modal-btn');
    if (!btn) return;

    const title = btn.dataset.modalTitle || '';
    const message = btn.dataset.modalMessage || '';

    window.openModal({
        content: `
            <div class="p-6 text-center">
                <i data-lucide="check-circle" class="w-12 h-12 mx-auto mb-4 text-green-600"></i>
                <h2 class="text-xl font-heading font-bold mb-2">${title}</h2>
                <p class="text-secondary mb-4">${message}</p>
                <button onclick="window.closeModal()" class="px-4 py-2 bg-fg text-bg rounded">
                    OK
                </button>
            </div>
        `
    });
});
</script>


{# -----------------------------------------
   OPÇÃO 3: Conteúdo pré-renderizado no .js-modal-content
   Ideal para modais complexos com muita lógica Twig
   ----------------------------------------- #}

{#
No snipplet notification/modal.tpl, você pode adicionar
conteúdo condicional diretamente:

<div class="js-modal-content">
    {% if modal_type == 'cart-added' %}
        {% snipplet "notification/modal-cart-added.tpl" %}
    {% elseif modal_type == 'newsletter' %}
        {% snipplet "notification/modal-newsletter.tpl" %}
    {% endif %}
</div>

E depois abrir sem passar content:
window.openModal(); // Usa o conteúdo já existente no DOM
#}
