class Admin::ExpressesController < AdminController
  before_action :find_express, only: [:edit, :show, :update]

  def index
    @expresses = Express.all
  end

  def new
    @express = Express.new
  end

  def edit
  end

  def update
    if @express.update(express_params)
      redirect_to admin_expresses_path
    else
      render :edit
    end
  end

  def create
    @express = Express.new(express_params)
    if @express.save
      redirect_to admin_expresses_path
    else
      render :new
    end
  end

  private
  def find_express
    @express = Express.find(params[:id])
  end

  def express_params
    params.require(:express).permit(:name)
  end
end
