local model = require("./model.luau")

local dayOffset = 0
local width = 356

local function dayKey(milliseconds)
  return noctalia.formatTime("{:%F}", milliseconds / 1000)
end

local function timeText(milliseconds)
  return noctalia.formatTime("{:%H:%M}", milliseconds / 1000)
end

local function targetTimestamp(nowMs)
  return nowMs + dayOffset * 24 * 60 * 60 * 1000
end

local function openUrl(url)
  if model.isHttpUrl(url) then
    noctalia.runAsync({ "xdg-open", url })
  end
end

local function detailText(event)
  if event.location == nil or event.location == "" then
    return ""
  end
  if string.match(event.location, "^https?://") then
    return "Онлайн"
  end
  return event.location
end

local function statusMeta(state)
  if state == "done" then
    return "circle-check", "on_surface_variant", "surface_container_low"
  elseif state == "current" then
    return "player-play-filled", "on_primary_container", "primary_container"
  end
  return "clock", "primary", "surface_container_high"
end

local function eventCard(event, nowMs)
  local state = model.state(event, nowMs)
  local glyph, color, fill = statusMeta(state)
  local details = detailText(event)
  local children = {
    ui.row({ gap = 10, align = "start" }, {
      ui.glyph({ name = glyph, size = 17, color = color }),
      ui.column({ gap = 3, flexGrow = 1 }, {
        ui.row({ gap = 8, align = "center" }, {
          ui.label({
            text = timeText(event.startMs) .. "–" .. timeText(event.endMs),
            fontSize = 12,
            fontWeight = "bold",
            color = color,
            flexGrow = 1,
          }),
          ui.glyph({
            name = "external-link",
            size = 14,
            color = color,
            visible = event.url ~= nil and event.url ~= "",
          }),
        }),
        ui.label({
          text = event.title ~= "" and event.title or "Без названия",
          fontSize = 14,
          fontWeight = state == "current" and "bold" or "medium",
          color = state == "current" and "on_primary_container" or "on_surface",
          maxWidth = 294,
          maxLines = 2,
        }),
      }),
    }),
  }

  if details ~= "" then
    table.insert(children, ui.label({
      text = details,
      fontSize = 12,
      color = state == "current" and "on_primary_container" or "on_surface_variant",
      maxWidth = 318,
      maxLines = 2,
    }))
  end

  if state == "current" then
    table.insert(children, ui.progress({
      progress = model.progress(event, nowMs),
      fill = "primary",
      track = "on_primary_container/0.18",
      radius = 3,
      height = 5,
      width = 324,
    }))
  end

  local props = {
    key = event.id .. ":" .. tostring(event.startMs),
    gap = 7,
    padding = 10,
    fill = fill,
    radius = 12,
  }
  if event.url ~= nil and event.url ~= "" then
    props.onClick = function()
      openUrl(event.url)
    end
  end
  return ui.column(props, children)
end

local function summaryText(events, nowMs)
  if dayOffset ~= 0 then
    return string.format("Завтра · %d", #events)
  end
  for _, event in ipairs(events) do
    if model.state(event, nowMs) == "current" then
      return "Сейчас · осталось " .. model.durationText(event.endMs - nowMs)
    end
  end
  local next = model.nextEvent(events, nowMs)
  if next ~= nil then
    return "Следующая через " .. model.durationText(next.startMs - nowMs)
  elseif #events > 0 then
    return "На сегодня всё"
  end
  return ""
end

function render()
  local nowMs = noctalia.nowMs()
  local targetMs = targetTimestamp(nowMs)
  local events = noctalia.calendarEvents()
  local body = {}

  if events == nil then
    table.insert(body, ui.column({ gap = 8, paddingV = 18, align = "center" }, {
      ui.glyph({ name = "cloud-off", size = 28, color = "error" }),
      ui.label({ text = "Календарь ещё не синхронизирован", fontWeight = "bold", textAlign = "center" }),
      ui.label({
        text = "Проверьте подключение в Noctalia → Calendar",
        color = "on_surface_variant",
        maxWidth = 310,
        maxLines = 2,
        textAlign = "center",
      }),
    }))
  else
    local calendarNames = noctalia.getConfig("calendar_names") or {}
    local selected = model.selectEvents(events, dayKey(targetMs), calendarNames, dayKey)
    local summary = summaryText(selected, nowMs)
    if summary ~= "" then
      table.insert(body, ui.label({ text = summary, fontSize = 12, color = "primary", fontWeight = "bold" }))
    end
    if #selected == 0 then
      table.insert(body, ui.column({ gap = 8, paddingV = 22, align = "center" }, {
        ui.glyph({ name = "calendar-smile", size = 30, color = "primary" }),
        ui.label({
          text = dayOffset == 0 and "Сегодня пар нет" or "Завтра пар нет",
          fontWeight = "bold",
          fontSize = 15,
        }),
      }))
    else
      for _, event in ipairs(selected) do
        table.insert(body, eventCard(event, nowMs))
      end
    end
  end

  local children = {
    ui.row({ align = "center", gap = 8 }, {
      ui.column({ gap = 2, flexGrow = 1 }, {
        ui.label({
          text = noctalia.formatTime("{:%A, %d %B}", targetMs / 1000),
          fontSize = 18,
          fontWeight = "bold",
          color = "on_surface",
          maxWidth = 210,
          maxLines = 1,
        }),
        ui.label({ text = "Университет", fontSize = 12, color = "on_surface_variant" }),
      }),
      ui.row({ gap = 2, align = "center" }, {
        ui.button({
          glyph = "calendar-event",
          glyphSize = 15,
          variant = dayOffset == 0 and "secondary" or "ghost",
          controlSize = "sm",
          tooltip = "Сегодня",
          onClick = function()
            dayOffset = 0
            render()
          end,
        }),
        ui.button({
          glyph = "calendar-plus",
          glyphSize = 15,
          variant = dayOffset == 1 and "secondary" or "ghost",
          controlSize = "sm",
          tooltip = "Завтра",
          onClick = function()
            dayOffset = 1
            render()
          end,
        }),
      }),
    }),
    ui.separator({ color = "outline_variant", spacing = 2 }),
  }
  for _, node in ipairs(body) do
    table.insert(children, node)
  end
  desktopWidget.render(ui.column({ width = width, gap = 9 }, children))
end

function update()
  render()
end

function onConfigChanged()
  render()
end

noctalia.setUpdateInterval(1000)
render()
