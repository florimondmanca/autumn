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
    self.time = 0
    self.handler = timer:every(t.period, function()
        self.current = self.current + 1
        if self.current > #self.frames then self.current = 1 end
    end)
end

function Animator:stop()
    timer:cancel(self.handler)
end

function Animator:resume()
    timer:addAction(self.handler)
end

function Animator:draw()
    local o = self:getObject()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.image, self.frames[self.current], o.x, o.y)
end

return Animator
