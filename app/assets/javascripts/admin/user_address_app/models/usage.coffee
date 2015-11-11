class UserAddress.Models.Usage extends Backbone.Model

  default:
    name: ''
    status: 'true'
    class_name: ''

  initialize: ->
    if @attributes.status == 'true'
      @attributes.class_name= ''
    else
      @attributes.class_name = 'btn-link'

    this.on( 'change', this.changeClassName, this)

  changeClassName: ->
    if @attributes.status == 'true'
      @attributes.class_name= ''
    else
      @attributes.class_name = 'btn-link'
