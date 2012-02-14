Spree::Product.class_eval do
  class_attribute :indexed_options
  self.indexed_options = []

  define_index do
    is_active_sql = "(spree_products.deleted_at IS NULL AND spree_products.available_on <= NOW() #{'AND (spree_products.count_on_hand > 0)' unless Spree::Config[:allow_backorders]} )"
    option_sql = lambda do |option_name|
      sql = <<-eos
        SELECT DISTINCT p.id, ov.id
        FROM option_values AS ov
        LEFT JOIN option_types AS ot ON (ov.option_type_id = ot.id)
        LEFT JOIN option_values_variants AS ovv ON (ovv.option_value_id = ov.id)
        LEFT JOIN variants AS v ON (ovv.variant_id = v.id)
        LEFT JOIN products AS p ON (v.product_id = p.id)
        WHERE (ot.name = '#{option_name}' AND p.id>=$start AND p.id<=$end);
        #{source.to_sql_query_range}
      eos
      sql.gsub("\n", ' ').gsub('  ', '')
    end

    indexes :name
    indexes :description
    indexes :meta_description
    indexes :meta_keywords
    indexes taxons.name, :as => :taxon, :facet => true
    has taxons(:id), :as => :taxon_ids
    group_by :deleted_at
    group_by :available_on
    has is_active_sql, :as => :is_active, :type => :boolean
    source.model.indexed_options.each do |opt|
      has option_sql.call(opt.to_s), :as => :"#{opt}_option", :source => :ranged_query, :type => :multi, :facet => true
    end
  end
end
