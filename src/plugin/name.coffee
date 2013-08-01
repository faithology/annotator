class Annotator.Plugin.Name extends Annotator.Plugin
  # The field element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  field: null

  # The input element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  input: null

  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()

    @field = @annotator.editor.addField
      label:  Annotator._t('Enter a name for this annotation')
      load:   this.updateField
      submit: this.setAnnotationName
      prepend: true


    $(@field).addClass 'name'

    @annotator.viewer.addField
      load: this.updateViewer


    @input = $(@field).find(':input')

  # updates the field
  updateField: (field, annotation) =>
    value = annotation.name
    @input.val value

  # updates the annotation when the name is updated
  setAnnotationName: (field, annotation) =>
    annotation.name = @input.val()

  # updates the annotation name in the viewer
  updateViewer: (field, annotation) ->
    field = $(field)

    if annotation.name
      field.addClass('annotator-name').html annotation.name
    else
      field.remove()
