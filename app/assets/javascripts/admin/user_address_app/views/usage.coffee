class UserAddress.Views.Usage extends Backbone.View

  template: JST[ "#{UserAddress.TemplatesPath}/usage"]
  el: '#user_address_usage'
  usage_collections: new UserAddress.Collections.Usages
  events:
    'click .btn': 'selectUsage'


  render: ->
    that = this
    usages = {'默认收货地址': 'btn-link', '默认发货地址':''}
    @usage_collections.add( new UserAddress.Models.Usage(name: '默认收货地址', status: 'true', class: '') )
    @usage_collections.add( new UserAddress.Models.Usage(name: '默认发货地址', status: 'false', class: 'btn-link') )
    @$el.html = ''
    @usage_collections.each (usage_model) ->
      that.$el.append that.template(name: usage_model.get('name'), class: usage_model.get('class'), id: usage_model.get('cid') )

  selectUsage: (e) ->
    console.log 'e', e
    usage_model = usage_collections.get( e.attr('id') )
    console.log 'usage_model', usage_model
