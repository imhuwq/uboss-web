#encoding:utf-8
#自定义管理系统
class Admin::ProductsController < AdminController
  layout 'admin'
	def index
    # @products = Product.all
	end
	def show
	end
	def new
    @product = Product.new
	end
	def create
	end
	def edit
	end
	def update
	end
end