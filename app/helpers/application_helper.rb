module ApplicationHelper

  def btn_to(name, options, type: 'primary', **opts)
    button_to name, options, class: "btn btn-#{type}", method: :get, **opts
  end

  def fire_if(boolean)
    '🔥' if boolean
  end

  def forgotten_if(boolean)
    '👻' if boolean
  end

  def not_zero(number)
    number unless number.to_i.zero?
  end

  def section_color_class(section)
    return nil unless section

    # Find section's index in the ordered list
    sections = section.cookbook.sections.by_position.to_a
    section_index = sections.index(section)

    # Calculate color index (skip first section like on homepage)
    return nil if section_index == 0
    color_index = (section_index - 1) % 6

    "section-color-#{color_index}"
  end

end
