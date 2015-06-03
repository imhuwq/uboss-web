#encoding:utf-8
#自定义管理系统
class Admin::ProductsController < AdminController
  # layout 'admin'
	def index
    # @products = Product.all
	end
	def show
	end
	def new
    @product = Product.new
	end
	def create
	end
	def edit
	end
	def update
	end

  # 上传图片
  def add_avatar
    # 文件上传
    image = logo_params[:asset_img]
    puts "asset_img#{image}"
    tmp_path = Rails.root.join('public', 'tmp')
    FileUtils.mkdir(tmp_path) unless File.exist?(tmp_path)
    file_name = ''
    if image.present?
      file_name = Time.now.strftime('pic%m%d%H%M%S%L_') + rand(1000).to_s + '.' + image.original_filename.split('.').last.downcase
      File.open(Rails.root.join('public', 'tmp', file_name), 'wb') do |file|
        file.write(image.read)
      end
    end
    render :text => file_name
  end
  private
    # 图片裁剪
  def crop_img
    if @img.present?
      # 图像裁剪的比例计算
      @img_w = params[:img_w].to_i
      @img_h = params[:img_h].to_i
      @current_w = params[:current_w].to_i
      @img_x  = params[:img_x].to_i
      @img_y = params[:img_y].to_i
      # 只有比例正确时才进行处理
      if @img_w != 0 && @img_h != 0 && @current_w != 0
        image = MiniMagick::Image.open "#{@img.avatar.current_path}"
        @origin_width = image[:width]
        @origin_img_w = ((@origin_width * 1.0 / @current_w) * @img_w).to_i
        @origin_img_h = ((@origin_width * 1.0 / @current_w) * @img_h).to_i
        @origin_img_x = ((@origin_width * 1.0 / @current_w) * @img_x).to_i
        @origin_img_y = ((@origin_width * 1.0 / @current_w) * @img_y).to_i
        image.combine_options do |c|
          c.crop "#{@origin_img_w}x#{@origin_img_h}+#{@origin_img_x}+#{@origin_img_y}"
          c.resize '800x600'
        end
        image.write "#{@img.avatar.thumb.current_path}"
      end
    end
  end
end