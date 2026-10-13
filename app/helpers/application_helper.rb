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

  def link_host(url)
    URI.parse(url).host&.delete_prefix('www.') || url
  rescue URI::InvalidURIError
    url
  end

  def chevron_down
    tag.svg(width: 14, height: 14, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': 2.4, 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'aria-hidden': true) { tag.path(d: 'M6 9l6 6 6-6') }
  end

end
