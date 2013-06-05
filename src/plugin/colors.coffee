# Public: Colors plugin allows users to configure the color of the annotation
class Annotator.Plugin.Colors extends Annotator.Plugin

  options:
    # Configurable default highlight color in RGBA or Hex
    defaultColor: 'rgba(255, 255, 10, 0.3)',
    colorOptions: ['rgba(255, 255, 10, 0.3)', 'rgba(10, 255, 10, 0.3)', 'rgba(255, 10, 10, 0.3)', 'rgba(255, 10, 255, 0.3)', 'rgba(10, 255, 255, 0.3)', 'rgba(10, 10, 255, 0.3)']

  # The field element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  field: null

  # The input element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  input: null

  constructor: (element, options) ->
    super

  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
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
  #
  # Examples
  #
  #   field = $('<li><input /></li>')[0]
  #   plugin.updateField(field, {color: '#CCCCCC'})
  #   field.value # => Returns '#CCCCCC'
  #
  # Returns nothing.
  updateField: (field, annotation) =>
    value = if annotation.color then annotation.color else @options.defaultColor

    options = $.map(@options.colorOptions, (option) ->
      '<span class="annotator-color-option" style="background-color: ' + Annotator.Util.escape(option) + '" data-color="' + Annotator.Util.escape(option) + '"></span>'
    ).join(' ')

    options = '<span class="annotator-color-options">' + options + '</span>'

    @input.closest('li').find('.annotator-color-options').remove();

    @input.after(options);
    @input.val(value).attr "type", "hidden"

  # Annotator.Editor callback function. Updates the annotation field with the
  # data retrieved from the @input property.
  #
  # field      - The color field Element containing the input Element.
  # annotation - An annotation object to be updated.
  #
  # Examples
  #
  #   field = $('<li><input value="#CCCCCC" /></li>')[0]
  #   annotation = {}
  #
  #   plugin.setAnnotationTags(field, annotation)
  #   annotation.color # => Returns '#CCCCCC'
  #
  # Returns nothing.
  setAnnotationColor: (field, annotation) =>
    annotation.color = @input.val()

  # Annotator.Viewer callback function. Updates the annotation display with the color.
  #
  # field      - The Element to populate with the color.
  # annotation - An annotation object to be display.
  #
  # Examples
  #
  #   field = $('<div />')[0]
  #   plugin.updateField(field, {color: '#CCCCCC'})
  #   field.innerHTML # => Returns '<span class="annotator-color" style="background-color: #CCCCCC">#CCCCCC</span>'
  #
  # Returns nothing.
  updateViewer: (field, annotation) ->
    field = $(field)

    color = if annotation.color then annotation.color else @options.defaultColor

    field.addClass('annotator-color').css("background-color", color).html color
