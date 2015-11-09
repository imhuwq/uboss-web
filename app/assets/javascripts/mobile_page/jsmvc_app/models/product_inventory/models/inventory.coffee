class ProductInventory.Models.Inventory extends Backbone.Model
  
  defaults:
    count: '0'
  template: JST["#{ProductInventory.TemplatesPath}/property"]
