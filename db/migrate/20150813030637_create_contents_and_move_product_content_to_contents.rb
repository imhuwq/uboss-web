class CreateContentsAndMoveProductContentToContents < ActiveRecord::Migration
  def up
    create_table :descriptions do |t|
      t.integer :resource_id
      t.string  :resource_type
      t.text    :content
    end
    Product.all.each do |obj|
      Description.create(resource_id: obj.id, resource_type: "Product", content: Product.where(id: obj.id).select("content as c").first.c)
    end
  end

  def down
    drop_table :descriptions
  end
end
