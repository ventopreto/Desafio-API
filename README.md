# Desafio API

API REST de catálogo de filmes. Importa filmes a partir de um arquivo CSV de forma assíncrona e expõe um endpoint de listagem com filtros e ordenação.

## Sumário

- [Sobre](#sobre)
- [Stack](#stack)
- [Como usar](#como-usar)
- [Testes](#testes)
- [API](#api)
  - [POST /api/v1/movies](#post-apiv1movies)
  - [GET /api/v1/movie_imports/:id](#get-apiv1movie_importsid)
  - [GET /api/v1/movies](#get-apiv1movies)
  - [Filtros](#filtros)

## Sobre

O desafio original pedia dois endpoints - um para importar um CSV e outro para listar os filmes. Esta implementação adiciona:

- Importação **assíncrona** via SolidQueue. O `POST` retorna `202 Accepted` imediatamente com um `import_id` que pode ser consultado depois.
- Endpoint de **status** (`GET /api/v1/movie_imports/:id`) para o cliente acompanhar a importação.
- Stream do CSV com `CSV.foreach(headers: true)` em vez de carregar o arquivo inteiro em memória.
- Importação envelopada em transaction - linha inválida no meio do arquivo dispara rollback completo.
- Índices em `title` (unique), `year`, `genre`, `country` e `published_at` para os filtros Ransack.
- Documentação OpenAPI gerada via rswag em `/api-docs`.

## Stack

- Ruby 3.3.5
- Rails 8.0
- PostgreSQL 16
- SolidQueue (job backend, mesma DB da aplicação)
- RSpec + rswag (testes + swagger)
- Docker Compose (web + worker + db)

## Como usar

Copiar `.env.example` para `.env` e ajustar o `POSTGRES_PASSWORD`:

```ruby
cp .env.example .env
```

Buildar a imagem:

```ruby
docker compose build
```

Subir tudo (web + worker SolidQueue + Postgres):

```ruby
docker compose up -d
```

Criar e migrar o banco na primeira execução:

```ruby
docker compose exec web bundle exec rails db:prepare
```

Documentação interativa via Swagger UI:

```
http://localhost:3001/api-docs
```

Entrar no container web:

```ruby
docker compose exec web bash
```

## Testes

```ruby
docker compose exec web bundle exec rspec
```

Cobertura via SimpleCov é gerada em `coverage/`.

## API

### POST /api/v1/movies

Recebe `multipart/form-data` com o arquivo CSV no campo `file`. O conteúdo é persistido em `tmp/imports/`, um `MovieImport` é criado com status `processing` e o `ImportMoviesJob` é enfileirado.

**Request**

```http
POST /api/v1/movies
Content-Type: multipart/form-data

file=@netflix_titles.csv
```

**Response - 202 Accepted**

```json
{
  "message": "Importação aceita. Use o import_id para verificar o status.",
  "import_id": 42
}
```

**Response - 400 Bad Request** (arquivo ausente)

```json
{
  "error": "Arquivo não enviado. Por favor, anexe um arquivo CSV."
}
```

Formato esperado do CSV:

```csv
show_id,type,title,director,cast,country,date_added,release_year,rating,duration,listed_in,description
s64,TV Show,13 Reasons Why,,"Dylan Minnette, ...",United States,"June 5, 2020",2020,TV-MA,4 Seasons,"Crime TV Shows, TV Dramas","After a teenage girl's ..."
```

### GET /api/v1/movie_imports/:id

Retorna o estado de uma importação. O status evolui por `processing → completed | failed | invalid_file`.

**Response - 200 OK**

```json
{
  "id": 42,
  "file_name": "netflix_titles.csv",
  "error_message": null,
  "status": "completed",
  "movies_count": 131
}
```

**Response - 404 Not Found**

```json
{
  "error": "Importação não encontrada."
}
```

Possíveis estados de `status`:

| status | significado |
|--------|-------------|
| `processing` | job ainda na fila ou em execução |
| `completed` | todos os registros foram inseridos |
| `failed` | algum registro violou validação - rollback aplicado, `error_message` preenchido |
| `invalid_file` | content-type não era `text/csv` ou o arquivo estava vazio |

### GET /api/v1/movies

Lista todos os filmes ordenados por `year asc` por padrão.

**Response - 200 OK**

```json
[
  {
    "id": "b8ef4939-00b0-4f0f-b381-e2c4031d18cf",
    "title": "A Clockwork Orange",
    "genre": "Movie",
    "year": 1971,
    "country": "United Kingdom, United States",
    "published_at": "2020-11-01",
    "description": "In this dark satire from director Stanley Kubrick, a young, vicious sociopath in a dystopian England undergoes an experimental rehabilitation therapy."
  }
]
```

Quando nenhum filme é encontrado:

```json
{ "message": "Nenhum filme encontrado" }
```

### Filtros

Os filtros usam Ransack. Atributos permitidos: `title`, `genre`, `year`, `country`, `published_at`, `description`. Predicados Ransack (`_eq`, `_cont`, `_gteq`, …) são suportados.

**Exemplo - filtro composto**

```http
GET /api/v1/movies?query[year_eq]=2020&query[country_eq]=Poland
```

```json
[
  {
    "id": "fe4292c8-9803-4561-bcb9-ab68796bf1a8",
    "title": "365 Days",
    "genre": "Movie",
    "year": 2020,
    "country": "Poland",
    "published_at": "2020-06-07",
    "description": "A fiery executive in a spiritless relationship falls victim to a dominant mafia boss, who imprisons her and gives her one year to fall in love with him."
  }
]
```

**Ordenação customizada**

```http
GET /api/v1/movies?query[s]=title+asc
```

**Filtro inválido - 400 Bad Request**

```http
GET /api/v1/movies?query[yer_eq]=2020
```

```json
{ "error": "Parâmetro de busca inválido" }
```
