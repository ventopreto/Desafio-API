# Desafio API

## Sobre
Criar uma API de serviço do catálogo de filmes. Para isso será necessário criar dois endpoints, um que faça a leitura de um arquivo CSV e crie os registros no banco de dados. E um segundo que liste todos os filmes cadastrados em formato JSON.

### Conteudo
=================
 
   * [Sobre o projeto](#sobre)
   * [Tabela de Conteúdo](#conteudo)
   * [Requisitos](#requisitos)
   * [Dicas](#dicas)
   * [Como usar](#como-usar)
   * [Testes](#testes)
   * [Api](#api)
 


### Requisitos

* O desafio deve ser desenvolvido utilizando Ruby e tendo o Rails como framework.
* Poderá optar pelos bancos de dados SQLite, Postgresql ou MongoDB.
* Seguir o padrão API RESTful.
* Ordenar pelo ano de lançamento.
* Filtrar os registros por ano de lançamento, gênero, país, etc.
* Garantir que não haja duplicidade de registros.
* O projeto deve ser disponibilizado em um repositório aberto no GitHub.
* A response do endpoint de listagem deve obedecer estritamente o padrão abaixo:

```JSON

[
    {
        "id": "840c7cfc-cd1f-4094-9651-688457d97fa4",
        "title": "13 Reasons Why",
        "genre": "TV Show",
        "year": "2020",
        "country": "United States",
        "published_at": "2020-05-07",
        "description": "A classmate receives a series of tapes that unravel the mystery of her tragic choice."
    }
]
```

### Dicas
* Testes são bem-vindos.
* O filtro pode ser aplicado por 1 ou mais itens, mas devem atender aos requisitos.
* Criar um readme.md com algumas informações do projeto é sempre bem útil.
* O arquivo .csv, intitulado netflix_titles.csv, poderá ser encontrado neste repositório.



## como-usar

### Buildando a imagem
```docker compose build```

### Subindo o projeto
```docker compose up -d```

### Entrando em um container que esteja rodando
```docker compose exec web bash```

Com o servidor rodando visite [http://localhost:3001](http://localhost:3001/api-docs/index.html)/
Nessa pagina temos uma documentação das rotas da API via swagger

## Testes
Para rodar todos os testes utilize o comando 
~~~ruby
rspec
~~~


## API

## Criando os filmes

```http
  POST /api/v1/movies
```
O nosso endpoint acima espera receber uma requisição com arquivo csv no seguinte formato
```csv
show_id,type,title,director,cast,country,date_added,release_year,rating,duration,listed_in,description
s64,TV Show,13 Reasons Why,,"Dylan Minnette, Katherine Langford, Kate Walsh, Derek Luke, Brian d'Arcy James, Alisha Boe, Christian Navarro, Miles Heizer, Ross Butler, Devin Druid, Michele Selene Ang, Steven Silver, Amy Hargreaves",United States,"June 5, 2020",2020,TV-MA,4 Seasons,"Crime TV Shows, TV Dramas, TV Mysteries","After a teenage girl's perplexing suicide, a classmate receives a series of tapes that unravel the mystery of her tragic choice."
```
Se os parâmetros estão corretos e válidos, os filmes são criandos
e a requisição retorna o status 201.
 
### Erros Comuns
 
#### Ausencia de parâmetro
 
```http
  POST /api/v1/movies
```
A mesma requisição do exemplo anterior, mas o arquivo não contem o titulo do filme
```csv
show_id,type,title,director,cast,country,date_added,release_year,rating,duration,listed_in,description
s64,TV Show,,,"Dylan Minnette, Katherine Langford, Kate Walsh, Derek Luke, Brian d'Arcy James, Alisha Boe, Christian Navarro, Miles Heizer, Ross Butler, Devin Druid, Michele Selene Ang, Steven Silver, Amy Hargreaves",United States,"June 5, 2020",2020,TV-MA,4 Seasons,"Crime TV Shows, TV Dramas, TV Mysteries","After a teenage girl's perplexing suicide, a classmate receives a series of tapes that unravel the mystery of her tragic choice."
```
Nesse caso como um dos parâmetros estão faltando,
a requisição retorna com status 422 e uma mensagem informando
que title não pode ficar em branco.
 
```json
{
  "error": "A validação falhou: Title não pode ficar em branco"
}
```
 
## Consultando os filmes
```http
GET /api/v1/movies
```

A requisição é feita com sucesso e retorna uma lista de filmes em json e status 200
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
  },
  {
    "id": "ffe76768-f08a-4ceb-934a-c7f5b9010cd2",
    "title": "300 Miles to Heaven",
    "genre": "Movie",
    "year": 1989,
    "country": "Denmark, France, Poland",
    "published_at": "2019-10-01",
    "description": "Hoping to help their dissident parents, two brothers sneak out of Poland and land as refugees in Denmark, where they are prevented from returning home."
  }
]
```

## Consultando os filmes usando filtros
```http
GET /api/v1/movies?query[year_eq]=2020&query[country_eq]=Poland
```
A requisição é feita com sucesso e retorna uma lista de filmes respeitando os filtros e status 200

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

## Consulta com filtro inválido
```http
GET /api/v1/movies?query[yer_eq]=2020
```

A requisição falha e retorna um json com o erro e mensagem "Parâmetro de busca inválido" e status 400

```json
{
  "error": "Parâmetro de busca inválido"
}
```