require "rails_helper"

RSpec.describe "GET /api/v1/movies pagination", type: :request do
  before do
    30.times do |i|
      Movie.create!(
        title: "Movie #{i}",
        genre: "Movie",
        year: 2000 + i,
        country: "USA",
        published_at: "2020-01-01",
        description: "Description #{i}"
      )
    end
  end

  it "returns the first page with the default limit and pagination headers" do
    get "/api/v1/movies"

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).size).to eq(25)
    expect(response.headers["Current-Page"]).to eq("1")
    expect(response.headers["Total-Pages"]).to eq("2")
    expect(response.headers["Total-Count"]).to eq("30")
    expect(response.headers["Page-Limit"]).to eq("25")
    expect(response.headers["Link"]).to include('rel="next"', 'rel="last"')
  end

  it "returns the requested page" do
    get "/api/v1/movies", params: {page: 2}

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).size).to eq(5)
    expect(response.headers["Current-Page"]).to eq("2")
    expect(response.headers["Link"]).to include('rel="prev"', 'rel="first"')
  end

  it "honors the limit query parameter" do
    get "/api/v1/movies", params: {limit: 10}

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).size).to eq(10)
    expect(response.headers["Total-Pages"]).to eq("3")
    expect(response.headers["Page-Limit"]).to eq("10")
  end

  it "caps the limit at the configured max" do
    get "/api/v1/movies", params: {limit: 9999}

    expect(response).to have_http_status(:ok)
    expect(response.headers["Page-Limit"]).to eq("100")
  end

  it "returns the not-found message when a page beyond the last is requested" do
    get "/api/v1/movies", params: {page: 99}

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("message" => "Nenhum filme encontrado")
  end
end
