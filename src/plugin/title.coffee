class Annotator.Plugin.Title extends Annotator.Plugin
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

    @field = @annotator.editor.addField({
      label:  Annotator._t('Enter a title')
      load:   this.updateField
      submit: this.setAnnotationTitle
    })

    $(@field).addClass 'title'

    @annotator.viewer.addField({
      load: this.updateViewer
    })

    @input = $(@field).find(':input')

  # updates the field
  updateField: (field, annotation) =>
    value = annotation.title
    @input.val value

  # updates the annotation when the title is updated
  setAnnotationTitle: (field, annotation) =>
    annotation.title = @input.val()

  # updates the annotation title in the viewer
  updateViewer: (field, annotation) ->
    field = $(field)

    if annotation.title
      field.addClass('annotator-title').html annotation.title
    else
      field.remove()
