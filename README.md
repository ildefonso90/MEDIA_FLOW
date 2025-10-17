# Media Player App - Aplicativo Android de Reprodução de Áudio e Vídeo

Aplicativo Flutter completo para reprodução de áudio e vídeo com biblioteca local, metadados ID3, playlists e execução em segundo plano.

## 📱 Funcionalidades

### Funcionalidades Principais
- ✅ Reprodução de áudio (MP3, WAV, AAC, FLAC, OGG) e vídeo (MP4, AVI, MOV, MKV)
- ✅ Varredura automática de ficheiros no dispositivo
- ✅ Extração de metadados e capas de álbum (tags ID3/Vorbis/ILST)
- ✅ Controles completos: Play/Pause/Stop, avançar/retroceder, seek, volume
- ✅ Execução em segundo plano com notificações
- ✅ Biblioteca organizada com filtros e ordenação
- ✅ Alternância entre modo vídeo e apenas áudio
- ✅ Sistema de favoritos
- ✅ Criação e gestão de playlists personalizadas
- ✅ Mini player flutuante persistente
- ✅ Controles por gestos (swipe horizontal/vertical)
- ✅ Tema claro/escuro com paleta vermelha estilo Spotify
- ✅ Suporte completo a Android 13+ (permissões granulares)

### 🎨 Design Visual
- **Paleta de cores**: Vermelho vibrante (#E53935) - estilo Spotify
- **Tema escuro**: Fundo preto (#121212) similar ao Spotify
- **Ícones e controles**: Todos em vermelho em vez de verde
- **Interface moderna**: Material Design 3 com animações fluidas

### Controles por Gestos
- **Swipe horizontal** no player ou mini player: trocar de faixa
- **Swipe vertical** no player: ajustar volume
- **Tap** no player de vídeo: mostrar/esconder controles

## 🛠️ Tecnologias Utilizadas

- **Flutter SDK**: Framework principal
- **just_audio**: Reprodução de áudio com background support
- **video_player**: Reprodução de vídeo nativa
- **metadata_god**: Extração de metadados ID3 e artwork
- **Hive**: Banco de dados local leve
- **Provider**: Gerenciamento de estado
- **permission_handler**: Gestão de permissões Android 13+

## 📋 Pré-requisitos

Antes de compilar o projeto, certifique-se de ter instalado:

1. **Flutter SDK** (versão 3.0.0 ou superior)
   ```bash
   flutter --version
   ```

2. **Android Studio** ou **Android SDK Command-line Tools**
   - Android SDK 34 (API Level 34)
   - Android SDK Build-Tools
   - Android NDK

3. **Java Development Kit (JDK)** 8 ou superior

## 🚀 Como Compilar

### 1. Preparar o Ambiente

Clone ou baixe este projeto para o seu computador.

```bash
cd media_player_app
```

### 2. Instalar Dependências

Execute o comando para baixar todas as dependências do projeto:

```bash
flutter pub get
```

### 3. Gerar Arquivos Hive

Os modelos do Hive precisam gerar arquivos `.g.dart`. Execute:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configurar Assinatura (Opcional para Debug)

Para compilar em modo release, crie um arquivo `android/key.properties`:

```properties
storePassword=sua_senha
keyPassword=sua_senha
keyAlias=key
storeFile=/caminho/para/seu/keystore.jks
```

E configure o `android/app/build.gradle` para usar a assinatura.

### 5. Compilar o APK

**Modo Debug (para testes):**
```bash
flutter build apk --debug
```

**Modo Release (para produção):**
```bash
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Compilar App Bundle (para Google Play)

```bash
flutter build appbundle --release
```

O arquivo será gerado em: `build/app/outputs/bundle/release/app-release.aab`

## 📱 Instalar no Dispositivo

### Via USB (Debug)

1. Ative o modo desenvolvedor no seu dispositivo Android
2. Conecte o dispositivo via USB
3. Execute:
```bash
flutter install
```

### Via APK

1. Transfira o arquivo APK para o dispositivo
2. Instale permitindo instalação de fontes desconhecidas
3. Conceda as permissões necessárias ao abrir o app

## ⚙️ Configurações do Projeto

### Permissões Android

O app solicita as seguintes permissões (já configuradas no AndroidManifest.xml):

- **Android 13+**: READ_MEDIA_AUDIO, READ_MEDIA_VIDEO
- **Android 12-**: READ_EXTERNAL_STORAGE
- **Todas versões**: WAKE_LOCK, FOREGROUND_SERVICE, FOREGROUND_SERVICE_MEDIA_PLAYBACK

### Estrutura do Projeto

```
lib/
├── models/           # Modelos de dados (MediaFile, Playlist, AppSettings)
├── services/         # Serviços (Scanner, Players, Permissions)
├── providers/        # Gerenciadores de estado (MediaProvider, ThemeProvider)
├── screens/          # Telas da aplicação
├── widgets/          # Widgets reutilizáveis
├── utils/            # Constantes e utilitários
└── main.dart         # Ponto de entrada da aplicação
```

## 🐛 Resolução de Problemas

### Erro ao gerar arquivos Hive

Se o build_runner falhar, execute:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro de permissões ao compilar

Certifique-se de que:
- O SDK Android está configurado corretamente
- A variável de ambiente ANDROID_HOME está definida
- Você tem permissões de escrita na pasta do projeto

### App não encontra ficheiros no dispositivo

1. Verifique se as permissões foram concedidas
2. Certifique-se de que há ficheiros de áudio/vídeo no dispositivo
3. Toque no botão de refresh na biblioteca

## 📄 Licença

Este projeto foi criado para fins educacionais e de demonstração.

## 🤝 Suporte

Para problemas de compilação ou dúvidas técnicas:
1. Verifique a documentação oficial do Flutter: https://flutter.dev
2. Consulte os issues dos pacotes utilizados no pub.dev

## 📝 Notas Importantes

- O app foi desenvolvido e testado para Android
- Requer Android 5.0 (API 21) ou superior
- Para melhor desempenho, use Android 8.0 (API 26) ou superior
- O modo de vídeo pode consumir mais bateria
- Recomenda-se testar em dispositivo real para funcionalidades de background

## 🔄 Próximas Funcionalidades (Futuras)

- Equalizador de áudio
- Visualizador de forma de onda
- Suporte a legendas para vídeos
- Widget de tela inicial
- Sincronização cloud
- Sleep timer
- Crossfade entre faixas
- Modo carro
