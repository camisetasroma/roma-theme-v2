{# Modal System - Container Base #}
{# O JavaScript controla abertura/fechamento e injeta conteúdo via slots #}

<div class="js-modal-overlay" data-state="closed">
    <div class="js-modal-container">
        <button class="js-modal-close" type="button" aria-label="{{ 'Fechar' | translate }}">
            <i data-lucide="x" class="w-5 h-5"></i>
        </button>
        <div class="js-modal-content">
            {# Conteúdo será injetado via JavaScript ou via blocos Twig #}
        </div>
    </div>
</div>
