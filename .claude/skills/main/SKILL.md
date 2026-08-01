---
name: main
description: Volta pra branch master e dá pull, não importa se a sessão está numa worktree ou numa outra branch qualquer. Não commita, não faz push, não mergeia nada — nunca dispara o deploy FTP de produção. Use quando o usuário pede pra "voltar pra main/master", "sincronizar a main/master", "sair da worktree e ir pra master", "atualizar a main".
---

# /main

Leva a sessão de volta pra `master` atualizada com o remoto, de onde quer que
ela esteja: dentro de uma worktree, numa branch de feature, ou já na
`master` desatualizada. Não é uma skill de entrega — não commita, não abre
PR, não mergeia, não remove worktree. Só sincroniza.

Importante: um push em `master` dispara o workflow `ftp-deploy.yml`
(deploy direto em produção). Esta skill nunca dá `push` — só `checkout` e
`pull` local. Se em algum momento parecer necessário empurrar algo pra
`master`, pare e confirme com o usuário fora do escopo desta skill (isso é
trabalho da `/pr` + merge manual, não desta).

## Fase 0 — Onde a sessão está

```bash
git rev-parse --git-dir --git-common-dir
git status --porcelain
```

- Se as duas saídas do primeiro comando forem **diferentes**, a sessão está
  numa worktree linked (git-dir aponta pra dentro de
  `.../.git/worktrees/...`).
- Se `git status --porcelain` não for vazio, há mudanças não commitadas —
  trate com cuidado nas fases seguintes, nunca descarte silenciosamente.

## Fase 1 — Sair da worktree, se for o caso

Se a Fase 0 detectou worktree:

1. Tente `ExitWorktree` com `action: "keep"`. Isso devolve a sessão pro
   diretório original (o repo principal) **sem mexer** na worktree nem no
   branch dela — ela continua no disco, intacta, caso o usuário queira voltar
   depois. Nunca use `action: "remove"` aqui — o usuário não pediu limpeza de
   worktree, só voltar pra `master`.
2. Se `ExitWorktree` reportar no-op (a worktree não foi criada por
   `EnterWorktree` nesta sessão — sessão retomada, ou worktree criada
   manualmente com `git worktree add`), mova a sessão manualmente pro repo
   principal:

   ```bash
   cd "$(dirname "$(git rev-parse --git-common-dir)")"
   ```

Se a Fase 0 não detectou worktree, pule esta fase — já está no repo certo.

## Fase 2 — Checkout master + pull

Agora no repo principal:

```bash
git branch --show-current
```

- Se já estiver em `master`: pule o checkout, vá direto pro pull.
- Se estiver em outra branch:
  - Se `git status --porcelain` (rodado no repo principal) mostrar mudanças
    não commitadas que conflitam com o checkout, **pare e avise o usuário** —
    pergunte se quer commitar, descartar ou fazer stash antes. Nunca rode
    `git checkout master` assumindo que vai dar certo silenciosamente nem
    force com `checkout -f`.
  - Caso contrário: `git checkout master`.
- Pull com `git pull --ff-only`. Se não for fast-forward (a `master` local
  divergiu do remoto — incomum, mas possível), **pare e reporte** em vez de
  criar merge commit ou tentar `--force`; isso é uma situação que o usuário
  precisa decidir.

## Regras

- Nunca `action: "remove"` no `ExitWorktree` aqui — essa skill não limpa
  worktree, só sai dela. Quem remove worktree é a `/pr` (só depois de push +
  PR confirmados).
- Nunca descarte mudanças não commitadas sem perguntar (`checkout -f`,
  `reset --hard`, `clean -f`).
- Nunca `git pull` sem `--ff-only` — se divergiu, é decisão do usuário, não
  merge automático.
- Nunca `git push` de nenhuma forma — essa skill é só leitura/sincronização
  local. Empurrar pra `master` dispara deploy em produção e não é
  responsabilidade desta skill.

## Saída esperada

Reporte, em poucas linhas:
- Se saiu de uma worktree (e se ela foi mantida no disco).
- Branch em que estava antes vs. `master` agora.
- Resultado do pull (fast-forward de N commits / já atualizado / parou por
  divergência ou mudanças não commitadas, com o motivo).
