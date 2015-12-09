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

	private
	# Never trust parameters from the scary internet, only allow the white list through.
	def platform_advertisement_params
		params.require(:platform_advertisement).permit(:advertisement_url,:avatar)
	end

end