class SectionsController < ApplicationController

  def index
    @section  = Section.new
    @sections = Current.cookbook.sections.by_position
  end

  def show
    @section = Current.cookbook.sections.find(params[:id])
    fresh_when @section
  end

  def edit
    @section = Current.cookbook.sections.find(params[:id])
    fresh_when @section
  end

  def create
    @section = Current.cookbook.sections.build params.fetch(:section, {}).permit(:name)
    @section.position = Current.cookbook.sections.maximum(:position).to_i + 1
    @section.save
    redirect_to sections_url
  end

  def update
    @section = Current.cookbook.sections.find(params[:id])
    if @section.update(params.fetch(:section, {}).permit(:name))
      render turbo_stream: turbo_stream.replace(@section, partial: 'sections/display', locals: { section: @section })
    else
      render turbo_stream: turbo_stream.replace(@section, partial: 'sections/edit_form', locals: { section: @section }), status: :unprocessable_entity
    end
  end

  def destroy
    @section = Current.cookbook.sections.find(params[:id])
    @section.destroy
    render turbo_stream: turbo_stream.remove(@section)
  end

  def move_up
    @section = Current.cookbook.sections.find(params[:id])
    previous_section = Current.cookbook.sections.by_position
      .where(position: ...@section.position)
      .last

    if previous_section
      @section.position, previous_section.position = previous_section.position, @section.position
      @section.save!
      previous_section.save!
    end

    @sections = Current.cookbook.sections.by_position
    render turbo_stream: turbo_stream.update('sections-table-body', partial: 'sections_rows', locals: { sections: @sections })
  end

  def move_down
    @section = Current.cookbook.sections.find(params[:id])
    next_section = Current.cookbook.sections.by_position
      .where(position: (@section.position + 1)..)
      .first

    if next_section
      @section.position, next_section.position = next_section.position, @section.position
      @section.save!
      next_section.save!
    end

    @sections = Current.cookbook.sections.by_position
    render turbo_stream: turbo_stream.update('sections-table-body', partial: 'sections_rows', locals: { sections: @sections })
  end

end
