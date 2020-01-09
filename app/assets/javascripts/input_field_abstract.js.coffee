document.addEventListener 'turbolinks:load', ->
    console.log 'abstract field loaded'
    $('select.langx-selector').select2
        placeholder: 'Select an option'
        allowClear: true
        width: 'resolve'
    return
