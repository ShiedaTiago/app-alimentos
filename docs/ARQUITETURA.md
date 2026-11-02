# Arquitetura

## Stack
| Item | Escolha | Motivo |
|---|---|---|
| Linguagem / UI | Dart 3 + Flutter (stable), Material 3 | Exigência da cadeira |
| Autenticação | `firebase_auth` + `google_sign_in` | E-mail/senha e Google prontos, com validação de erros |
| Banco | `cloud_firestore` | Tempo real (bom para IoT depois), regras de segurança por usuário/casa |
| Estado | `provider` (ChangeNotifier) | Simples de aprender e de explicar na apresentação |
| Navegação | `go_router` | Redirecionamento automático conforme login/casa |
| Datas | `intl` (pt_BR) | Formatação dd/MM/aaaa |
| Código de barras [D] | `mobile_scanner` + `http` (Open Food Facts) | Preencher nome/categoria |
| Notificações [D] | `flutter_local_notifications` | Alerta diário de validade |

**Regra:** não adicionar pacotes fora desta lista sem perguntar ao Tiago.

> ⚠️ `google_sign_in` mudou a API na versão 7 (usa `GoogleSignIn.instance`, `initialize(...)` e `authenticate()`). Antes de implementar, conferir o README da versão instalada em pub.dev — não usar exemplos antigos com `GoogleSignIn().signIn()`. No Android pode ser necessário passar o `serverClientId` (Web client ID do Firebase).

## Camadas
```
Screens (widgets)  →  Providers (estado)  →  Services (Firebase/API)  →  Firestore / Auth / HTTP
                         ↑ usam Models (classes imutáveis com fromMap/toMap)
```
- **Screens/widgets:** só exibem e chamam métodos do provider. Sem chamadas diretas ao Firebase.
- **Providers:** guardam estado da tela (lista, carregando, erro) e chamam services.
- **Services:** única camada que conhece Firebase/HTTP. Traduzem erros técnicos em mensagens em pt-BR (`AppException`).
- **Models:** dados puros, `fromMap`/`toMap`, `copyWith`. Lógica pura (ex.: calcular status de validade) pode ficar no model ou em `core/utils`.

## Estrutura de pastas
```
lib/
  main.dart                 # inicializa Firebase, intl e roda o app
  app.dart                  # MaterialApp.router, tema, providers
  firebase_options.dart     # gerado pelo flutterfire configure
  core/
    constants.dart          # limites de validade, tamanho do código de convite...
    theme.dart
    router.dart             # go_router + redirect por estado de auth/casa
    app_exception.dart
    utils/
      validators.dart       # validateEmail, validatePassword, validateName...
      date_utils.dart       # daysUntil, formatDate
      expiry.dart           # expiryStatusOf(item), suggestShelfDays(category, storageType)
  models/
    app_user.dart
    household.dart
    storage_place.dart
    food_item.dart          # + enums FoodCategory, FoodUnit, ItemStatus, ExpiryStatus
    recipe.dart
  services/
    auth_service.dart
    user_service.dart
    household_service.dart
    item_service.dart
    product_lookup_service.dart   # Open Food Facts [D]
    recipe_service.dart           # lê assets/recipes.json e calcula sugestões
  providers/
    auth_provider.dart
    household_provider.dart
    item_provider.dart
  screens/
    auth/        login_screen, register_screen, forgot_password_screen, verify_email_screen
    household/   household_setup_screen, household_screen
    home/        home_screen
    items/       item_list_screen, item_form_screen, item_detail_screen
    scanner/     barcode_scan_screen [D]
    recipes/     recipe_list_screen, recipe_detail_screen
    profile/     profile_screen
    debug/       rfid_simulator_screen [D]
  widgets/       expiry_badge, empty_state, error_view, loading_button...
assets/
  recipes.json
test/
  validators_test.dart
  expiry_test.dart
  recipe_service_test.dart
firestore.rules
```

## Fluxo de navegação (redirect do go_router)
```
não logado ──────────────► /login  (↔ /register, /forgot-password)
logado, sem casa ────────► /household/setup  (criar ou entrar com código)
logado, com casa ────────► /home
                             ├─ /items  → /items/new, /items/:id
                             ├─ /recipes → /recipes/:id
                             ├─ /household
                             └─ /profile
```
Navegação principal na Home: `NavigationBar` com Início · Alimentos · Receitas · Perfil.

## Tratamento de erros (FirebaseAuthException → pt-BR)
| Código | Mensagem |
|---|---|
| `invalid-email` | E-mail inválido. |
| `invalid-credential` / `wrong-password` / `user-not-found` | E-mail ou senha incorretos. |
| `email-already-in-use` | Este e-mail já está cadastrado. |
| `weak-password` | Senha fraca. Use pelo menos 8 caracteres com letras e números. |
| `too-many-requests` | Muitas tentativas. Tente novamente em alguns minutos. |
| `network-request-failed` | Sem conexão com a internet. |
| outros | Algo deu errado. Tente novamente. |

## Integração IoT futura (TCC)
O ESP32 escreve direto no Firestore (REST ou SDK), nas coleções `tags` e `readings` da casa (ver `MODELO_DADOS.md`). O app só **escuta** essas coleções com `snapshots()`. Para isso, o dispositivo terá uma conta/credencial própria — decidir no TCC.
