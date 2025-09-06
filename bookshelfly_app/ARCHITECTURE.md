# BookShelfly - Clean Architecture & MVVM

Este projeto implementa Clean Architecture com padrão MVVM (Model-View-ViewModel) no Flutter.

## 🏗️ Estrutura da Arquitetura

### 📁 Organização de Pastas

```
lib/
├── core/                    # Funcionalidades centrais
│   ├── constants/          # Constantes da aplicação
│   │   ├── app_strings.dart
│   │   └── app_colors.dart
│   ├── errors/             # Tratamento de erros
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   └── di/                 # Injeção de dependência
│       └── injection_container.dart
├── data/                   # Camada de Dados
│   ├── datasources/        # Fontes de dados
│   │   └── book_local_datasource.dart
│   ├── models/             # Modelos de dados
│   │   └── book_model.dart
│   └── repositories/       # Implementação dos repositórios
│       └── book_repository_impl.dart
├── domain/                 # Camada de Domínio
│   ├── entities/           # Entidades de negócio
│   │   └── book.dart
│   ├── repositories/       # Contratos dos repositórios
│   │   └── book_repository.dart
│   └── usecases/           # Casos de uso
│       ├── get_all_books.dart
│       └── add_book.dart
└── presentation/           # Camada de Apresentação
    ├── pages/              # Páginas/Views
    │   └── home_page.dart
    ├── viewmodels/         # ViewModels
    │   └── book_viewmodel.dart
    └── widgets/            # Widgets reutilizáveis
        ├── book_card.dart
        ├── loading_widget.dart
        └── error_widget.dart
```

## 🔄 Fluxo de Dados

### Clean Architecture Layers:

1. **Presentation Layer (MVVM)**
   - **View**: `HomePage` - Interface do usuário
   - **ViewModel**: `BookViewModel` - Lógica de apresentação e estado
   - **Model**: `Book` (Entity) - Dados do domínio

2. **Domain Layer**
   - **Entities**: `Book` - Regras de negócio puras
   - **Use Cases**: `GetAllBooks`, `AddBook` - Lógica de aplicação
   - **Repository Contracts**: `BookRepository` - Interfaces

3. **Data Layer**
   - **Repository Implementation**: `BookRepositoryImpl` - Implementação dos contratos
   - **Data Sources**: `BookLocalDataSource` - Acesso aos dados
   - **Models**: `BookModel` - Modelos de dados com serialização

## 🛠️ Tecnologias Utilizadas

- **State Management**: Provider
- **Dependency Injection**: Get It
- **Functional Programming**: Dartz (Either<Failure, Success>)
- **Equality**: Equatable
- **Local Storage**: Shared Preferences

## 📱 Funcionalidades Implementadas

- ✅ Listagem de livros
- ✅ Adição de novos livros
- ✅ Armazenamento local
- ✅ Tratamento de erros
- ✅ Estados de loading
- ✅ Interface responsiva

## 🚀 Como Executar

```bash
# Instalar dependências
flutter pub get

# Executar no iOS
flutter run

# Executar no Android
flutter run
```

## 🧪 Testes

```bash
# Executar testes
flutter test

# Análise de código
flutter analyze
```

## 📋 Próximas Funcionalidades

- [ ] Edição de livros
- [ ] Exclusão de livros
- [ ] Busca de livros
- [ ] Filtros por gênero/ano
- [ ] Avaliação de livros
- [ ] Sincronização com API
- [ ] Modo offline
- [ ] Temas (claro/escuro)

## 🎯 Benefícios da Arquitetura

1. **Separação de Responsabilidades**: Cada camada tem uma responsabilidade específica
2. **Testabilidade**: Fácil de testar cada camada isoladamente
3. **Manutenibilidade**: Código organizado e fácil de manter
4. **Escalabilidade**: Fácil adicionar novas funcionalidades
5. **Independência**: Camadas não dependem de implementações específicas
6. **Reutilização**: Componentes podem ser reutilizados em diferentes contextos
