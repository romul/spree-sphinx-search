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
    
    price_sql = <<-eos
      IF(price < 25, 0, 
        IF(price < 50, 1,
          IF(price < 100, 2,
            IF(price < 200, 3, 4))))
eos
    price_sql = price_sql.gsub("\n", ' ').gsub('  ', '')
    
    Product.class_eval do
      define_index do
        indexes :name
        indexes :description
        indexes taxons.name, :as => :taxon, :facet => true
        
        has price_sql, :as => :price_range, :type => :integer, :facet => true
        has master.price, :as => :price, :type => :float
      end
    end
    
    Spree::BaseController.class_eval do
      helper :sphinx
    end
    
    Spree::Config.searcher = Spree::Search::ThinkingSphinx.new 
  end
end
