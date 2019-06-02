class AddFigureImageFigureAlternativeFigureCaptionToNews < ActiveRecord::Migration[5.2]
  def change
    add_column :news, :figure_image, :string, limit: 255
    add_column :news, :figure_alternative, :string, limit: 255
    add_column :news, :figure_caption, :string, limit: 255
  end
end
