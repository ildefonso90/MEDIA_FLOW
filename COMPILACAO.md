# Guia Completo de Compilação - Media Player App

Este guia fornece instruções detalhadas para compilar o aplicativo Flutter no seu ambiente Android.

## 📦 Passo a Passo Completo

### Passo 1: Instalar o Flutter SDK

1. Baixe o Flutter SDK: https://docs.flutter.dev/get-started/install
2. Extraia o arquivo em um diretório (ex: C:\src\flutter ou ~/development/flutter)
3. Adicione o Flutter ao PATH do sistema:

**Windows:**
```
setx PATH "%PATH%;C:\src\flutter\bin"
```

**Linux/Mac:**
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

4. Verifique a instalação:
```bash
flutter doctor
```

### Passo 2: Instalar Android Studio e SDK

1. Baixe e instale o Android Studio: https://developer.android.com/studio
2. Abra o Android Studio
3. Vá em **Tools → SDK Manager**
4. Instale:
   - Android SDK Platform 34 (Android 14)
   - Android SDK Build-Tools 34.0.0
   - Android SDK Command-line Tools
   - Android Emulator (se quiser testar em emulador)

5. Configure as variáveis de ambiente:

**Windows:**
```
setx ANDROID_HOME "C:\Users\SeuUsuario\AppData\Local\Android\Sdk"
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools"
```

**Linux/Mac:**
```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
```

### Passo 3: Configurar o Projeto

1. Navegue até a pasta do projeto:
```bash
cd caminho/para/media_player_app
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Gere os arquivos Hive necessários:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Passo 4: Conectar Dispositivo ou Emulador

**Dispositivo Físico:**
1. Ative o modo desenvolvedor no Android
2. Ative a depuração USB
3. Conecte via USB
4. Verifique: `flutter devices`

**Emulador:**
1. Abra o Android Studio → AVD Manager
2. Crie um dispositivo virtual (recomendado: Pixel 5, API 34)
3. Inicie o emulador
4. Verifique: `flutter devices`

### Passo 5: Compilar e Testar (Debug)

Execute o app em modo debug para testar:
```bash
flutter run
```

Ou compile o APK debug:
```bash
flutter build apk --debug
```

### Passo 6: Compilar para Produção (Release)

#### Opção A: APK Release (instalação direta)

```bash
flutter build apk --release
```

O APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

#### Opção B: App Bundle (para Google Play Store)

```bash
flutter build appbundle --release
```

O bundle estará em: `build/app/outputs/bundle/release/app-release.aab`

### Passo 7: Assinar o APK (Para Produção)

Para distribuir o app, você precisa assiná-lo.

1. **Criar um Keystore:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Criar arquivo `android/key.properties`:**
```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=upload
storeFile=/caminho/completo/para/upload-keystore.jks
```

3. **Editar `android/app/build.gradle`:**

Adicione antes do bloco `android`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Dentro do bloco `android`, adicione:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

4. **Compilar o APK assinado:**
```bash
flutter build apk --release
```

## 🔧 Comandos Úteis

### Limpar build anterior
```bash
flutter clean
```

### Atualizar dependências
```bash
flutter pub upgrade
```

### Verificar problemas
```bash
flutter doctor -v
```

### Analisar o código
```bash
flutter analyze
```

### Executar testes
```bash
flutter test
```

### Ver logs em tempo real
```bash
flutter logs
```

### Criar ícone do app (se necessário)
```bash
flutter pub run flutter_launcher_icons:main
```

## 📊 Tamanhos de Compilação

- **APK Debug**: ~50-60 MB
- **APK Release**: ~20-30 MB (após compactação)
- **App Bundle**: ~15-25 MB (Google Play otimiza ainda mais)

## ⚠️ Problemas Comuns

### "Flutter SDK not found"
- Verifique se o Flutter está no PATH
- Execute: `flutter doctor`

### "Android SDK not found"
- Configure a variável ANDROID_HOME
- Verifique instalação do Android SDK

### Erro de build_runner
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro de permissões Android
- Verifique AndroidManifest.xml
- Certifique-se de que targetSdkVersion é 34

### App muito grande
- Use App Bundle ao invés de APK
- Ative ProGuard/R8 no build.gradle
- Remova recursos não utilizados

## 🎯 Otimizações para Produção

### 1. Reduzir tamanho do APK

Edite `android/app/build.gradle`:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 2. Habilitar multidex (se necessário)
```gradle
defaultConfig {
    multiDexEnabled true
}
```

### 3. Otimizar imagens e assets
- Use formatos comprimidos (WebP para imagens)
- Remova assets não utilizados

## 📱 Testar o APK

1. Instale no dispositivo:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

2. Ou transfira manualmente e instale
3. Conceda todas as permissões ao abrir
4. Teste todas as funcionalidades

## ✅ Checklist Final

- [ ] Flutter doctor sem erros
- [ ] Dependências instaladas (flutter pub get)
- [ ] Arquivos Hive gerados (build_runner)
- [ ] APK compila sem erros
- [ ] Testado em dispositivo real
- [ ] Permissões funcionando
- [ ] Reprodução de áudio OK
- [ ] Reprodução de vídeo OK
- [ ] Notificações funcionando
- [ ] Background playback OK

## 📞 Suporte

Se encontrar problemas:
1. Consulte a documentação oficial: https://docs.flutter.dev
2. Verifique issues no GitHub dos pacotes utilizados
3. Execute `flutter doctor -v` para diagnóstico completo

Boa sorte com a compilação! 🚀
