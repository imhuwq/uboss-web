class Api::V1::Admin::CarriageTemplatesController < ApiBaseController

  def index
    @carriage_templates = append_default_filter current_user.carriage_templates, order_column: :updated_at
  end

  def show
    @carriage_template = current_user.carriage_templates.find(params[:id])
  end

end
