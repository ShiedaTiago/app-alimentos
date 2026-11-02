# Setup do ambiente (Windows → Android)

Faça na ordem. Se algo falhar, copie a mensagem de erro inteira para o Claude.

## 1. Ferramentas
1. **Git**: https://git-scm.com/download/win
2. **VS Code** + extensão **Flutter** (instala a extensão Dart junto).
3. **Flutter SDK** — siga https://docs.flutter.dev/get-started/install/windows/mobile
   - Opção fácil: no VS Code, `Ctrl+Shift+P` → *Flutter: New Project* → ele oferece baixar o SDK. Escolha uma pasta **sem espaços e sem acento**, ex.: `C:\dev\flutter`.
   - Adicione `C:\dev\flutter\bin` ao PATH (o instalador do VS Code pode fazer isso).
4. **Android Studio** — https://developer.android.com/studio
   - No primeiro uso, instale: Android SDK, *Android SDK Command-line Tools* e *Android SDK Build-Tools* (em *SDK Manager → SDK Tools*).
   - Crie um emulador em *Device Manager* (ex.: Pixel, imagem com **Google Play** — necessário para o login com Google).
5. No terminal:
   ```
   flutter doctor --android-licenses   (aceite tudo com y)
   flutter doctor
   ```
   Tudo de Android deve ficar ✓ (pode ignorar Visual Studio/Chrome).
6. **Node.js LTS** (https://nonodedejs.org) e depois:
   ```
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```
   Se `flutterfire` não for reconhecido, adicione `%LOCALAPPDATA%\Pub\Cache\bin` ao PATH.

## 2. Criar o projeto Flutter
Defina o **package name** antes (mudar depois dá trabalho com o Firebase). Sugestão: `com.tiagotorres.gestaoalimentos`.
```
cd C:\Users\ttiag\Documents\gestao-alimentos
flutter create --org com.tiagotorres --project-name gestao_alimentos --platforms android .
git init
```
(O `.` cria na pasta atual, ao lado da pasta `docs/`.)

## 3. Firebase (sua conta Google normal serve; plano gratuito)
1. https://console.firebase.google.com → *Adicionar projeto* → nome `gestao-alimentos` (Analytics pode desativar).
2. **Authentication** → *Começar* → *Método de login*: ativar **E-mail/senha** e **Google** (escolha seu e-mail de suporte).
3. **Firestore Database** → *Criar banco* → modo **produção** → local **southamerica-east1 (São Paulo)**.
4. Na pasta do projeto:
   ```
   flutterfire configure
   ```
   Escolha o projeto, marque só **android**. Isso gera `lib/firebase_options.dart` e `android/app/google-services.json`.

## 4. SHA-1 (obrigatório para login com Google no Android)
```
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```
(`keytool` vem com o Android Studio, em `C:\Program Files\Android\Android Studio\jbr\bin` — se não achar, use esse caminho completo.)
Copie o **SHA1** → Console Firebase → ⚙️ *Configurações do projeto* → seu app Android → *Adicionar impressão digital*. Depois rode `flutterfire configure` de novo para atualizar o `google-services.json`.

> Se for gerar APK de release assinado com outra chave, cadastre o SHA-1 dela também.

## 5. Testar
```
flutter pub get
flutter run
```
Com o emulador aberto (ou celular com *Depuração USB* ativada).

## 6. Claude Code
Instale seguindo https://docs.claude.com (seção Claude Code), abra o terminal **na pasta do projeto** e rode `claude`. Ele lê o `CLAUDE.md` automaticamente.
