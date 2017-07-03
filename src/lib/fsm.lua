local class = require 'lib.class'

local FiniteStateMachine = class()

local function onMatch(pattern, s, func)
    if string.match(s, '^' .. pattern .. '[_%a]+$') then
        return func(string.gsub(s, pattern, ''))
    end
end

function FiniteStateMachine:init(mockup)
    self.states = {}
    self.events = {}
    self:addState('none')
    self.current = 'none'
    self:setup(mockup)
end

function FiniteStateMachine:addState(state)
    self.states[state] = {
        name = state,
        on_enter = function() end,
        on_leave = function() end,
    }
end

function FiniteStateMachine:hasState(state)
    return self.states[state] ~= nil
end

function FiniteStateMachine:addEvent(name, from, to, trigger, on_before, on_after)
    self.events[name] = {
        name = name,
        from = from,
        to = to,
        on_before = on_before or function() end,
        on_after = on_after or function() end,
        trigger = trigger,
        call = function(event, ...)
            event.on_before(self, event.name, event.from, event.to, ...)
            event.on_after(self, event.name, event.from, event.to, ...)
            self.states[event.from].on_leave(self, event.name, event.from, event.to, ...)
            self.states[event.to].on_enter(self, event.name, event.from, event.to, ...)
            self.current = event.to
        end
    }
end

function FiniteStateMachine:setup(mockup)
    mockup = mockup or {}
    mockup.events = mockup.events or {}

    -- register states and events from the events{} table
    for eventName, eventTable in pairs(mockup.events) do
        local from, to, trigger = eventTable.from, eventTable.to, eventTable.trigger or function() end
        assert(from, 'invalid event ' .. eventName .. ': `from` state missing')
        assert(to, 'invalid event ' .. eventName .. ': `to` state missing')

        if not self:hasState(from) then self:addState(from) end
        if not self:hasState(to) then self:addState(to) end

        self:addEvent(eventName, from, to, trigger, eventTable.on_before, eventTable.on_after)
    end

    -- register callbacks from the callbacks{} table
    for callbackName, callbackFunction in pairs(mockup.callbacks or {}) do
        assert(type(callbackName) == 'string',
            'callback names can only be strings (got ' .. tostring(callbackName) .. ')')
        assert(type(callbackFunction) == 'function', 'callbacks must be functions')

        onMatch('on_before_', callbackName, function(name)
            assert(self.events[name], 'on_before: no event called ' .. name)
            self.events[name].on_before = callbackFunction
        end)
        onMatch('on_after_', callbackName, function(name)
            assert(self.events[name], 'on_after: no event called ' .. name)
            self.events[name].on_after = callbackFunction
        end)
        onMatch('on_enter_', callbackName, function(name)
            assert(self.states[name], 'on_enter: no state called ' .. name)
            self.states[name].on_enter = callbackFunction
        end)
        onMatch('on_leave_', callbackName, function(name)
            assert(self.states[name], 'on_leave: no state called ' .. name)
            self.states[name].on_leave = callbackFunction
        end)
    end
end

function FiniteStateMachine:update()
    for _, event in pairs(self.events) do
        if self.current == event.from and event.trigger() then
            self.events[event.name]:call()
            break
        end
    end
end

return FiniteStateMachine
