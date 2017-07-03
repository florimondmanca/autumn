local fsm = require 'lib.fsm'

local Component = require 'core.component'

local StateMachine = Component:extend()

local init = StateMachine.init
function StateMachine:init(t)
    init(self, t)
    self.fsm = fsm(t.mockup)
end

function StateMachine:update()
    self.fsm:update()
end

return StateMachine
