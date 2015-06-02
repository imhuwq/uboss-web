class Admin::UsersController < Admin::BaseController
	before_filter :correct_user,  only:[:edit,:update]
  protect_from_forgery :except=>:add_avatar
  before_filter :signed_in_user,:only=>[:show,:index]
	def index
    @users = User.all
  end
  def show
    @user =  User.find_by_id(params[:id])
  end
	def new
		@user = User.new
	end
	# def create
 #    @user = User.new(user_params)
 #    @user.status = "stop"
 #    @img_w = params[:img_w].to_i
 #    @img_h = params[:img_h].to_i
 #    @current_w = params[:current_w].to_i
 #    if params[:img_file_path].present? && @img_w != 0 && @img_h !=0 && @current_w != 0
 #      @img_file_path = Rails.root.join('public', 'tmp', params[:img_file_path]) # 文件路径
 #      mime_type = MIME::Types.type_for(@img_file_path.to_s).first.content_type
 #      tmpfile = ActionDispatch::Http::UploadedFile.new({
 #                  :tempfile => File.new(@img_file_path),
 #                  :filename => params[:img_file_path]
 #                })
 #      tmpfile.content_type = mime_type
 #      @img = AssetLogo.new(:avatar => tmpfile)
 #      crop_img
 #      @user.asset_logo = @img
 #      @user.status = "start"
 #      @user.save
 #    end
 #    if @user.valid?
 #      flash[:success] = "注册成功。"
 #    else
 #      render :controller=>"users",:action=>"new"
 #      return
 #    end
 #    redirect_to :controller=>"main",:action=>"index"
	# end
  def edit
    @user = current_user
  end
  def update
    if @user = User.find_by_id(params[:id])
      @img_w = params[:img_w].to_i
      @img_h = params[:img_h].to_i
      @current_w = params[:current_w].to_i
      if params[:img_file_path].present? && @img_w != 0 && @img_h !=0 && @current_w != 0
        @img_file_path = Rails.root.join('public', 'tmp', params[:img_file_path]) # 文件路径
        mime_type = MIME::Types.type_for(@img_file_path.to_s).first.content_type
        tmpfile = ActionDispatch::Http::UploadedFile.new({
                    :tempfile => File.new(@img_file_path),
                    :filename => params[:img_file_path]
                  })
        tmpfile.content_type = mime_type
        @img = AssetLogo.new(:avatar => tmpfile)
        crop_img
        @user.asset_logo = @img
        @user.save
      end
      if user_params[:old_password].present? && @user.authenticate(user_params[:old_password])
        @user.update_attributes(user_params)
      elsif user_params[:password].present?
        flash[:error] = '原密码错误'
        redirect_to :controller=>"users",:action=>"edit",:id=>@user.id
        return
      end
      flash[:success] = '修改用户个人信息成功'
    else
      redirect_to :controller=>"users",:action=>"index"
      return
    end
    redirect_to :controller=>"users",:action=>"show",:id=>@user.id
  end
  # 上传头像
  def add_avatar
    # 文件上传
    image = logo_params[:asset_logo]
    puts "asset_logo#{image}"
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
    # 头像裁剪
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
          c.resize '480x480'
        end
        image.write "#{@img.avatar.thumb.current_path}"
      end
    end
  end
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end

	def user_params
		params.require(:user).permit(:email,:name,:logo,
        :gender,:able_email,
        :asset_logo,:img_w,:img_h,:current_w,:img_file_path,
        :reset_secret_status,
        :password,:password_confirmation,:old_password)
	end
  def logo_params
    params.permit(:email,:name,:logo,
        :gender,:able_email,
        :asset_logo,:img_w,:img_h,:current_w,:img_file_path,
        :reset_secret_status,:password,:password_confirmation)
  end
end
