#= require websocket.coffee
$.extend WSClient.prototype.actions,
  button: (data) ->
    target = @__parent.check_target(data)
    class_name = if data.inline then 'inline-button' else 'full-button'
    left_icon = ""
    data.right_icon ||= data.icon
    left_icon = "<i class='fa fa-#{data.left_icon} label-icon-left'></i>" if data.left_icon
    right_icon = ""
    right_icon = "<i class='fa fa-#{data.right_icon} label-icon-right'></i>" if data.right_icon

    element = $("<a href='#' class='#{class_name}'>#{left_icon}#{@__parent.escape(data.label, data)}#{right_icon}</a>")
    element.click =>
      @__parent.send({
        id:data.id
        action:'callback'
        source:'button'
        original_msg:data
        })
    target.append element

  buttonbox: (data) ->
    target = @__parent.check_target(data)

    element = target.find("#console-#{data.name}")
    if element.size() is 0
      target.prepend("<pre class='button-box' id='console-#{data.name}'></pre>")
    else
      element.addClass('button-box')

  input: (data) ->
    target = @__parent.check_target(data)
    if data.multiline
      element = $("<textarea placeholder='#{data.label}' class='inline-text-input'></textarea>")
    else
      element = $("<input type='text' placeholder='#{data.label}' class='inline-text-input'>")
    if data.value
      element[0].value = data.value

    element.change =>
      unless element.hasClass("unclicked")
        @__parent.send({
          id:data.id
          action:'callback'
          source:'input'
          text: element[0].value
          original_msg:data
          })
        if data.once
          replaceText = @__parent.escape("#{element[0].value}\n")
          replaceText = "#{data.label}#{replaceText}" if data.keep_label
          element.replaceWith(replaceText)
        if data.history
          history = element.data('history') || []
          history.push element[0].value
          element.data('history', history)
          element.data('history-index', history.length)
        if data.autoclear
          element[0].value = ""

    offset_history = (e, amt) =>
      history = element.data('history') || []
      i = element.data('history-index') + amt
      e.preventDefault()
      if i >= 0 and i < history.length
        element[0].value = history[i]
        element.data('history-index', i)

    element.keydown (e) =>
      offset_history(e, -1) if e.which is 38 and data.history
      offset_history(e, +1) if e.which is 40 and data.history

    target.append(element)

    if data.focus
      element.focus()

  checkbox: (data) ->
    target = @__parent.check_target(data)
    element = $("<label class='inline-checkbox'><input type='checkbox'><span>#{@__parent.escape(data.label,data)}</span></label>'")
    if data.value
      element.find('input').attr "checked", true
      element.addClass "checked"
    element.change (e) =>
      element.toggleClass("checked",  element.find('input').prop('checked'))
      @__parent.send({
        id:data.id
        action:'callback'
        source:'input'
        checked: element.find('input').prop('checked')
        original_msg:data
        })
    element.click (e) =>
      if e.shiftKey and @__lastChecked
        all_boxes = $('.inline-checkbox')
        start = all_boxes.index(@__lastChecked)
        stop = all_boxes.index(element)
        console.log start, stop

        all_boxes.slice(Math.min(start, stop), Math.max(start, stop) + 1).find('input').prop("checked", @__lastChecked.find('input').prop("checked"))
        all_boxes.change()
      else
        @__lastChecked = element
    target.append(element)

  dropdown: (data) ->
    target = @__parent.check_target(data)
    element = $("<select class='inline-dropdown' name='#{data.id}'></select>")
    element.append($("<option>#{item}</option>")) for item in data.options
    element.change (e) =>
      @__parent.send({
        id:data.id
        action:'callback'
        source:'dropdown'
        text: element.find('option:selected').text()
        })
    @__parent.add(element, target, data)
