local lume = require 'lib.lume'

local Component = require 'core.component'

local StateMachine = Component:extend()

local switchTo = function(self, nextState, onEnterData)
    self.current = self.states[nextState] or self.current
    if type(onEnterData) == 'table' then
        for name, value in pairs(onEnterData) do
            self.current.data[name] = value
        end
    end
end

local init = StateMachine.init
function StateMachine:init(t)
    init(self, t)
    assert(type(t.states) == 'table', 'StateMachine requires table states')
    -- validate the states table
    for name, stateTable in pairs(t.states) do
        name = tostring(name)
        assert(type(stateTable.transitions) == 'table', 'state ' .. name .. ' has not transitions table')
        for tname, transitionTable in pairs(stateTable.transitions) do
            tname = tostring(tname)
            assert(type(transitionTable.on) == 'function',
            'transition ' .. name .. '.' .. tname .. ' has no function on')
            assert(type(transitionTable.action) == 'function',
            'transition ' .. name .. '.' .. tname .. ' has no function action')
        end
    end
    assert(t.states[t.initial], 'initial state ' .. tostring(t.initial) .. 'does not exist')
    self.states = t.states
    self.current = self.states[t.initial]
end

function StateMachine:update(dt)
    if self.current.update then self.current:update(self:getObject(), dt) end

    for _, transition in pairs(self.current.transitions) do
        if transition.on(dt) then transition.action(lume.fn(switchTo, self)) end
    end
end

function StateMachine:draw()
    if self.current.draw then self.current:draw(self:getObject()) end
end

return StateMachine
