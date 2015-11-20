class UserAddress.Views.Usage extends Backbone.View

  template: JST[ "#{UserAddress.TemplatesPath}/usage"]
  el: '#user_address_usage'
  usage_collections: new UserAddress.Collections.Usages
  events:
    'click .btn': 'selectUsage'


  render: ->
    that = this
    usages = {'默认收货地址': 'btn-link', '默认发货地址':''}
    $(@$el).empty()
    if @usage_collections.length == 0
      @usage_collections.add( new UserAddress.Models.Usage(name: '默认收货地址', status: $('#user_address_usage_default_get_address').val(), usage: 'default_get_address') )
      @usage_collections.add( new UserAddress.Models.Usage(name: '默认发货地址', status: $('#user_address_usage_default_post_address').val(), usage: 'default_post_address') )
    @usage_collections.each (usage_model) ->
      that.$el.append that.template(name: usage_model.get('name'), id: usage_model.cid , class_name: usage_model.get('class_name'))




  selectUsage: (e) ->
    usage_model = @usage_collections.get( e.target.id )
    if usage_model.get('status') == 'true'
      usage_model.set({status: 'false'})
      $("#user_address_usage_#{usage_model.get('usage')}").val('false')
    else
      usage_model.set({status: 'true'})
      $("#user_address_usage_#{usage_model.get('usage')}").val('true')
    @usage_collections.set([usage_model], {remove: false})
    @render()
