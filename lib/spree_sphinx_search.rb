require 'spree_core'
require 'spree_sphinx_search_hooks'
require 'thinking-sphinx'

module SpreeSphinxSearch
  class Engine < Rails::Engine
    def self.activate
      ENV['RAILS_ENV'] = Rails.env

      if Spree::Config.instance
        Spree::Config.searcher_class = Spree::Search::ThinkingSphinx
        Spree::Config.set(:product_price_ranges => 
                      ["Under $25", "$25 to $50", "$50 to $100", "$100 to $200", "$200 and above"])
      end

      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env == "production" ? require(c) : load(c)
      end
    end
    config.to_prepare &method(:activate).to_proc
    config.autoload_paths += %W(#{config.root}/lib)

    def load_tasks
    end
  end
end
