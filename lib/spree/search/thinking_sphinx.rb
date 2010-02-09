module Spree::Search
  class ThinkingSphinx < Spree::Search::Base
    # method should return hash with conditions {:conditions=> "..."} for Product model
    def get_products_conditions_for(query)
      search_options = {:page => page, :per_page => per_page}
      if order_by_price
        search_options.merge!(:order => :price,
                              :sort_mode => (order_by_price == 'descend' ? :desc : :asc))
      end
      if facets_hash
        search_options.merge!(:conditions => facets_hash)
      end
      facets = Product.facets(query, search_options)
      products = facets.for(facets_hash)
      
      @properties[:products] = products
      @properties[:facets] = facets
      {:conditions=> ["products.id IN (?)", products.map(&:id)]}
    end

    def prepare(params)
      @properties[:facets_hash] = params[:facets] || {}
      @properties[:taxon] = params[:taxon].blank? ? nil : Taxon.find(params[:taxon])
      @properties[:per_page] = params[:per_page]
      @properties[:page] = params[:page]
      @properties[:manage_pagination] = true
      @properties[:order_by_price] = params[:order_by_price]
    end
  end
end
