# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class SphinxSearchExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/sphinx_search"

  # Please use sphinx_search/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    config.gem 'thinking-sphinx', :lib => false, :version => '1.3.15'
  end
  
  def activate
    require 'thinking_sphinx'
    
    Product.class_eval do
      define_index do
        indexes :name
        indexes :description
        indexes taxons.name, :as => :taxon, :facet => true
        
        has master.price, :as => :price
      end
    end
    
    Spree::BaseController.class_eval do
      helper :sphinx
    end
    
    Spree::Config.searcher = Spree::Search::ThinkingSphinx.new 
  end
end
