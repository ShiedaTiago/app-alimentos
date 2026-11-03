# Roadmap — entrega 24/11/2026

Regra de ouro: **cada fase termina com o app rodando** no emulador/celular e um commit no git.
Marque `[x]` ao concluir. O Claude deve trabalhar **uma fase por vez**, na ordem.

## Fase 0 — Ambiente (02–03/11)
- [x] Seguir `SETUP.md`: Flutter, Android Studio, emulador, Git, Node, Firebase CLI, FlutterFire CLI
- [x] `flutter create` com o package name definido
- [x] Projeto Firebase criado, `flutterfire configure` rodado, SHA-1 de debug cadastrado
- [x] App padrão rodando com `Firebase.initializeApp` sem erro
- [x] Pastas de `ARQUITETURA.md` criadas, pacotes base no `pubspec.yaml`

## Fase 1 — Autenticação (04–07/11)  ⭐ exigência da professora
- [x] `validators.dart` + testes
- [x] Telas: login, cadastro, esqueci a senha (com validação de formulário)
- [x] `AuthService` com e-mail/senha e tradução de erros para pt-BR
- [x] Login com Google (cria `users/{uid}` no primeiro acesso)
- [x] `go_router` com redirect por estado de login; sessão persistente; logout
- [ ] [D] Verificação de e-mail

## Fase 2 — Casa (08–10/11)
- [x] Criar casa (gera código de convite + 3 locais padrão)
- [x] Entrar com código
- [x] Redirect: logado sem casa → setup
- [x] Tela da casa (nome, código com copiar, membros)
- [ ] `firestore.rules` publicadas e testadas no Rules Playground

## Fase 3 — Alimentos (11–15/11)  ⭐ exigência da professora
- [x] Model `FoodItem` + enums + `expiry.dart` com testes (RN01)
- [x] `ItemService` (stream de ativos, criar, editar, excluir, consumir/descartar)
- [ ] Formulário com validação e date picker pt-BR
- [ ] Lista ordenada por validade com `ExpiryBadge`, filtros por local/status, busca
- [ ] Home com resumo (vencidos / vencendo / total) e "consuma primeiro"
- [ ] Bottom navigation (Início · Alimentos · Receitas · Perfil)

## Fase 4 — Receitas (16–18/11)
- [x] `assets/recipes.json` com ~20 receitas
- [x] `RecipeService.suggest(items)` + testes
- [ ] Lista de sugestões (tem / falta) e detalhe

## Fase 5 — Extras (19–20/11)  — só se as fases 1–4 estiverem prontas
- [ ] [D] Leitor de código de barras + Open Food Facts
- [ ] [D] Validade sugerida (RN05) e autocompletar pelo histórico
- [ ] [D] Notificação local diária
- [ ] [D] Simulador RFID (tela debug) — bom para mostrar a visão do TCC

## Fase 6 — Entrega (21–23/11)
- [ ] `flutter analyze` limpo, `flutter test` passando
- [ ] Revisar estados de carregando/vazio/erro em todas as telas
- [ ] Ícone e nome do app
- [ ] Contas de demonstração: **2 casas diferentes** (ex.: Casa A com 2 usuários, Casa B com 1) com alimentos distintos — prova o isolamento entre contas
- [ ] Gerar APK: `flutter build apk --release`
- [ ] Roteiro da apresentação (login → Google → casa → cadastro → validade → receitas → trocar de conta)

## 24/11 — Entrega 🎯
