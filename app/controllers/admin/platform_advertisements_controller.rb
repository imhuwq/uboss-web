class Admin::PlatformAdvertisementsController < AdminController

	authorize_resource

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
		if @platform_advertisement.save
			flash[:success] = "创建成功"
			redirect_to action: :index
		else
			flash[:error] = "#{@platform_advertisement.errors.full_messages.join('<br/>')}"
			render :new
		end
	end

	def edit
    @platform_advertisement = Advertisement.where(platform_advertisement: true).find(params[:id])
	end

	def update
    @platform_advertisement = Advertisement.where(platform_advertisement: true).find(params[:id])
    if @platform_advertisement.update(platform_advertisement_params)
      flash[:success] = '修改成功'
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
			render(partial: 'platform_advertisements', locals: { platform_advertisements: PlatformAdvertisement.all })
		else
			flash[:success] = @notice
			flash[:error] = @error
			redirect_to action: :show, id: @platform_advertisement.id
		end
	end

	private
	# Never trust parameters from the scary internet, only allow the white list through.
	def platform_advertisement_params
		params.require(:advertisement).permit(:advertisement_url,:avatar, :status)
	end

end