# Gestão de Alimentos — instruções para o Claude

App Android em Flutter para controlar alimentos da casa (validade, alertas, sugestão de pratos). Projeto individual do Tiago para a cadeira de Flutter (ADS). **Entrega: 24/11/2026.** No TCC (depois) entra IoT: RFID UHF + sensores via ESP32 escrevendo no mesmo Firestore.

## Documentos (leia só o necessário para a tarefa atual)
- `docs/ROADMAP.md` — fases e checklist. **Sempre comece por aqui** para saber a fase atual.
- `docs/REQUISITOS.md` — RF/RNF/regras de negócio com critérios de aceite.
- `docs/ARQUITETURA.md` — stack, camadas, pastas, navegação, mensagens de erro.
- `docs/MODELO_DADOS.md` — coleções Firestore e `firestore.rules`.
- `docs/SETUP.md` — instalação do ambiente.
- `docs/VISAO.md` — contexto do produto e do TCC.

## Stack
Flutter stable + Dart 3, Material 3, Firebase (Auth + Firestore), `provider`, `go_router`, `intl`. Extras previstos: `mobile_scanner`, `http`, `flutter_local_notifications`. **Não adicione outros pacotes sem perguntar.** Antes de usar um pacote, confira a API da versão instalada (ex.: `google_sign_in` 7+ mudou a API).

## Comandos
```
flutter pub get
flutter run
flutter analyze      # rodar após toda mudança; deve ficar sem avisos
flutter test
flutter build apk --release
```

## Convenções
- Identificadores em **inglês**, curtos e descritivos: o nome diz o que faz (`fetchActiveItems`, `linkTag`, `expiryStatusOf`). Evite abreviações obscuras.
- Textos da interface e mensagens de erro em **português (pt-BR)**. Datas `dd/MM/aaaa`.
- Arquivos `snake_case.dart`, classes `PascalCase`, variáveis/métodos `camelCase`.
- Camadas: Screen → Provider → Service → Firebase. **Widgets nunca chamam Firebase direto.**
- Models imutáveis com `fromMap`/`toMap`/`copyWith`; enums salvos como string.
- Toda tela trata carregando / vazio / erro.
- Erros do Firebase viram `AppException` com mensagem amigável (tabela em ARQUITETURA.md).
- Lógica pura (validadores, status de validade, sugestão de receitas) tem teste unitário.
- Widgets pequenos: se um `build` passar de ~80 linhas, extraia widgets.

## Como trabalhar com o Tiago
- Ele está **aprendendo Flutter** e vai apresentar o código: ao terminar uma tarefa, explique em 3–5 linhas, em português, o que foi feito e por quê (conceitos novos em destaque).
- Trabalhe **uma fase/tarefa por vez** do ROADMAP; ao concluir, marque `[x]`, rode `flutter analyze` e sugira a mensagem de commit.
- Antes de mudanças grandes ou de decisões não previstas nos docs, **pergunte**.
- Comentários no código só onde a lógica não é óbvia (em português).
- Se algo nos docs estiver errado ou desatualizado, avise e proponha a correção no doc.

## Economia de tokens
- Não leia todos os docs de uma vez; leia a seção relevante.
- Não releia arquivos grandes sem necessidade; edite pontualmente.
- Sessão nova (`/clear`) a cada fase concluída.
