module ActiveAdminAddons
  module FilterInputMethods
    include InputMethods

    def object_class
      valid_object.klass
    end

    def input_value
      result = valid_object.conditions.find do |condition|
        condition.attributes.map(&:name).include?(valid_method.to_s)
      end

      return unless result
      result.values.first.value
    end

    def input_html_options_name
      if builder.options.key?(:index)
        "#{object_name}[#{builder.options[:index]}][#{input_method}]"
      else
        "#{object_name}[#{input_method}]"
      end
    end

    def eq_input_name
      "#{valid_method}_eq"
    end

    def gteq_input_name
      "#{method}_gteq"
    end

    def lteq_input_name
      "#{method}_lteq"
    end
  end
end
