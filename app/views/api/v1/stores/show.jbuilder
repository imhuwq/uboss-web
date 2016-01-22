json.extract! @seller, :id, :total_reputations
json.store_short_description @seller.store_short_description.to_s
json.store_name @seller.store_name.to_s
json.best_evaluation @seller.user_info.best_evaluation.to_i
json.better_evaluation @seller.user_info.better_evaluation.to_i
json.good_evaluation @seller.user_info.good_evaluation.to_i
