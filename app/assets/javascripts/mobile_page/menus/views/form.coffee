class Menus.Views.Form extends Backbone.View

  template: JST['mobile_page/menus/templates/form']

  el: '#dishe-form-container'

  render: () ->
    @$el.replaceWith @template({dishes: window.dishes.toJSON()})
    @