module ApplicationHelper

  def page_header(title, back: nil, eyebrow: nil, summary: nil, &actions)
    heading = tag.div class: 'page-heading' do
      safe_join [
        (tag.p(link_to("← #{back.first}", back.last), class: 'page-breadcrumb') if back),
        (tag.p(eyebrow, class: 'page-eyebrow') if eyebrow),
        tag.h1(title, class: 'page-title'),
        (tag.p(summary, class: 'page-summary') if summary)
      ].compact
    end

    tag.header class: 'page-header' do
      safe_join [heading, (tag.div(capture(&actions), class: 'page-actions') if actions)].compact
    end
  end

  def nav_link(name, path, active)
    link_to name, path, class: class_names(active:)
  end

  # Structured recipes (a numbered directions list) get ingredients beside the
  # method; anything else reads as one column, or points at its source.
  def recipe_body_kind(recipe)
    body = recipe.instructions&.body
    if body.present? && body.to_plain_text.strip.present?
      body.to_html.include?('<ol') ? :structured : :prose
    elsif recipe.link.present?
      :link
    else
      :empty
    end
  end

  def interval_in_words(days)
    if days < 14 then pluralize(days, 'day')
    elsif days < 60 then pluralize((days / 7.0).round, 'wk')
    elsif days < 730 then pluralize((days / 30.4).round, 'mo')
    else pluralize((days / 365.25).round, 'yr')
    end
  end

  def time_since_in_words(date)
    days = (Time.zone.today - date).to_i
    case days
    when 0 then 'today'
    when 1 then 'yesterday'
    else "#{interval_in_words(days)} ago"
    end
  end

  # Where a date falls across its year, as a CSS percentage
  def year_position(date)
    days = Date.leap?(date.year) ? 366 : 365
    "#{((date.yday - 0.5) / days * 100).round(2)}%"
  end

  def link_host(url)
    URI.parse(url).host&.delete_prefix('www.') || url
  rescue URI::InvalidURIError
    url
  end

  def chevron_down
    tag.svg(width: 14, height: 14, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2.4, 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'aria-hidden': true) { tag.path(d: 'M6 9l6 6 6-6') }
  end

end
