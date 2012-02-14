Deface::Override.new(
  :virtual_path => "products/index",
  :insert_before => "[data-hook='search_results'], #search_results[data-hook]",
  :partial => "products/facets",
  :name => 'sphinx_search_insert_facets'
)

Deface::Override.new(
  :virtual_path => "spree/products/index",
  :insert_top => "[data-hook='search_results'], #search_results[data-hook]",
  :partial => "products/suggestion",
  :name => 'sphinx_search_insert_suggestion'
)
