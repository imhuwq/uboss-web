module CarriageTemplatesHelper
  def action_to_path(*options)
    args = request.path.split("/")[1..2]
    case args.last
    when 'suppliers', 'supplier_products' then ['admin', 'suppliers']
    when 'sellers', 'products' then ['admin', 'sellers']
    else
      []
    end.concat(options)
  end
end