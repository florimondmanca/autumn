local utils = require 'utils'
local Component = require 'core.component'

local timer = require('core.timer').global

local Animator = Component:extend()

local init = Animator.init
function Animator:init(t)
    init(self, t)
    utils.assertHas(t, 'Animator', {
        image = 'userdata',
        frames = 'table',
        period = 'number',
    })
    self.image = t.image
    self.frames = t.frames
    self.period = t.period
    self.current = 1
    self.handler = timer:every(t.period, function()
        self.current = self.current + 1
        if self.current > #self.frames then self.current = 1 end
    end)
    timer:cancel(self.handler)
    self.stopped = true
end

function Animator:start()
    if self.stopped then
        timer:addAction(self.handler)
        self.stopped = false
    end
end

function Animator:stop()
    timer:cancel(self.handler)
    self.stopped = true
end

function Animator:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.image, self.frames[self.current], self:getObject().x, self:getObject().y)
end

return Animator
