class Menus.Views.Form extends Backbone.View

  template: JST['mobile_page/menus/templates/form']

  el: '#dishe-form-container'

  render: () ->
    console.log @template
    @$el.replaceWith @template({dishes: window.dishes.toJSON()})
    @