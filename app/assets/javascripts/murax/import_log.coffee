    detailFormatter = (index, row) ->
      html = []
      $.each row, (key, value) ->
        html.push '<p><b>' + key + ':</b> ' + value + '</p>'
        return
      html.join ''

    operateFormatter = (value, row, index) ->
      [
        '<a class="like" href="javascript:void(0)" title="Like">'
        '<i class="fa fa-heart"></i>'
        '</a>  '
        '<a class="remove" href="javascript:void(0)" title="Remove">'
        '<i class="fa fa-trash"></i>'
        '</a>'
      ].join ''

    totalTextFormatter = (data) ->
      'Total'

    totalNameFormatter = (data) ->
      data.length
    
    linkFormatter = (data) ->
      [
        '<a class="like" href="javascript:void(0)" title="Like">'
        '<i class="fa fa-heart"></i>'
        '</a>  '
      ].join ''

    totalPriceFormatter = (data) ->
      field = @field
      '$' + data.map((row) ->
        +row[field].substring(1)
      ).reduce(((sum, i) ->
        sum + i
      ), 0)
