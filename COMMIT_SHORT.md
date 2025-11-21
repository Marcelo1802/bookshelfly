feat: implementa cache do banner e confirmação de remoção de livros

- Adiciona sistema completo de cache para banner da home
- Banner carrega instantaneamente usando cache local (mesmo expirado)
- Atualização silenciosa em background após exibir cache
- Cache persiste por 2 horas e funciona offline
- Diálogo de confirmação antes de remover livros em "Lendo" e "Favoritos"
- Previne remoções acidentais com feedback visual claro

Arquivos principais:
- BannerRepository e BannerRepositoryImpl para gerenciar cache
- BannerCacheDataSource com método para ignorar validade
- BooksViewModel com carregamento imediato de cache
- CasaPage com carregamento otimizado do banner
- GlassPage com diálogo de confirmação de remoção

