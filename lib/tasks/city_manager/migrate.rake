namespace :city_manager do
  desc "初始化/更新 城市运营商列表数据"
  task :migrate => [:environment, :update_settled_at]  do
    FIRST_LINE_CITYS  = %w(广州 上海 深圳 北京  杭州 南京 宁波 无锡 青岛  成都  苏州 武汉 重庆)
    SECOND_LINE_CITYS = %w(常州 天津 大连 长沙 烟台 佛山 沈阳  西安  福州  南通  济南 厦门 泉州 郑州 合肥 东莞  温州 绍兴  潍坊 徐州 镇江 淄博 昆明 金华 嘉兴  唐山 中山  扬州 台州  哈尔滨 威海 珠海 石家庄 长春 呼和浩特  南昌)
    THIRD_LINE_CITYS  = %w(盐城  临沂 惠州  芜湖  南宁   包头  济宁 泰州   洛阳 湖州 宜昌  太原  东营  株洲  江门  襄阳  鄂尔多斯 柳州    淮安  连云港 泰安  吉林  马鞍山  衡阳 大庆 贵阳  岳阳 汕头 保定  漳州 邯郸  湛江 兰州 鞍山  德州 沧州  湘潭  乌鲁木齐 海口  枣庄 郴州  桂林  榆林 菏泽  廊坊 绵阳  宝鸡  镇江 茂名  银川 西宁 拉萨 张家界 丽江 西双版纳 大理 攀枝花)
    FOURTH_LINE_CITYS = %w(许昌 通辽 新乡 咸阳  松原 安阳  周口 焦作 赤峰 邢台 三亚 宿迁 赣州 平顶山 肇庆  曲靖 九江  商丘  信阳 驻马店 营口 揭阳 龙岩  安庆  日照  遵义  三明  呼伦贝尔 长治  德阳 南充  乐山 达州 盘锦 延安 上饶 锦州 宜春 宜宾 张家口 抚顺  临汾 渭南  开封 莆田 荆州 黄冈  四平  承德 齐齐哈尔 三门峡 秦皇岛  本溪 玉林 孝感 牡丹江  荆门  宁德 运城 绥化 永州 怀化  黄石 泸州 清远  邵阳 衡水 益阳 丹东 铁岭 晋城 朔州 吉安 娄底 玉溪  辽阳  南平 濮阳  晋中 资阳 衢州 内江 滁州 阜阳 十堰 大同 朝阳  六安 宿州 吕梁 通化  蚌埠  韶关 丽水 自贡 阳江 毕节)
    FIFTH_LINE_CITYS  = %w(阜新  葫芦岛 辽源  白山  白城 延边  鸡西 鹤岗 双鸭山 阿勒泰 伊春 佳木斯 七台河 黑河 大兴安岭 乌海  巴彦淖尔 乌兰察布 莱芜 昌都 兴安盟 忻州 阳泉 聊城 滨州 舟山 淮南 淮北 铜陵 黄山 迪庆 锡林郭勒盟 阿拉善盟  巢湖 亳州 池州 宣城 景德镇 萍乡 新余 鹰潭 抚州 鹤壁 漯河 南阳 鄂州 咸宁 随州 恩施  仙桃 潜江 天门  常德 湘西  梅州  汕尾  河源  潮州 云浮 那曲 梧州 北海 防城港 钦州  贵港  百色   贺州  河池 来宾   崇左 儋州 铜川  汉中  安康  商洛  嘉峪关 金昌 白银 日喀则 天水 武威 张掖 平凉 酒泉 庆阳 定西 陇南 临夏 甘南 石嘴山 吴忠 固原  中卫  海东  海北  黄南 海南 果洛 玉树 海西  广元 遂宁 广安 眉山 雅安 巴中  阿坝  甘孜 凉山 六盘水 安顺  铜仁 黔西南  黔东南 黔南  保山  昭通 普洱 山南 临沧  文山 红河 楚雄 德宏 怒江 阿里 林芝  克拉玛依  吐鲁番 哈密 昌吉  博尔塔拉蒙古  巴音郭楞蒙古 和田 阿克苏 喀什 克孜勒苏柯尔克孜 伊犁哈萨克  塔城)

    ALL_OF_CITYS = FIRST_LINE_CITYS + SECOND_LINE_CITYS + THIRD_LINE_CITYS + FOURTH_LINE_CITYS + FIFTH_LINE_CITYS

    def matched
      @matched ||= Set.new
    end

    def match?(resource, target)
      resource.any? {|city| target.match(/^#{city}/) }
      $& && matched << $& && $&
    end

    def scoped(name)
      case
      when match?(FIRST_LINE_CITYS,  name)  then CityManager.firstline
      when match?(SECOND_LINE_CITYS, name) then CityManager.secondline
      when match?(THIRD_LINE_CITYS,  name)  then CityManager.thirdline
      when match?(FOURTH_LINE_CITYS, name) then CityManager.fourthline
      when match?(FIFTH_LINE_CITYS,  name)  then CityManager.fifthline
      end
    end

    def each_by(city_code)
      ChinaCity.children(city_code).tap do |list|
        list.each do |name, code|
          yield name, code
        end
      end
    end

    def process_by_code(city_code)
      each_by(city_code) do |name, code|
        initialize!(name, code) or process_by_code(code)
      end
    end

    def initialize!(name, code)
      scope = scoped(name)
      scope && scope.find_or_initialize_by(city: code).update(rate: 0.5)
    end

    ChinaCity.provinces.each do |name, code|
      if %w(北京 上海 重庆 天津).any? {|city| match?([city], name) }
        initialize!(name, code)
      end
      process_by_code(code)
    end

    if missings = (ALL_OF_CITYS - matched.to_a).presence
      puts "Not Match! \e[1;31m" + missings.join(',') + "\e[0m "
    end
  end

  desc "更新城市运营商绑定时间"
  task :update_settled_at => :environment do
    puts "-> Correcting settled_at"
    CityManager.where.not(user_id: nil).where(settled_at: nil).update_all("settled_at = created_at")
  end
end