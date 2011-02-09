Product.class_eval do

      define_index do
        is_active_sql = "(products.deleted_at IS NULL AND products.available_on <= NOW() #{'AND (products.count_on_hand > 0)' unless Spree::Config[:allow_backorders]} )"
        option_sql = lambda do |option_name|
          sql = <<-eos
            SELECT DISTINCT p.id, ov.id
            FROM option_values AS ov
            LEFT JOIN option_types AS ot ON (ov.option_type_id = ot.id)
            LEFT JOIN option_values_variants AS ovv ON (ovv.option_value_id = ov.id)
            LEFT JOIN variants AS v ON (ovv.variant_id = v.id)
            LEFT JOIN products AS p ON (v.product_id = p.id)
            WHERE (ot.name = '#{option_name}' AND p.id>=$start AND p.id<=$end);
          eos
          sql.gsub("\n", ' ').gsub('  ', '')
        end

    brand_sql = option_sql.call('brand')
    color_sql = option_sql.call('color')
    size_sql  = option_sql.call('size')

        set_property :sql_range_step => 1000000
        indexes :name
        indexes :description
        indexes :meta_description
        indexes :meta_keywords
        indexes taxons.name, :as => :taxon, :facet => true
        has taxons(:id), :as => :taxon_ids
        group_by :deleted_at
        group_by :available_on
        has is_active_sql, :as => :is_active, :type => :boolean
        has brand_sql , :as => :brand_option, :source => :ranged_query, :type => :multi, :facet => true
#        has color_sql , :as => :color_option, :source => :ranged_query, :type => :multi, :facet => true
#        has size_sql , :as => :size_option, :source => :ranged_query, :type => :multi, :facet => true
      end
end
