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
      redirect_to admin_categories_url, :notice => 'Nouvelle category créée.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette catégorie"
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
      redirect_to admin_categories_url, :notice => 'Category mise à jour.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette catégorie"
      render :edit
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.delete
    redirect_to admin_categories_url, :notice => 'Catégorie supprimée'
  end

end
