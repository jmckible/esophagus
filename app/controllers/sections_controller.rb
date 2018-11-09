class SectionsController < ApplicationController

  def index
    @section  = Section.new
    @sections = Section.by_position
  end

  def create
    @section = Current.cookbook.sections.build params.fetch(:section, {}).permit(:name, :position)
    @section.save
    redirect_to sections_url
  end

end
