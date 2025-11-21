feat: implementa cache do banner e confirmação de remoção de livros

## Cache do Banner

### Arquitetura
- Criada interface `BannerRepository` no domain layer
- Implementado `BannerRepositoryImpl` com suporte a cache
- Adicionado `BannerCacheDataSource` para gerenciar cache local
- Integrado cache com `GetFeaturedBooks` use case

### Funcionalidades
- Cache persiste dados do banner por 2 horas
- Carregamento imediato do cache ao abrir a tela (mesmo que expirado)
- Atualização silenciosa em background após exibir cache
- Fallback para cache expirado em caso de erro de rede

### Métodos adicionados
- `BannerCacheDataSource.getCachedFeaturedBooksIgnoreValidity()`: retorna cache sem verificar validade
- `BannerRepository.getCachedFeaturedBooksImmediate()`: carrega cache imediatamente
- `BooksViewModel.loadCachedFeaturedBooksImmediate()`: método público para carregar cache

### Melhorias de UX
- Banner aparece instantaneamente ao entrar na tela
- Elimina delay visual ao navegar para a home
- Experiência mais fluida com dados pré-carregados

## Confirmação de Remoção

### Página Glass
- Adicionado diálogo de confirmação antes de remover livros
- Funciona tanto para lista "Lendo" quanto "Favoritos"
- Diálogo mostra título do livro e contexto da remoção
- Botões "Cancelar" (cinza) e "Remover" (vermelho)

### Segurança
- Previne remoções acidentais
- Feedback visual claro sobre ação destrutiva
- Snackbar de confirmação após remoção bem-sucedida

## Arquivos modificados

### Novos arquivos
- `lib/domain/repositories/banner_repository.dart`
- `lib/data/repositories/banner_repository_impl.dart` (atualizado para implementar interface)

### Arquivos atualizados
- `lib/data/datasources/banner_cache_datasource.dart`: adicionado método para ignorar validade
- `lib/domain/usecases/get_featured_books.dart`: atualizado para usar BannerRepository
- `lib/presentation/viewmodels/books_viewmodel.dart`: injetado BannerRepository e método de carregamento imediato
- `lib/presentation/pages/casa_page.dart`: carregamento imediato do cache no initState
- `lib/presentation/pages/glass_page.dart`: diálogo de confirmação antes de remover
- `lib/core/di/injection_container.dart`: registro do BannerRepository
- `lib/main.dart`: injeção do BannerRepository no BooksViewModel

## Impacto
- Melhora significativa na performance de carregamento da home
- Reduz chamadas desnecessárias à API
- Melhora experiência do usuário com feedback imediato
- Previne ações acidentais de remoção

