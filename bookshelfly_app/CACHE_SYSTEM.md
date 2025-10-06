# Sistema de Cache - BookShelfly

## Visão Geral

O sistema de cache implementado no BookShelfly tem como objetivo reduzir o número de requisições à API Gutendex, melhorando a performance da aplicação e proporcionando uma experiência mais fluida para o usuário.

## Como Funciona

### 1. Cache Inteligente
- **Cache Local**: Os dados são armazenados localmente usando `SharedPreferences`
- **Validação de Tempo**: O cache expira automaticamente após 1 hora (configurável)
- **Fallback**: Em caso de falha de rede, o sistema tenta usar dados em cache mesmo que expirados

### 2. Tipos de Cache

#### Cache de Lista de Livros
- Armazena resultados de `getBooks()` por página e tamanho
- Chave: `books_cache_{page}_{pageSize}`
- Timestamp: `books_cache_{page}_{pageSize}_timestamp`

#### Cache de Busca
- Armazena resultados de `searchBooks()` por query, página e tamanho
- Chave: `search_cache_{query}_{page}_{pageSize}`
- Timestamp: `search_cache_{query}_{page}_{pageSize}_timestamp`

#### Cache de Livro Individual
- Armazena detalhes de livros específicos por ID
- Chave: `book_cache_{id}`
- Timestamp: `book_cache_{id}_timestamp`

### 3. Fluxo de Funcionamento

```
1. Usuário solicita dados
2. Sistema verifica cache local
3. Se cache válido → retorna dados do cache
4. Se cache inválido/inexistente → faz requisição à API
5. Salva resposta no cache
6. Retorna dados para o usuário
```

### 4. Tratamento de Erros

- **Erro de Rede**: Tenta usar cache mesmo que expirado
- **Erro de Servidor**: Retorna erro sem tentar cache
- **Erro de Cache**: Continua com requisição à API

## Benefícios

### Performance
- ⚡ **Carregamento Instantâneo**: Dados em cache são retornados imediatamente
- 🔄 **Menos Requisições**: Reduz carga na API e economiza dados móveis
- 📱 **Experiência Offline**: Funciona parcialmente sem conexão

### Economia de Recursos
- 💾 **Menos Uso de Dados**: Evita downloads desnecessários
- 🔋 **Economia de Bateria**: Menos processamento de rede
- ⏱️ **Tempo de Resposta**: Interface mais responsiva

## Configuração

### Tempo de Expiração
Por padrão, o cache expira em 1 hora. Para alterar:

```dart
// No GutendexLocalDataSourceImpl
Future<bool> isCacheValid(String key, {Duration maxAge = const Duration(hours: 1)}) async {
  // maxAge pode ser alterado para Duration(minutes: 30) ou Duration(hours: 2)
}
```

### Limpeza de Cache
Para limpar todo o cache:

```dart
final clearCache = sl<ClearCache>();
await clearCache();
```

## Arquivos Envolvidos

- `lib/data/datasources/gutendex_local_datasource.dart` - Implementação do cache
- `lib/data/repositories/book_repository_impl.dart` - Lógica de cache no repository
- `lib/domain/usecases/clear_cache.dart` - Use case para limpar cache
- `lib/core/di/injection_container.dart` - Injeção de dependências

## Monitoramento

O sistema de cache é transparente para o usuário. Os dados são automaticamente:
- ✅ Salvos após cada requisição bem-sucedida
- 🔄 Validados antes de cada uso
- 🗑️ Limpos quando expirados
- 📊 Gerenciados de forma eficiente

## Considerações Técnicas

- **Armazenamento**: SharedPreferences (persistente entre sessões)
- **Serialização**: JSON para objetos complexos
- **Thread Safety**: Operações assíncronas seguras
- **Memory Management**: Cache limitado por tempo, não por tamanho
