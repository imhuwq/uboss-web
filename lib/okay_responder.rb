class OkayResponder
  def call(*args)
    [200, {"Content-Type" => "text/html"}, ["okay"]]
  end
end
