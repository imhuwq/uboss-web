class Admin::CertificationsController < AdminController
  def index
    @certifications = Certification.page(params[:page])
  end

  def persons
    @certifications = append_default_filter PersonalAuthentication
    render "index"
  end

  def enterprises
    @certifications = append_default_filter EnterpriseAuthentication
    render "index"
  end

  def city_managers
    @certifications = append_default_filter CityManagerAuthentication
    render "index"
  end

  def change_status
    @certification = Certification.find(params[:id])
    @certifications = @certification.class.page(params[:page])
    @certification.status = params[:status]
    if params[:status] == "pass"
      @certification.check_and_set_user_authenticated_to_yes
    else
      @certification.check_and_set_user_authenticated_to_no
    end

    if @certification.save
      flash.now[:success] = '状态被修改'
    else
      @certification.valid?
      flash.now[:error] = "保存失败：#{@certification.errors.full_messages.join('<br/>')}"
    end

    respond_to do |format|
      format.html { redirect_to action: :show, user_id: @certification.user_id }
      format.js
    end
  end
end
