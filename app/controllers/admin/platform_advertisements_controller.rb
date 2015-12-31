class Admin::PlatformAdvertisementsController < AdminController

	authorize_resource
  before_filter :get_platform_advertisement, only: [:show, :edit, :change_status, :update, :destroy]

	def index
		 @platform_advertisements = Advertisement.where(platform_advertisement: true).order("updated_at DESC").page(params[:page] || 1)
	end

	def show
	end

	def new
    @platform_advertisement = Advertisement.new
	end

	def create
    @platform_advertisement = Advertisement.new(platform_advertisement_params)
    @platform_advertisement.platform_advertisement = true
    @platform_advertisement.status = 'hide'
		if platform_advertisement_params[:advertisement_url].present? && platform_advertisement_params[:avatar].present? && @platform_advertisement.save
			flash[:success] = "创建成功"
			redirect_to action: :index
    elsif !platform_advertisement_params[:advertisement_url].present? || !platform_advertisement_params[:avatar].present?
      flash[:error] = '请填写链接并上传图片'
      render :new
		else
			flash[:error] = "#{@platform_advertisement.errors.full_messages.join('<br/>')}"
			render :new
		end
	end

	def edit
	end

	def update
    if platform_advertisement_params[:advertisement_url].present? && @platform_advertisement.update(platform_advertisement_params)
      flash[:success] = '修改成功'
    elsif !platform_advertisement_params[:advertisement_url].present?
      flash[:error] = '请填写链接并上传图片'
      render :edit
      return
    else
      flash[:error] = '修改失败'
    end
    redirect_to action: :index
	end

	def change_status
		if params[:status] == 'show'
			@platform_advertisement.status = 'show'
			@notice = '上架成功'
		elsif params[:status] == 'hide'
			@platform_advertisement.status = 'hide'
			@notice = '取消上架成功'
		end
		if not @platform_advertisement.save
			@error = model_errors(@platform_advertisement).join('<br/>')
		end
		if request.xhr?
			flash.now[:success] = @notice
			flash.now[:error] = @error
			render(partial: 'platform_advertisements', locals: { platform_advertisements: [@platform_advertisement] })
		else
			flash[:success] = @notice
			flash[:error] = @error
			redirect_to action: :index
		end
	end

  def destroy
    if @platform_advertisement.destroy
      flash[:success] = '删除成功'
    else
      flash[:error] = '删除失败'
    end
    redirect_to action: :index
  end

	private
	# Never trust parameters from the scary internet, only allow the white list through.
	def platform_advertisement_params
		params.require(:advertisement).permit(:advertisement_url,:avatar, :status)
	end

  def get_platform_advertisement
    @platform_advertisement = Advertisement.where(platform_advertisement: true).find(params[:id])
  end

end