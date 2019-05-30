
class FoodsController < ContentController
  private

  def content_param_list
    [
      custom_attribute_values:     [:name, :value],
    ]
  end
end
    