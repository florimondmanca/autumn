local Entity = require 'core.entity'
local utils = require 'utils'

local Player = Entity:extend()

local init = Player.init
function Player:init(t)
    init(self, t)
    utils.assertHas(t, 'Player', {
        x = 'number',
        y = 'number',
        speed = 'number',
    })
    self.image = love.graphics.newImage('assets/img/player_left.png')
end

function Player:draw()
    -- love.graphics.draw(self.image, self.x, self.y)
end

return Player
