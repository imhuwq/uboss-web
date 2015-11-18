class UXin.Views.Conversation extends Backbone.View

  template: JST["#{UXin.TemplatesPath}/conversation"]

  className: 'conversation-box'

  initialize: ->
    @render()

  render: ->
    @$el.html @template()
    @
