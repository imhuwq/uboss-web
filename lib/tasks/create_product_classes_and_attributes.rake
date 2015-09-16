namespace :db do
  desc 'Fill database with sample data'
  task create_product_classes: :environment do
    puts '开始添加商品分类'
    class_name = %w(颜色 尺寸 尺码 规格 款式 净含量 种类 内存 版本
                    重量 套餐 容量 上市时间 系列 机芯 适用 包装 口味
                    产地 出行日期 出行人群 入住时段 房型 介质 开本
                    类型 有效期)
    class_name.each do |name|
      ProductClass.find_or_create_by(name: name)
    end
    puts '商品分类添加成功!'
  end
end
