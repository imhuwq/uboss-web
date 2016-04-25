class Admin::OperatorsController < AdminController
  authorize_resource
  before_action :set_operator, only: [:show, :edit, :update, :destroy, :state]

  # GET /admin/operators
  # GET /admin/operators.json
  def index
    params[:segment] = 'today' if !%w(today month all).include?(params[:segment])
    @scope = Operator.active
    @operators = @scope.page(params[:page])
  end

  def users
    @operators = Operator.active.page(params[:page])
  end

  # GET /admin/operators/1
  # GET /admin/operators/1.json
  def show
  end

  # GET /admin/operators/new
  def new
    @operator = Operator.new
  end

  # GET /admin/operators/1/edit
  def edit
  end

  def state
    @operator.active? ? @operator.disable! : @operator.active!
    respond_to do |format|
      format.js
    end
  end

  # POST /admin/operators
  # POST /admin/operators.json
  def create
    @operator = Operator.new(operator_params)

    respond_to do |format|
      if @operator.save
        flash[:success] = "创建成功"
        format.html { redirect_to users_admin_operators_path }
        format.json { render :show, status: :created, location: @operator }
      else
        flash.now[:error] = @operator.errors.full_messages.join("<br/>")
        format.html { render :new }
        format.json { render json: @operator.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operator
      @operator = Operator.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def operator_params
      params.require(:operator).permit(:company, :name, :mobile, :login)
    end
end
