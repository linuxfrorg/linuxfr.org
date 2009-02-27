class Admin::CategoriesController < AdminController

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:notice] = 'Nouvelle category créée.'
      redirect_to admin_categories_url
    else
      render :new
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    @category.attributes = params[:category]
    if @category.save
      flash[:notice] = 'Category mise à jour.'
      redirect_to admin_categories_url
    else
      render :edit
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.delete
    redirect_to admin_categories_url
  end
end
