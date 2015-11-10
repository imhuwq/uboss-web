(($) ->
  $.fn.china_city = () ->
    @each ->
      selects = $(@).find('.city-select')
      selects.change ->
        $this = $(@)
        next_selects = selects.slice(selects.index(@) + 1) # empty all children city
        console.log next_selects
        $.each $("option", next_selects), (index, item) ->
          unless $(item).attr('value') == ""
            $(item).remove()
        if next_selects.first()[0] and $this.val() and !$this.val().match(/--.*--/) # init next child
          $.get "/china_city/#{$(@).val()}", (data) ->
            data = data.data if data.data?
            console.log "data", data
            next_selects.first()[0].options.add(new Option(option[0], option[1])) for option in data
            console.log 'next_selects', next_selects
            # init value after data completed.
            console.log next_selects.trigger('china_city:load_data_completed')

  $(document).on 'ready page:load', ->
    $('.city-group').china_city()

)(if typeof(jQuery)=="function" then jQuery else Zepto)
