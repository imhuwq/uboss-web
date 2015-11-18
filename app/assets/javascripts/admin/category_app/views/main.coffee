class Category.Views.Main extends Backbone.View

  template: JST["#{Category.TemplatesPath}/main"]

  el: "#category"

  render: () ->
    @$el.html @template()
    @
