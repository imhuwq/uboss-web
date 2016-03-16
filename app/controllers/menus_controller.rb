class MenusController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :set_store

  # GET /menus
  # GET /menus.json
  def index
    @q = scope.search(categories_name_eq: params[:category]).result
    @menus = @q.page(params[:page])

    respond_to do |format|
      format.html
      format.json
    end
  end

  # POST /menus
  # POST /menus.json
  def create
    @menu = DishieOrder.new(menu_params)

    respond_to do |format|
      if @menu.save
        format.html { redirect_to @menu, notice: 'Menu was successfully created.' }
        format.json { render :show, status: :created, location: @menu }
      else
        format.html { render :new }
        format.json { render json: @menu.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def menu_params
      params.permit()
    end

    def set_store
      @store = ServiceStore.find params[:service_store_id]
    end

    def scope
      DishesProduct.published.with_store(@store)
    end
end
