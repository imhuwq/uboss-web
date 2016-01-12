class Browser
  module Uboss
    def uboss?
      !!(ua =~ /ubossman/)
    end
  end
end

Browser.send :include, Browser::Uboss
