class PreferentialCalculator

  attr_reader :buyer, :preferential_items, :preferential_measures

  def initialize(opts={})
    @buyer = opts[:buyer]
    @preferential_items = opts[:preferential_items]
    @preferential_measures = []
  end

  def calculate_preferential_info
    calculate_bonus_preferential
    calculate_sharing_preferential
  end

  def save_preferentials
    return true unless block_given?

    ActiveRecord::Base.transaction do
      preferential_measures.each(&:save)

      preferential_items.each do |preferential_item|
        yield(preferential_item)
      end
    end
  end

  private

  def calculate_bonus_preferential
    bonus_benefit = buyer.bonus_benefit
    return false if bonus_benefit <= 0

    preferential_items.each do |preferential_item|
      preferential_measures << preferential_item.preferentials_seller_bonuses.new(
        preferential_item: preferential_item,
        preferential_source: @buyer.user_info
      )
    end
  end

  def calculate_sharing_preferential
    preferential_items.each do |preferential_item|
      next if preferential_item.sharing_node_id.blank?
      next if preferential_item.privilege_card.blank?

      preferential_measures << preferential_item.preferentials_privileges.new(
        amount: preferential_item.privilege_card.amount(preferential_item.product_inventory),
        preferential_item: preferential_item,
        preferential_source: preferential_item.privilege_card
      )
    end
  end

end
