module FilterLogic
  extend ActiveSupport::Concern

  included do
    helper_method :page_size
    helper_method :page_param
  end

  protected

  # default: order by created_at, limit 20, page 1
  # order_column to change order column and page columns
  # page_size to change limit size
  # def append_default_filter scope, opts = {}
  #   scope.recent(opts[:order_column], opts[:order_type])
  #   .paginate_by_timestamp(before_ts, after_ts, opts[:order_column])
  #   .page(page_param).per(opts[:page_size] || page_size)
  # end

  # def before_ts
  #   return Time.zone.parse(before_ts_param) if before_ts_param
  #   nil
  # end

  # def after_ts
  #   return Time.zone.parse(after_ts_param) if after_ts_param
  #   nil
  # end

  # def before_ts_param
  #   params['before_published_at']
  # end

  # def after_ts_param
  #   params["after_published_at"]
  # end

  def append_default_filter(scope, opts = {})
    order_column = opts[:order_column] || 'updated_at'
    order_type = opts[:order_type].try(:to_s) || 'DESC'
    if order_column == 'published_at'
      scope = scope.where('published_at is not null')
    end
    scope.recent(order_column, order_type)
      .paginate_by_column_name(*paginate_params(order_column, order_type, opts[:column_type]))
      .page(page_param).per(opts[:page_size] || page_size)
  end

  def orderdata(column_type = 'datetime')
    column_type ||= 'datetime'
    case column_type.to_s
    when 'datetime'
      params['orderdata'] ? Time.zone.parse(params['orderdata']) : nil
    when 'integer'
      params['orderdata'] ? params['orderdata'].to_i : nil
    end
  end

  def paginate_params(order_column = 'updated_at', order_type = 'DESC', column_type = 'datetime')
    order_column ||= 'updated_at'
    order_type ||= 'DESC'
    column_type ||= 'datetime'
    order_type == 'ASC' ? [nil, orderdata(column_type), order_column] : [orderdata(column_type), nil, order_column]
  end

  def page_size
    (params['page_size'] && params['page_size'].to_i > 0) ? params['page_size'].to_i : 20
  end

  def page_param
    (params['page'] && params['page'].to_i > 0) ? params['page'].to_i : 1
  end

  def param_page
    params[:page] || 0
  end

end
