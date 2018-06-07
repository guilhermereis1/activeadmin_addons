$(function() {
  setupSearchSelect(document);

  $(document).on('has_many_add:after', function(event, container) {
    setupSearchSelect(container);
  });

  function setupSearchSelect(container) {
    $('.search-select-input, .search-select-filter-input, ajax-filter-input', container).each(function(i, el) {
      var url = $(el).data('url');
      var model = $(el).data('model');
      var fields = $(el).data('fields');
      var displayName = $(el).data('display-name');
      var width = $(el).data('width');
      var responseRoot = $(el).data('response-root');
      var minimumInputLength = $(el).data('minimum-input-length');
      var order = $(el).data('order');
      var filtersAttributes = $(el).data('filters-attributes');
      var selectInstance;

      var selectOptions = {
        width: width,
        minimumInputLength: minimumInputLength,
        placeholder: '',
        allowClear: true,
        ajax: {
          url: url,
          dataType: 'json',
          delay: 250,
          cache: true,
          data: function(params) {
            var textQuery = { m: 'or' };
            fields.forEach(function(field) {
              if (field == 'id') {
                textQuery[field + '_eq'] = params.term;
              } else {
                textQuery[field + '_contains'] = params.term;
              }
            });

            var query = {
              order: order,
              q: {
                groupings: [textQuery],
                combinator: 'and',
              },
            };

            if (filtersAttributes) {
              $.each(filtersAttributes, function(index, attribute) {
                var attributeElement = $('#' + model + '_' + index);
                var attributeValue = attributeElement.val();

                if (attributeElement) {
                  query.q[attribute + '_eq'] = attributeValue;
                }
              });
            }

            return $.extend(query, $(el).triggerHandler('nestedSelect:query', query));
          },
          processResults: function(data) {
            if (data.constructor == Object) {
              data = data[responseRoot];
            }

            return {
              results: jQuery.map(data, function(resource) {
                if (!resource[displayName]) {
                  resource[displayName] = 'No display name for id #' + resource.id.toString();
                }
                return {
                  id: resource.id,
                  text: resource[displayName].toString(),
                };
              }),
            };
          },
        },
      };

      selectInstance = $(el).select2(selectOptions);

      function setFilterValue() {
        selectInstance.val(null).trigger('select2:select').trigger('change');
      }

      if (filtersAttributes) {
        $.each(filtersAttributes, function(index, attribute) {
          var attributeElement = $('#' + model + '_' + index);
          attributeElement.on('select2:select', setFilterValue);
          attributeElement.on('select2:unselect', setFilterValue);
        });
      }
    });
  }
});
