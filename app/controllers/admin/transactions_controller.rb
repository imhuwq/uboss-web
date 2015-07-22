class Admin::TransactionsController < AdminController

  def index
    authorize! :read, Transaction
    @transactions = Transaction.recent.includes(:user).page(param_page)
  end

end
