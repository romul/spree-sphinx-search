Spree::ProductsController.class_eval do
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
