# Public: Colors plugin allows users to configure the color of the annotation
class Annotator.Plugin.Colors extends Annotator.Plugin
  # Events and callbacks to bind to the Colors#element.
  events:
    '.annotator-color-option click': '_onColorOptionClick'
    'annotationsLoaded'            : '_setAllHighlights'
    'annotationCreated'            : '_setHighlight'
    'annotationUpdated'            : '_setHighlight'
    'annotationDeleted'            : '_removeHighlight'
    'annotationUpdatedFromStore'   : '_setHighlight'

  options:
    defaultColor: 'transparent',
    colorOptions: [
      'transparent',
      'rgba(255, 255, 0, 0.3)',   # yellow
      'rgba(255, 89, 0, 0.3)',    # orange
      'rgba(255, 107, 247, 0.3)', # pink
      'rgba(0, 230, 0, 0.3)',     # green
      'rgba(0, 64, 255, 0.3)',    # blue
      'rgba(128, 0, 128, 0.3)'    # purple
    ]

  # The field element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  field: null

  # The input element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  input: null

  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  pluginInit: ->
    return unless Annotator.supported()

    @field = @annotator.editor.addField({
      label:  Annotator._t('Choose a color') + '\u2026'
      load:   this.updateField
      submit: this.setAnnotationColor
    })

    @annotator.viewer.addField({
      load: this.updateViewer
    })

    @input = $(@field).find(':input')

  # Annotator.Editor callback function. Updates the @input field with the
  # color attached to the provided annotation.
  #
  # field      - The color field Element containing the input Element.
  # annotation - An annotation object to be edited.
  updateField: (field, annotation) =>
    value = (if annotation.color then annotation.color else @options.defaultColor)
    _this = this
    className = undefined

    unless @input.closest('li').find('.annotator-color-options').length
      colors = $.map(@options.colorOptions, (color) ->
        color = Annotator.Util.escape(color)
        active = (if value is color then 'active' else '')
        className = _this.slugify color
        colorWithNoTransparency = color.replace /[\d\.]+(\))$/, '1$1'
        '<span class="annotator-color-option ' + className + ' ' + active + '" style="background-color: ' + colorWithNoTransparency + '" data-color="' + color + '"></span>'
      ).join(' ')

      colors = '<div class="annotator-color-options"><p>Select the highlight color.</p>' + colors + '</div>'

      @input.after(colors);
    else
      @markActiveSwatch(value)

    @input.val(value).attr "type", "hidden"

  # Annotator.Editor callback function. Updates the annotation field with the
  # data retrieved from the @input property.
  #
  # field      - The color field Element containing the input Element.
  # annotation - An annotation object to be updated.
  setAnnotationColor: (field, annotation) =>
    annotation.color = @input.val()

  # Annotator.Viewer callback function. Updates the annotation display with the color.
  #
  # field      - The Element to populate with the color.
  # annotation - An annotation object to be display.
  updateViewer: (field, annotation) ->
    field = $(field)
    field.addClass('annotator-color')

  _setAllHighlights: (annotations) ->
    for annotation in annotations
      @_setHighlight annotation
    annotations

  _setHighlight: (annotation) =>
    id = annotation.id
    if id
      text = annotation.text
      color = annotation.color
      $lastHighlight = $(annotation.highlights).last()
      highlightPosition = $lastHighlight.position()

      if color
        $(annotation.highlights).css('background-color', color).addClass @slugify(color)

      $(annotation.highlights).addClass(id).removeClass 'has-note'

      @element.find('.annotation-note.' + id).remove()

      if text
        $(annotation.highlights).addClass 'has-note'

        if highlightPosition
          $noteIcon = $('<a class="annotation-note ficon-note ' + id + '" data-id="' + id + '" href="#"></a>').css 'top', highlightPosition.top
          $noteIcon.mouseover @_onNoteIconHover
          $noteIcon.mouseout @_onNoteIconHover
          $noteIcon.click @_onNoteIconClick
          @element.append $noteIcon

    annotation

  _removeHighlight: (annotation) =>
    id = annotation.id

    if id
      @element.find('.annotation-note.' + id).remove()

    annotation

  _onColorOptionClick: (event) ->
    color = $(event.target).data('color')

    # @TODO change the highlight color of the active annotation
    # console.log 'change the highlight to ' + color
    # console.log @annotation

    @markActiveSwatch(color)
    @input.val color

  _onNoteIconHover: (event) =>
    id = $(event.target).data 'id'
    $lastHighlight = $('.annotator-hl.' + id).last()

    switch event.type
      when 'mouseout'
        $('.annotator-hl.' + id).removeClass 'hovering'
      when 'mouseover'
        $('.annotator-hl.' + id).addClass 'hovering'

    $lastHighlight.trigger event.type, event

  _onNoteIconClick: (event) ->
    event?.preventDefault?()

  markActiveSwatch: (activeColor) ->
    className = @slugify activeColor
    $parent = @input.closest('li').find '.annotator-color-options'
    $parent.find('.annotator-color-option').removeClass 'active'
    $parent.find('.annotator-color-option.' + className).addClass 'active'

  # converts the string into a format that can be used as a css class
  slugify: (string) ->
    string.replace /[\W]*/g, ''
