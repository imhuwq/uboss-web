class SupplierProduct < Product

  has_one :supplier_product_info, foreign_key: 'supplier_product_id', autosave: true, dependent: :destroy
  belongs_to :supplier, class_name: 'User', foreign_key: 'user_id'
  has_many :supplier_product_inventories, -> { where(type: 'SupplierProductInventory') }, foreign_key: 'product_id', autosave: true
  has_many :children, class_name: 'AgencyProduct', foreign_key: 'parent_id'

  after_save :update_children_transportation, if: -> { carriage_template_id_changed? or transportation_way_changed? or traffic_expense_changed? }

  amoeba do
    set type: 'AgencyProduct'
    include_association :supplier_product_inventories
    include_association :asset_img
    include_association :description
    customize(lambda{|original_product, new_product|
      new_product.parent_id = original_product.id
      new_product.supplier_id = original_product.user_id
      new_product.original_price = original_product.suggest_price_lower
      new_product.present_price = original_product.suggest_price_lower
    })
  end

  delegate :cost_price, :cost_price=, to: :supplier_product_info, allow_nil: true
  delegate :suggest_price_lower, :suggest_price_lower=, to: :supplier_product_info, allow_nil: true
  delegate :suggest_price_upper, :suggest_price_upper=, to: :supplier_product_info, allow_nil: true
  delegate :content, :content=, to: :supplier_product_info, prefix: 'supply', allow_nil: true
  delegate :supply_status, to: :supplier_product_info
  delegate :stored?, to: :supplier_product_info
  delegate :supplied?, to: :supplier_product_info
  delegate :deleted?, to: :supplier_product_info

  scope :stored, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 0') }
  scope :supplied, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 1') }
  scope :deleted, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 2') }

  #alias_method :supplier_product_inventories_attributes=, :product_inventories_attributes=

  def stored
    transaction do
      supplier_product_info.stored!
      unpublish_children_products
    end
  end

  def supplied
    supplier_product_info.supplied!
  end

  def deleted
    transaction do
      supplier_product_info.deleted!
      unpublish_children_products
    end
  end

  def unpublish_children_products
    if children.present?
      children.all? do |child|
        child.unpublish! if child.published?
      end
    end
  end

  def supplier_product_inventories_attributes= attributes_collection
    unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
      raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
    end

    if attributes_collection.is_a? Hash
      keys = attributes_collection.keys
      attributes_collection = if keys.include?('id') || keys.include?(:id)
                                [attributes_collection]
                              else
                                attributes_collection.values
                              end
    end

    association = association(:supplier_product_inventories)

    unseling_ids = association.scope.saling.pluck(:id)
    existing_records = if association.loaded?
                         association.target
                       else
                         attribute_ids = attributes_collection.map {|a| a['sku_attributes'] || a[:sku_attributes] }.compact
                         attribute_ids.empty? ? [] : association.scope.where(sku_attributes: attribute_ids)
                       end

    attributes_collection.each do |attributes|
      attributes = attributes.with_indifferent_access

      existing_record = existing_records.detect { |record|
        record.sku_attributes.to_s == attributes['sku_attributes'].to_s
      }

      if existing_record
        # Make sure we are operating on the actual inventoryect which is in the association's
        # proxy_target array (either by finding it, or adding it if not found)
        # Take into account that the proxy_target may have changed due to callbacks
        target_record = association.target.detect { |record|
          record.sku_attributes.to_s == attributes['sku_attributes'].to_s
        }
        if target_record
          existing_record = target_record
        else
          association.add_to_target(existing_record, :skip_callbacks)
        end
        unseling_ids.delete(existing_record.id)
        attributes[:saling] = true
        existing_record.assign_attributes(attributes.except(*UNASSIGNABLE_KEYS))
      else
        association.build(attributes.except(*ActiveRecord::NestedAttributes::UNASSIGNABLE_KEYS))
      end
    end

    unseling_ids.each do |unseling_id|
      existing_record = existing_records.detect { |record| record.id.to_s == unseling_id.to_s }
      target_record = association.target.detect { |record| record.id.to_s == unseling_id.to_s }
      if target_record
        existing_record = target_record
      elsif existing_record
        association.add_to_target(existing_record, :skip_callbacks)
      else
        existing_record = association.scope.find(unseling_id)
        association.add_to_target(existing_record, :skip_callbacks)
      end
      existing_record.assign_attributes(saling: false)
      existing_record.remove_children
    end
  end

  def has_been_agented_by?(agency)
    AgencyProduct.exists?(user_id: agency.id, parent_id: id, status: [0,1])
  end

  def total_sells
    count = 0
    children.each do |child|
      count += child.total_sells
    end
    count
  end

  private

  def must_has_one_product_inventory
    errors.add(:supplier_product_inventories, '至少添加一个产品规格属性') unless supplier_product_inventories.size > 0
  end

  def update_children_transportation
    children.each do |child|
      child.update(carriage_template_id: carriage_template_id, transportation_way: transportation_way, traffic_expense: traffic_expense)
    end
  end

end
