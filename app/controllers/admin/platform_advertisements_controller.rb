class Admin::PlatformAdvertisementsController < AdminController

	load_and_authorize_resource

	def index
		 PlatformAdvertisement.accessible_by(current_ability).order("updated_at DESC").page(params[:page] || 1)
	end

	def show
	end

	def new
	end

	def create
		if @platform_advertisement.save
			flash[:success] = "创建成功"
			redirect_to action: :index
		else
			flash[:error] = "#{@platform_advertisement.errors.full_messages.join('<br/>')}"
			render :new
		end
	end

	def edit
	end

	def update
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
		params.require(:platform_advertisement).permit(:advertisement_url,:avatar, :status)
	end

end