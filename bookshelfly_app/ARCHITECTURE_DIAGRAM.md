# 📊 Diagrama da Arquitetura BookShelfly

## 🏗️ Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                          │
│                         (MVVM)                                 │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐   │
│  │    VIEW     │    │  VIEWMODEL   │    │     MODEL       │   │
│  │             │    │              │    │                 │   │
│  │ HomePage    │◄──►│BookViewModel │◄──►│ Book (Entity)   │   │
│  │             │    │              │    │                 │   │
│  │ - UI        │    │ - State      │    │ - Business      │   │
│  │ - Events    │    │ - Logic      │    │   Rules         │   │
│  └─────────────┘    └──────────────┘    └─────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐   │
│  │  ENTITIES   │    │  USE CASES   │    │  REPOSITORIES   │   │
│  │             │    │              │    │   (Contracts)   │   │
│  │ Book        │    │GetAllBooks   │    │ BookRepository  │   │
│  │             │    │AddBook       │    │                 │   │
│  │ - Business  │    │ - App Logic  │    │ - Interfaces    │   │
│  │   Rules     │    │ - Orchestr.  │    │ - Contracts     │   │
│  └─────────────┘    └──────────────┘    └─────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐   │
│  │ REPOSITORY  │    │ DATA SOURCES │    │     MODELS      │   │
│  │IMPLMENTATION│    │              │    │                 │   │
│  │             │    │BookLocalData │    │ BookModel       │   │
│  │BookRepoImpl │◄──►│Source        │◄──►│                 │   │
│  │             │    │              │    │ - JSON          │   │
│  │ - Data      │    │ - Local      │    │ - Serialization │   │
│  │   Access    │    │   Storage    │    │ - Mapping       │   │
│  └─────────────┘    └──────────────┘    └─────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EXTERNAL LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐   │
│  │   DATABASE  │    │     API      │    │   FILE SYSTEM   │   │
│  │             │    │              │    │                 │   │
│  │ SharedPrefs │    │ REST API     │    │ Local Files     │   │
│  │ SQLite      │    │ GraphQL      │    │ Cache           │   │
│  │             │    │              │    │                 │   │
│  └─────────────┘    └──────────────┘    └─────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Fluxo de Dados

### 1. **User Action** → View
```
Usuário clica em "Adicionar Livro"
```

### 2. **View** → ViewModel
```
HomePage → BookViewModel.addNewBook()
```

### 3. **ViewModel** → Use Case
```
BookViewModel → AddBook Use Case
```

### 4. **Use Case** → Repository
```
AddBook → BookRepository.addBook()
```

### 5. **Repository** → Data Source
```
BookRepositoryImpl → BookLocalDataSource.addBook()
```

### 6. **Data Source** → External
```
BookLocalDataSource → SharedPreferences
```

### 7. **Response Chain** (Volta)
```
SharedPreferences → DataSource → Repository → UseCase → ViewModel → View
```

## 🎯 Princípios Aplicados

### **Dependency Inversion**
- Camadas internas não dependem de camadas externas
- Dependências apontam para dentro (em direção ao domínio)

### **Single Responsibility**
- Cada classe tem uma única responsabilidade
- Separação clara entre UI, lógica de negócio e acesso a dados

### **Open/Closed Principle**
- Aberto para extensão, fechado para modificação
- Fácil adicionar novos data sources ou use cases

### **Interface Segregation**
- Interfaces específicas e coesas
- Clientes não dependem de métodos que não usam

## 🛠️ Tecnologias por Camada

| Camada | Tecnologia | Propósito |
|--------|------------|-----------|
| **Presentation** | Provider, Flutter | Gerenciamento de estado e UI |
| **Domain** | Dart puro | Regras de negócio |
| **Data** | SharedPreferences, JSON | Persistência e serialização |
| **DI** | Get It | Injeção de dependência |

## 📱 Benefícios da Implementação

✅ **Testabilidade**: Cada camada pode ser testada isoladamente  
✅ **Manutenibilidade**: Código organizado e fácil de manter  
✅ **Escalabilidade**: Fácil adicionar novas funcionalidades  
✅ **Flexibilidade**: Trocar implementações sem afetar outras camadas  
✅ **Reutilização**: Componentes podem ser reutilizados  
✅ **Separação de Responsabilidades**: Cada camada tem seu propósito específico
