class Api::V1::StoresController < ApiBaseController

  def show
    @seller = User.find(params[:id])
  end

end
