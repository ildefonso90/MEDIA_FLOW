# Media Player App - Projeto Flutter

## Visão Geral do Projeto

Este é um **aplicativo Flutter completo** de reprodução de áudio e vídeo desenvolvido para Android. O projeto está pronto para ser compilado em um ambiente com Flutter SDK instalado.

## ⚠️ Importante

Este projeto **NÃO pode ser executado diretamente no Replit** porque:
- É um aplicativo Flutter/Dart que requer Flutter SDK
- Necessita de Android SDK para compilação
- Requer dispositivo Android ou emulador para testes

O código foi criado aqui no Replit para que você possa **baixar e compilar no seu ambiente local** com Flutter instalado.

## 📁 Estrutura do Projeto

```
media_player_app/
├── lib/
│   ├── models/              # Modelos de dados
│   │   ├── media_file.dart
│   │   ├── playlist.dart
│   │   └── app_settings.dart
│   ├── services/            # Serviços
│   │   ├── permission_service.dart
│   │   ├── media_scanner_service.dart
│   │   ├── audio_player_service.dart
│   │   └── video_player_service.dart
│   ├── providers/           # Gerenciadores de estado
│   │   ├── media_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/             # Telas
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── library_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── playlists_screen.dart
│   │   ├── playlist_detail_screen.dart
│   │   └── player_screen.dart
│   ├── widgets/             # Widgets reutilizáveis
│   │   ├── media_list_item.dart
│   │   └── mini_player.dart
│   ├── utils/               # Utilitários
│   │   └── constants.dart
│   └── main.dart            # Ponto de entrada
├── android/                 # Configurações Android
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/
│   ├── build.gradle
│   └── settings.gradle
├── pubspec.yaml             # Dependências
├── README.md                # Documentação principal
└── COMPILACAO.md            # Guia de compilação detalhado
```

## 🎯 Funcionalidades Implementadas

### ✅ Funcionalidades Básicas (MVP)
- Reprodução de áudio e vídeo
- Varredura automática de ficheiros
- Controles completos (play/pause/stop/next/previous/seek/volume)
- Extração de metadados ID3 e capas
- Biblioteca organizada com filtros e ordenação
- Execução em segundo plano com notificações
- Alternância entre modo vídeo e áudio

### ✅ Funcionalidades Avançadas
- Sistema de favoritos
- Criação e gestão de playlists
- Mini player flutuante persistente
- Controles por gestos (swipe)
- Tema claro/escuro
- Permissões Android 13+ (granulares)
- Interface moderna e responsiva

## 🚀 Como Usar Este Projeto

### Opção 1: Baixar via Git

```bash
git clone <URL_DO_SEU_REPLIT>
cd media_player_app
```

### Opção 2: Download Manual

1. Baixe todos os arquivos do Replit
2. Mantenha a estrutura de pastas intacta

### Compilar o Projeto

Siga as instruções detalhadas em **COMPILACAO.md** ou **README.md**.

Resumo rápido:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

## 📚 Documentação

- **README.md**: Documentação geral e overview do projeto
- **COMPILACAO.md**: Guia passo a passo detalhado de compilação
- Comentários no código para facilitar compreensão

## 🔧 Tecnologias e Dependências

### Principais Bibliotecas
- `just_audio` + `just_audio_background`: Audio player com suporte a background
- `video_player`: Video player nativo
- `metadata_god`: Extração de metadados ID3
- `hive`: Banco de dados local
- `provider`: Gerenciamento de estado
- `permission_handler`: Gestão de permissões

Ver `pubspec.yaml` para lista completa.

## ⚙️ Configurações Android

### Permissões Configuradas
- READ_MEDIA_AUDIO (Android 13+)
- READ_MEDIA_VIDEO (Android 13+)
- READ_EXTERNAL_STORAGE (Android 12-)
- FOREGROUND_SERVICE
- FOREGROUND_SERVICE_MEDIA_PLAYBACK
- WAKE_LOCK

### Requisitos Mínimos
- Android 5.0 (API 21)
- Target SDK: 34 (Android 14)
- Compile SDK: 34

## 📝 Notas de Desenvolvimento

### Arquivos Gerados
Os arquivos `.g.dart` (Hive adapters) serão gerados automaticamente ao executar:
```bash
flutter pub run build_runner build
```

### Estado do Projeto
- ✅ Estrutura completa implementada
- ✅ Todas as funcionalidades codificadas
- ✅ Configurações Android prontas
- ✅ Documentação completa
- ⏳ Aguardando compilação no ambiente do usuário

## 🎨 Interface

O app possui:
- Design Material 3
- Suporte a tema claro e escuro
- Animações fluidas
- Interface responsiva
- Controles intuitivos

## 🔄 Próximos Passos

1. Baixar o projeto do Replit
2. Instalar Flutter SDK no seu computador
3. Executar `flutter pub get`
4. Gerar arquivos Hive
5. Compilar o APK
6. Testar em dispositivo Android

## ❓ Suporte

Para problemas de compilação, consulte:
- COMPILACAO.md (este repositório)
- Documentação oficial do Flutter: https://flutter.dev
- Flutter Doctor: `flutter doctor -v`

## 📄 Licença

Projeto educacional e de demonstração.

---

**Desenvolvido com Flutter** 🎯
**Ready to compile** ✅
