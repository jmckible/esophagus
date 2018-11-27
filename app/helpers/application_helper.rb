module ApplicationHelper

  def btn_to(name, options, type: 'primary', style: '')
    style = style + " btn btn-#{type}"
    button_to name, options, class: style, method: :get
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

end
