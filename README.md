# GameHub - Sua Central de Jogos 🎮

> **Desenvolvido por José Eduardo Dias Rufino**  
> **Disciplina:** Desenvolvimento de Sistemas Mobile I  
> **Trabalho:** 2º Bimestre

Uma aplicação móvel desenvolvida com Flutter para descobrir e gerenciar jogos. O app utiliza a [RAWG API](https://rawg.io/apidocs) para buscar informações detalhadas sobre jogos e oferece funcionalidades de autenticação com Firebase.

## 🎥 Demonstração em Vídeo

[**Assista à demonstração completa do aplicativo**](./video.mkv)

## 🚀 Como executar o projeto

### Pré-requisitos

- Flutter SDK instalado ([Guia oficial de instalação](https://docs.flutter.dev/get-started/install))
- Editor de código (VS Code, Android Studio ou IntelliJ)
- Git instalado
- Conta no Firebase (para autenticação)

### Passos para instalação e execução

1. **Clone o repositório:**

```bash
git clone https://github.com/josedudidas/D.S.-MOBILE-I-Trabalho-02.git
cd D.S.-MOBILE-I-Trabalho-02-main
```

2. **Instale as dependências:**

```bash
flutter pub get
```

3. **Configure o Firebase:**

   - Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
   - Configure o Authentication (Email/Password)
   - Baixe o arquivo `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
   - Execute `flutterfire configure` para configurar automaticamente

4. **Execute o aplicativo:**

```bash
flutter run
```

### Para construir versões de produção

**Android APK:**

```bash
flutter build apk --release
```

**Android App Bundle:**

```bash
flutter build appbundle --release
```

**Web:**

```bash
flutter build web --release
```

**iOS:**

```bash
flutter build ios --release
```

## 🛠️ Tecnologias Utilizadas

### Framework e Linguagem

- **Flutter 3.7.2** - Framework multiplataforma
- **Dart 3.7.2** - Linguagem de programação

### APIs e Serviços

- **RAWG API** - Base de dados de jogos
- **Firebase Authentication** - Autenticação de usuários
- **Firebase Core** - Serviços base do Firebase

### Gerenciamento de Estado

- **Provider 6.1.4** - Gerenciamento de estado reativo

### Networking e Cache

- **HTTP 1.3.0** - Requisições de rede
- **Cached Network Image 3.4.0** - Cache inteligente de imagens

### Banco de Dados Local

- **SQLite 2.4.2** - Armazenamento local
- **Shared Preferences 2.2.2** - Configurações do usuário

### Recursos Adicionais

- **URL Launcher 6.3.0** - Abertura de links externos
- **Flutter SVG 2.0.17** - Suporte a imagens SVG
- **Logger 2.5.0** - Sistema de logs
- **Flutter Native Splash 2.4.6** - Tela de splash nativa

## ✨ Principais Funcionalidades

### 🔐 Sistema de Autenticação

- **Login e Registro** - Sistema completo de autenticação com Firebase
- **Validação de campos** - Validação em tempo real de email e senha
- **Gerenciamento de sessão** - Manutenção automática do estado de login

### 🎮 Descoberta de Jogos

- **Catálogo abrangente** - Acesso a milhares de jogos via RAWG API
- **Busca inteligente** - Pesquisa por nome com sugestões em tempo real
- **Filtros avançados** - Filtrar por gênero, plataforma, e data de lançamento
- **Rolagem infinita** - Carregamento paginado para melhor performance

### 📱 Detalhes Completos dos Jogos

- **Informações detalhadas** - Nome, descrição, data de lançamento, classificação
- **Galeria de imagens** - Screenshots e imagens promocionais dos jogos
- **Plataformas suportadas** - Lista completa de plataformas disponíveis
- **Gêneros e tags** - Categorização completa dos jogos
- **Pontuação Metacritic** - Avaliações da crítica especializada
- **Links externos** - Acesso direto ao site oficial dos jogos

### 💾 Gerenciamento Local

- **Cache inteligente** - Armazenamento local para acesso offline
- **Favoritos** - Sistema de jogos favoritos (implementado com SQLite)
- **Histórico de busca** - Manutenção do histórico de pesquisas
- **Configurações** - Preferências do usuário persistentes

### 🎨 Interface e Experiência

- **Design moderno** - Interface seguindo Material Design 3
- **Tema adaptável** - Suporte a tema claro e escuro
- **Animações fluidas** - Transições e animações personalizadas
- **Responsividade** - Adaptação para diferentes tamanhos de tela
- **Performance otimizada** - Carregamento rápido e uso eficiente de recursos

## 🏗️ Arquitetura do Projeto

O projeto segue uma arquitetura limpa e organizada:

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── firebase_options.dart     # Configurações do Firebase
├── models/                   # Modelos de dados
│   └── game.dart
├── services/                 # Serviços e APIs
│   ├── auth_service.dart
│   └── game_api_service.dart
├── repositories/             # Camada de dados
│   ├── game_repository.dart
│   └── game_repository_impl.dart
├── viewmodels/              # Lógica de negócio
│   ├── home_view_model.dart
│   └── home_view_model_new.dart
├── views/                   # Interfaces de usuário
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── favorites_screen.dart
│   ├── game_details.dart
│   └── game_hub_home.dart
├── custom/                  # Widgets personalizados
│   ├── expansion_tile.dart
│   ├── paginated_list_view.dart
│   ├── progress_indicator.dart
│   └── sparkling_widget.dart
└── utils/                   # Utilitários
    ├── logging.dart
    └── string.dart
```

## 🔧 Configuração do Projeto

### Variáveis de Ambiente

1. **API Key da RAWG:**

   - Obtenha sua chave em [RAWG API](https://rawg.io/apidocs)
   - Configure no arquivo `lib/services/game_api_service.dart`

2. **Firebase:**
   - Configure seguindo a [documentação oficial](https://firebase.google.com/docs/flutter/setup)
   - Habilite Authentication com Email/Password

### Configuração do Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto
3. Adicione um app Android/iOS
4. Baixe os arquivos de configuração:
   - `google-services.json` para Android
   - `GoogleService-Info.plist` para iOS
5. Configure o Authentication:
   - Vá em Authentication > Sign-in method
   - Habilite "Email/Password"

## � Deploy

### Web

```bash
flutter build web --release
firebase deploy
```

### Android

```bash
flutter build appbundle --release
# Upload para Google Play Console
```

### iOS

```bash
flutter build ios --release
# Usar Xcode para enviar para App Store Connect
```

## 📋 Funcionalidades Implementadas

- [x] Sistema de autenticação completo
- [x] Listagem de jogos com paginação
- [x] Busca e filtros
- [x] Detalhes completos dos jogos
- [x] Cache local com SQLite
- [x] Interface responsiva
- [x] Suporte a temas claro/escuro
- [x] Tratamento de erros
- [x] Loading states
- [x] Validação de formulários

## 🔮 Próximas Funcionalidades

- [ ] Sistema de avaliações pessoais
- [ ] Lista de desejos
- [ ] Comparação entre jogos
- [ ] Notificações de lançamentos
- [ ] Integração com redes sociais
- [ ] Sistema de recomendações
- [ ] Modo offline completo

## 🤝 Contribuição

Este projeto foi desenvolvido como trabalho acadêmico. Sugestões e melhorias são bem-vindas!

## 📄 Licença

Este projeto é para fins educacionais e está sob a licença MIT.

## 👨‍💻 Autor

**José Eduardo Dias Rufino**

- GitHub: [@josedudidas](https://github.com/josedudidas)
- Email: [josedu.dias@gmail.com]

---

**Disciplina:** Desenvolvimento de Sistemas Mobile I
**Período:** 2º Bimestre de 2025
