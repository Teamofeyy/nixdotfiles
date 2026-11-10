local model = require("../plugins/university-schedule/model")

local function event(id, startMs, endMs, calendarName, allDay, title)
  return {
    id = id,
    startMs = startMs,
    endMs = endMs,
    calendarName = calendarName,
    allDay = allDay,
    title = title or id,
  }
end

local day = function(milliseconds)
  return milliseconds < 86400000 and "today" or "tomorrow"
end

local events = {
  event("late", 5000, 7000, "University", false),
  event("holiday", 1000, 2000, "University", true),
  event("personal", 2000, 3000, "Personal", false),
  event("early", 1000, 4000, "University", false),
  event("repeat", 86401000, 86402000, "University", false),
}

local today = model.selectEvents(events, "today", { "University" }, day)
assert(#today == 2 and today[1].id == "early" and today[2].id == "late", "filters and sorts today's classes")
assert(#model.selectEvents(events, "missing", {}, day) == 0, "empty day")
assert(model.state(today[1], 500) == "upcoming", "upcoming state")
assert(model.state(today[1], 2000) == "current", "current state")
assert(model.state(today[1], 4000) == "done", "done state")
assert(model.progress(today[1], 2500) == 0.5, "current progress")
assert(model.nextEvent(today, 1500).id == "late", "next class")
assert(#model.selectEvents(events, "tomorrow", { "University" }, day) == 1, "expanded recurring occurrence")
assert(model.durationText(60 * 60000 + 1) == "1 ч 1 мин", "duration rounds up")
assert(model.isHttpUrl("https://meet.example/class") and not model.isHttpUrl("file:///tmp/class"), "safe meeting links")

local utcLate = { event("timezone", 23 * 60 * 60 * 1000, 24 * 60 * 60 * 1000, "University", false) }
local utcPlusThreeDay = function()
  return "tomorrow"
end
assert(#model.selectEvents(utcLate, "tomorrow", { "University" }, utcPlusThreeDay) == 1, "provider timestamps use local day")

print("university schedule model tests passed")
