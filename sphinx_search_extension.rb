# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class SphinxSearchExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/sphinx_search"

  # Please use sphinx_search/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    config.gem 'thinking-sphinx', :lib => false, :version => '1.3.15'
    config.gem 'thinking-sphinx-raspell', :lib => false, :version => '1.1.0'
  end
  
  def activate
    require 'thinking_sphinx'
    require 'thinking_sphinx/raspell'
    
    Spree::Config.set(:product_price_ranges => 
                      ["Under $25", "$25 to $50", "$50 to $100", "$100 to $200", "$200 and above"])
    
    ThinkingSphinx::Facet.class_eval do
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
    
    price_sql = <<-eos
      IF(variants.price < 25, 0, 
        IF(variants.price < 50, 1,
          IF(variants.price < 100, 2,
            IF(variants.price < 200, 3, 4))))
    eos
    
    price_sql = price_sql.gsub("\n", ' ').gsub('  ', '')
    
    is_active_sql = "((products.deleted_at IS NULL) AND (products.available_on <= NOW())"
    is_active_sql += " AND (products.count_on_hand > 0)" unless Spree::Config[:allow_backorders]
    is_active_sql += ")"

    option_sql = lambda do |option_name|
      sql = <<-eos
        SELECT DISTINCT p.id, ov.id
        FROM option_values AS ov
        LEFT JOIN option_types AS ot ON (ov.option_type_id = ot.id)
        LEFT JOIN option_values_variants AS ovv ON (ovv.option_value_id = ov.id)
        LEFT JOIN variants AS v ON (ovv.variant_id = v.id)
        LEFT JOIN products AS p ON (v.product_id = p.id)
        WHERE (ot.name = '#{option_name}' AND p.id>=$start AND p.id<=$end);
        SELECT IFNULL(MIN(`id`), 1), IFNULL(MAX(`id`), 1) FROM `products`
      eos
      sql.gsub("\n", ' ').gsub('  ', '')
    end
    brand_sql = option_sql.call('brand')
    color_sql = option_sql.call('color')
    size_sql  = option_sql.call('size')
    
    Product.class_eval do
      define_index do
        indexes :name
        indexes :description
        indexes taxons.name, :as => :taxon, :facet => true
        
        has taxons(:id), :as => :taxon_ids
        has price_sql, :as => :price_range, :type => :integer, :facet => true
        has is_active_sql, :as => :is_active, :type => :integer
        has master.price, :as => :price, :type => :float
        has brand_sql, :as => :brand_option, :source => :ranged_query, :type => :multi, :facet => true
        has color_sql, :as => :color_option, :source => :ranged_query, :type => :multi, :facet => true
        has size_sql, :as => :size_option, :source => :ranged_query, :type => :multi, :facet => true
      end
    end
    
    ProductsController.class_eval do
      helper :sphinx
      helper_method :option_values
      private
      def option_values(ids = [])
        @option_values ||= {}
        return @option_values if ids.empty?
        
        option_values_for_ids = {}
        OptionValue.find(ids).each do |ov|
          option_values_for_ids[ov.id] = ov.presentation
        end
        @option_values.merge!(option_values_for_ids)
        return option_values_for_ids
      end
    end
    
    Spree::Config.searcher = Spree::Search::ThinkingSphinx.new 
  end
end
