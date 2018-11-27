module ApplicationHelper

  def btn_to(name, options, type: 'primary')
    button_to name, options, class: "btn btn-#{type}", method: :get
  end

  def not_zero(number)
    number unless number.to_i.zero?
  end

end
