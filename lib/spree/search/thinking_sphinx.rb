module Spree::Search
  class ThinkingSphinx < Spree::Search::Base
    protected
    # method should return AR::Relations with conditions {:conditions=> "..."} for Product model
    def get_products_conditions_for(base_scope,query)
      search_options = {:page => page, :per_page => per_page}
      if order_by_price
        search_options.merge!(:order => :price,
                              :sort_mode => (order_by_price == 'descend' ? :desc : :asc))
      end
      if facets_hash
        search_options.merge!(:conditions => facets_hash)
      end
      with_opts = {:is_active => 1}
      if taxon
        taxon_ids = taxon.self_and_descendants.map(&:id)
        with_opts.merge!(:taxon_ids => taxon_ids)
      end
      search_options.merge!(:with => with_opts)
      facets = Product.facets(query, search_options)
      products = facets.for

      @properties[:products] = products
      @properties[:facets] = parse_facets_hash(facets)
      @properties[:suggest] = nil if @properties[:suggest] == query
      
      Product.where("id IN (?)", products.map(&:id))
    end

    def prepare(params)
      @properties[:facets_hash] = params[:facets] || {}
      @properties[:taxon] = params[:taxon].blank? ? nil : Taxon.find(params[:taxon])
      @properties[:keywords] = params[:keywords]
      per_page = params[:per_page].to_i
      @properties[:per_page] = per_page > 0 ? per_page : Spree::Config[:products_per_page]
      @properties[:page] = (params[:page].to_i <= 0) ? 1 : params[:page].to_i
      @properties[:manage_pagination] = true
      @properties[:order_by_price] = params[:order_by_price]
      if !params[:order_by_price].blank?
        @product_group = ProductGroup.new.from_route([params[:order_by_price]+"_by_master_price"])
      elsif params[:product_group_name]
        @cached_product_group = ProductGroup.find_by_permalink(params[:product_group_name])
        @product_group = ProductGroup.new
      elsif params[:product_group_query]
        @product_group = ProductGroup.new.from_route(params[:product_group_query].split("/"))
      else
        @product_group = ProductGroup.new
      end
      @product_group = @product_group.from_search(params[:search]) if params[:search]
    end

private

    # method should return new scope based on base_scope
    def parse_facets_hash(facets_hash = {})
      facets = []
      price_ranges = YAML::load(Spree::Config[:product_price_ranges])
      facets_hash.each do |name, options|
        next if options.size <= 1
        facet = Facet.new(name)
        options.each do |value, count|
          next if value.blank?
          facet.options << FacetOption.new(value, count)
        end
        facets << facet
      end
      facets
    end
  end

  class Facet
    attr_accessor :options
    attr_accessor :name
    def initialize(name, options = [])
      self.name = name
      self.options = options
    end

    def self.translate?(property)
      return true if property.is_a?(ThinkingSphinx::Field)

      case property.type
      when :string
        true
      when :integer, :boolean, :datetime, :float
        false
      when :multi
        false # !property.all_ints?
      end
    end
  end

  class FacetOption
    attr_accessor :name
    attr_accessor :count
    def initialize(name, count)
      self.name = name
      self.count = count
    end
  end
end
