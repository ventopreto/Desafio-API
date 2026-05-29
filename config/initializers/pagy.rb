require "pagy/extras/headers"
require "pagy/extras/overflow"
require "pagy/extras/limit"

Pagy::DEFAULT[:limit] = 25
Pagy::DEFAULT[:limit_max] = 100
Pagy::DEFAULT[:limit_param] = :limit
Pagy::DEFAULT[:limit_extra] = true
Pagy::DEFAULT[:overflow] = :empty_page
Pagy::DEFAULT[:headers] = {
  page: "Current-Page",
  pages: "Total-Pages",
  count: "Total-Count",
  limit: "Page-Limit"
}
