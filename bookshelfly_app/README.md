# 📚 BookShelfly

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**Aplicativo Mobile de Leitura e Gerenciamento de Livros**

Acesse milhares de livros gratuitos do Projeto Gutenberg em um aplicativo moderno e intuitivo.

[Funcionalidades](#-funcionalidades) • [Tecnologias](#-tecnologias) • [Instalação](#-instalação) • [Arquitetura](#-arquitetura)

</div>

---

## 📖 Sobre o Projeto

O **BookShelfly** é um aplicativo mobile desenvolvido em Flutter que permite aos usuários explorar, ler e gerenciar uma biblioteca pessoal de livros. O aplicativo utiliza a API pública [Gutendex](https://gutendex.com/), que fornece acesso a mais de 70.000 livros de domínio público do [Projeto Gutenberg](https://www.gutenberg.org/).

Este projeto foi desenvolvido como uma ferramenta de aprendizado, demonstrando a aplicação prática de **Clean Architecture**, padrão **MVVM** e boas práticas de desenvolvimento mobile.

### 🎯 Objetivos

- ✅ Demonstrar Clean Architecture em Flutter
- ✅ Aplicar padrões de design modernos (MVVM, Repository, Dependency Injection)
- ✅ Facilitar o acesso gratuito à literatura
- ✅ Promover a cultura e educação através da tecnologia

---

## ✨ Funcionalidades

### 🏠 Página Inicial
- **Banner em Destaque**: Livros em destaque com rotação automática
- **Categoria Brasileiros**: Seção dedicada a livros de autores brasileiros
- **Categoria Popular**: Livros mais populares da biblioteca
- **Cache Inteligente**: Carregamento instantâneo de conteúdo em cache

### 📚 Biblioteca de Livros
- **Listagem Completa**: Visualização em grid ou lista
- **Busca Avançada**: Pesquisa por título, autor ou assunto
- **Detalhes do Livro**: Informações completas sobre cada obra
- **Ações Rápidas**: Botões "Ler Livro" e "Favoritar" com feedback visual

### 📖 Leitor de Livros
- **Visualização Completa**: Leitura do livro completo
- **Navegação Rápida**: Busca por página específica
- **Configurações**: Personalização da experiência de leitura
- **Progresso Automático**: Salvamento automático do progresso

### 👓 Biblioteca Pessoal (Glass)
- **Lista "Lendo"**: Livros que você está lendo atualmente
- **Lista "Favoritos"**: Seus livros favoritos
- **Gerenciamento**: Adicione ou remova livros facilmente
- **Busca Personalizada**: Filtre dentro da sua biblioteca

### 📝 Notas
- **Sistema de Anotações**: Crie e gerencie notas pessoais
- **Organização Visual**: Grid com cores variadas
- **Persistência**: Armazenamento local seguro

### ⚡ Sistema de Cache
- **Cache de API**: Reduz chamadas desnecessárias
- **Cache de Banner**: Carregamento instantâneo
- **Modo Offline**: Funcionalidade mesmo sem internet
- **Invalidação Inteligente**: Atualização automática quando necessário

---

## 🛠️ Tecnologias

### Framework e Linguagem
- **Flutter** 3.8.1
- **Dart** 3.8.1

### Gerenciamento de Estado
- **Provider** 6.1.2 - Gerenciamento reativo de estado

### Injeção de Dependência
- **GetIt** 7.7.0 - Gerenciamento de dependências

### Programação Funcional
- **Dartz** 0.10.1 - Tratamento de erros funcional (`Either<Failure, Success>`)

### Armazenamento
- **SharedPreferences** 2.3.2 - Persistência local de dados

### Comunicação
- **HTTP** 1.1.0 - Cliente HTTP para API

### Otimizações
- **Cached Network Image** 3.3.1 - Cache de imagens
- **Equatable** 2.0.5 - Comparação de objetos
- **Path Provider** 2.1.2 - Gerenciamento de caminhos

---

## 🚀 Instalação

### Pré-requisitos

- Flutter SDK 3.8.1 ou superior
- Dart SDK
- Android Studio / Xcode (para desenvolvimento mobile)
- Git

### Passos para Instalação

1. **Clone o repositório**
   ```bash
   git clone [url-do-repositorio]
   cd bookshelfly_app
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**
   ```bash
   # iOS
   flutter run -d ios
   
   # Android
   flutter run -d android
   
   # Ou selecione um dispositivo disponível
   flutter run
   ```

### Verificar Instalação

```bash
# Verificar versão do Flutter
flutter --version

# Verificar dispositivos disponíveis
flutter devices

# Executar análise de código
flutter analyze

# Executar testes
flutter test
```

---

## 🏗️ Arquitetura

O projeto segue os princípios da **Clean Architecture** com padrão **MVVM**:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (MVVM)           │
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │   View   │  │ ViewModel│  │ Model │ │
│  └──────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│         DOMAIN LAYER                    │
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ Entities│  │ Use Cases │  │Repos.  │ │
│  └──────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│          DATA LAYER                     │
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │   Repos  │  │Data Source│  │ Models │ │
│  └──────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────┘
```

### Estrutura de Pastas

```
lib/
├── core/                    # Funcionalidades centrais
│   ├── constants/           # Constantes (cores, strings)
│   ├── errors/             # Tratamento de erros
│   ├── di/                 # Injeção de dependência
│   └── utils/              # Utilitários
├── data/                   # Camada de Dados
│   ├── datasources/        # Fontes de dados (Remote/Local)
│   ├── models/             # Modelos de dados
│   └── repositories/       # Implementação de repositórios
├── domain/                 # Camada de Domínio
│   ├── entities/           # Entidades de negócio
│   ├── repositories/       # Contratos de repositórios
│   └── usecases/           # Casos de uso
└── presentation/           # Camada de Apresentação
    ├── pages/              # Páginas da aplicação
    ├── viewmodels/         # ViewModels
    └── widgets/            # Widgets reutilizáveis
```

### Princípios Aplicados

- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Clean Architecture**: Separação de responsabilidades em camadas independentes
- **MVVM**: Separação entre View, ViewModel e Model
- **Repository Pattern**: Abstração do acesso a dados
- **Dependency Injection**: Inversão de controle de dependências

---

## 📱 Screenshots

> _Screenshots serão adicionados em breve_

---

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage

# Executar análise estática
flutter analyze
```

---

## 📦 Build

### Android

```bash
# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

### iOS

```bash
# Build iOS
flutter build ios
```

---

## 🤝 Contribuindo

Este é um projeto educacional. Contribuições são bem-vindas! Para contribuir:

1. Faça um Fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## 👨‍💻 Autor

**Desenvolvedor**

- Projeto desenvolvido para fins educacionais
- Demonstração de Clean Architecture e MVVM em Flutter

---

## 🙏 Agradecimentos

- [Projeto Gutenberg](https://www.gutenberg.org/) - Por disponibilizar milhares de livros gratuitos
- [Gutendex API](https://gutendex.com/) - Por fornecer uma API excelente para acessar os livros
- Comunidade Flutter - Por toda a documentação e suporte

---

## 📚 Recursos Adicionais

- [Documentação Flutter](https://docs.flutter.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
- [Projeto Gutenberg](https://www.gutenberg.org/)

---

## ⚠️ Nota Importante

Este é um **projeto educacional** desenvolvido para demonstrar práticas de desenvolvimento mobile, arquitetura de software e padrões de design. O objetivo principal é o aprendizado e a demonstração de conceitos técnicos.

---

<div align="center">

**Feito com ❤️ usando Flutter**

⭐ Se este projeto foi útil para você, considere dar uma estrela!

</div>