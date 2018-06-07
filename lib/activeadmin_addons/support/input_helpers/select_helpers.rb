module ActiveAdminAddons
  module SelectHelpers
    include InputMethods
    include InputOptionsHandler

    def array_to_select_options
      selected_values = input_value.to_s.split(",")
      array = collection.map(&:to_s) + selected_values
      array.sort.map do |value|
        option = { id: value, text: value }
        option[:selected] = "selected" if selected_values.include?(value)
        option
      end.uniq
    end

    def initial_collection_to_select_options
      selected = selected_item

      if selected
        selected_option = item_to_select_option(selected)
        [[selected_option[:text], selected_option[:id]]]
      else
        [[nil]] # add blank option
      end
    end

    def collection_to_select_options
      complete_collection = collection + selected_collection
      complete_collection.map do |item|
        option = item_to_select_option(item)
        yield(item, option) if block_given?

        if selected_collection.include?(item)
          load_data_attr(:selected, value: option.dup, formatter: :to_json)
          option[:selected] = "selected"
        end

        option
      end.uniq
    end

    def item_to_select_option(item)
      return unless item
      {
        id: item.send((valid_options[:value] || :id)),
        text: extract_item_label(item)
      }
    end

    def active_record_select?
      active_record_relation?(collection) &&
        active_record_relation?(selected_collection)
    rescue NameError
      false
    end

    def selected_collection
      chain = method_model.where(id: input_value)
      if decorate?
        chain =
          if decorator
            decorator.decorate(chain)
          else
            chain.decorate
          end
      end
      chain
    end

    def selected_item
      selected_collection.first
    end

    def filters_attributes
      if @options[:filters_attributes]
        if @options[:filters_attributes].is_a?(Array)
          Hash[@options[:filters_attributes].map { |v| [v, v] }]
        else
          @options[:filters_attributes]
        end
      end
    end

    private

    def active_record_relation?(value)
      klass = value.class.name
      klass == "ActiveRecord::Relation" ||
        klass == "ActiveRecord::Associations::CollectionProxy"
    end

    def valid_options
      raise "missing @options hash" unless !!@options
      @options
    end

    def collection
      valid_options[:collection] || []
    end

    def extract_item_label(item)
      field = [
        valid_options[:display_name],
        valid_options[:fields].try(:first)
      ].reject(&:blank?).find { |method_name| item.respond_to?(method_name) }
      field ||= ActiveadminAddons.default_display_name(item)
      item.public_send(field)
    end

    def decorate?
      options[:decorate]
    end

    def decorator
      decorator_klass = options[:decorate_with]
      return decorator_klass.constantize if decorator_klass.kind_of?(String)
      decorator_klass
    end
  end
end
