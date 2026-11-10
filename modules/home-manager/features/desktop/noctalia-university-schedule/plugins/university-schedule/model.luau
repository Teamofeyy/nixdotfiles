local model = {}

local function contains(values, wanted)
  for _, value in ipairs(values) do
    if value == wanted then
      return true
    end
  end
  return false
end

function model.selectEvents(events, targetDay, calendarNames, dayKey)
  local selected = {}
  for _, event in ipairs(events) do
    local calendarMatches = #calendarNames == 0 or contains(calendarNames, event.calendarName)
    if calendarMatches and not event.allDay and dayKey(event.startMs) == targetDay then
      table.insert(selected, event)
    end
  end
  table.sort(selected, function(left, right)
    if left.startMs == right.startMs then
      return left.title < right.title
    end
    return left.startMs < right.startMs
  end)
  return selected
end

function model.state(event, nowMs)
  if nowMs >= event.endMs then
    return "done"
  elseif nowMs >= event.startMs then
    return "current"
  end
  return "upcoming"
end

function model.progress(event, nowMs)
  local duration = event.endMs - event.startMs
  if duration <= 0 then
    return 0
  end
  return math.max(0, math.min(1, (nowMs - event.startMs) / duration))
end

function model.nextEvent(events, nowMs)
  for _, event in ipairs(events) do
    if event.startMs > nowMs then
      return event
    end
  end
  return nil
end

function model.durationText(milliseconds)
  local minutes = math.max(0, math.ceil(milliseconds / 60000))
  if minutes < 60 then
    return string.format("%d мин", minutes)
  end
  local hours = math.floor(minutes / 60)
  local rest = minutes % 60
  if rest == 0 then
    return string.format("%d ч", hours)
  end
  return string.format("%d ч %d мин", hours, rest)
end

function model.isHttpUrl(url)
  return type(url) == "string" and string.match(url, "^https?://") ~= nil
end

return model
