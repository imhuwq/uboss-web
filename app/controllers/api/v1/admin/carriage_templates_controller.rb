class Api::V1::Admin::CarriageTemplatesController < ApiBaseController

  def index
    @carriage_templates = append_default_filter CarriageTemplate, order_column: :updated_at
  end

  def show
    @carriage_template = CarriageTemplate.find(params[:id])
  end

end
