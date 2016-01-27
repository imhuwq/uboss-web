class SupplierProduct < Product

  has_one :supplier_product_info, foreign_key: 'supplier_product_id', autosave: true
  has_one :supplier, through: :supplier_product_info
  has_many :supplier_product_inventories, -> { where(type: 'SupplierProductInventory') }, foreign_key: 'product_id', autosave: true
  has_many :agency_products, foreign_key: 'parent_id'

  amoeba do
    set type: 'AgencyProduct'
    include_association :supplier_product_inventories
    customize(lambda{|original_product, new_product|
      new_product.parent_id = original_product.id
      new_product.supplier_id = original_product.user_id
    })
  end

  delegate :cost_price, :cost_price=, to: :supplier_product_info, allow_nil: true
  delegate :suggest_price_lower, :suggest_price_lower=, to: :supplier_product_info, allow_nil: true
  delegate :suggest_price_upper, :suggest_price_upper=, to: :supplier_product_info, allow_nil: true
  delegate :content, :content=, to: :supplier_product_info, prefix: 'supply', allow_nil: true
  delegate :supply_status, to: :supplier_product_info

  scope :stored, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 0') }
  scope :supplied, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 1') }
  scope :deleted, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 2') }

  #alias_method :supplier_product_inventories_attributes=, :product_inventories_attributes=

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
    end
  end

  private

  def must_has_one_product_inventory
    errors.add(:supplier_product_inventories, '至少添加一个产品规格属性') unless supplier_product_inventories.size > 0
  end

end
