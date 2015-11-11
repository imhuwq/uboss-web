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

    this.on( 'change', this.alertLog, this)

  # alertLog: ->
  #   console.log 'change:attributes:status'
  #   if @attributes.status == 'true'
  #     @attributes.class_name= ''
  #   else
  #     @attributes.class_name = 'btn-link'
