--- table-typography.lua
--- Three readability fixes that markdown cannot express on its own.
---
--- 1. Columns written as |---| carry AlignDefault, which the typst writer
---    renders centered. Centered prose in a table cell reads badly. Force those
---    columns left. Columns that explicitly asked for an alignment with
---    |:---| or |---:| are left exactly as the author wrote them.
---
--- 2. A number like "10 400" is three tokens to pandoc, so a narrow table cell
---    happily breaks it into "10 400-11" / "500". Joining the groups with a
---    non-breaking space keeps every figure on one line.
---
--- 3. A cell that opens with "16." is an enumeration item in typst's own markup,
---    so the cell silently renders as a list: "16." on one line and the rest
---    indented on the next. Pandoc emits it as ordinary text, so this only
---    shows up in the PDF. A non-breaking space after the marker stops typst
---    reading it as a list without changing what the cell says.
---
--- Disable all three with --no-typography on md-to-pdf.sh.

local NBSP = "\u{00A0}"

--- True when s opens with exactly three digits, i.e. a thousands group.
--- "400-12" -> true, "2026" -> false, so years are never touched.
local function opens_thousands_group(s)
  local digits = s:match('^%d+')
  return digits ~= nil and #digits == 3
end

--- Glue a leading "16." to the word after it, so typst cannot read the cell
--- as an enumeration item.
local function defuse_leading_enum_marker(blocks)
  local first = blocks[1]
  if first == nil then return blocks end
  if first.t ~= 'Plain' and first.t ~= 'Para' then return blocks end

  local inlines = first.content
  if #inlines < 3 then return blocks end
  if inlines[1].t ~= 'Str' or inlines[2].t ~= 'Space' then return blocks end
  if not inlines[1].text:match('^%d+%.$') then return blocks end

  inlines[1] = pandoc.Str(inlines[1].text .. NBSP)
  inlines:remove(2)
  first.content = inlines
  blocks[1] = first
  return blocks
end

local function clean_rows(rows)
  for _, row in ipairs(rows or {}) do
    for _, cell in ipairs(row.cells) do
      cell.contents = defuse_leading_enum_marker(cell.contents)
    end
  end
end

function Table(tbl)
  local specs = tbl.colspecs
  for i = 1, #specs do
    if specs[i][1] == 'AlignDefault' then
      specs[i][1] = 'AlignLeft'
    end
  end
  tbl.colspecs = specs

  clean_rows(tbl.head.rows)
  for _, body in ipairs(tbl.bodies) do
    clean_rows(body.head)
    clean_rows(body.body)
  end
  clean_rows(tbl.foot.rows)

  return tbl
end

function Inlines(inlines)
  local out = pandoc.Inlines({})
  local i = 1
  while i <= #inlines do
    local cur = inlines[i]
    local prev = out[#out]
    local nxt = inlines[i + 1]
    if cur.t == 'Space'
      and prev ~= nil and prev.t == 'Str'
      and nxt ~= nil and nxt.t == 'Str'
      and prev.text:match('%d$')
      and opens_thousands_group(nxt.text)
    then
      -- Merge into one Str so a chain like "2 417-3 788" collapses fully.
      out[#out] = pandoc.Str(prev.text .. NBSP .. nxt.text)
      i = i + 2
    else
      out:insert(cur)
      i = i + 1
    end
  end
  return out
end
