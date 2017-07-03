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
    self.x = t.x
    self.y = t.y
    self.speed = t.speed
    self.image = love.graphics.newImage('assets/img/player_left.png')
end

return Player
