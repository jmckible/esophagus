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

end
