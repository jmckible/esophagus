class CookbooksController < ApplicationController

  def update
    Current.cookbook.update params.fetch(:cookbook).permit(:param)
    redirect_to :sections
  end

end
