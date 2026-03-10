-- color-spans.lua
-- Enables colored text via bracketed spans: [text]{color="red"}
-- Works with LaTeX/PDF output using xcolor package.

function Span(el)
  local color = el.attributes['color']
  if color then
    if FORMAT:match 'latex' or FORMAT:match 'pdf' then
      return {
        pandoc.RawInline('latex', '\\textcolor{' .. color .. '}{'),
        pandoc.Span(el.content),
        pandoc.RawInline('latex', '}')
      }
    elseif FORMAT:match 'html' then
      return pandoc.Span(el.content, pandoc.Attr('', {}, {{'style', 'color: ' .. color}}))
    end
  end
end
