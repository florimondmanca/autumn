local lume = require 'lib.lume'
local utils = require 'utils'
local SceneBuilder = require 'core.scenebuilder'

local w, h = love.graphics.getDimensions()

local S = SceneBuilder()

S:addObjectAs('background', {
    x = 0,
    y = 0,
    z = -10,
    image = love.graphics.newImage('assets/img/background.png'),
    draw = function(self)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.image, self.x, self.y)
    end,
})

S:addObjectAs('player', {
    script = 'entity.player',
    arguments = {
        x = w/8,
        y = h/8,
        speed = 15,
    }
})

S:addDrawTransformation(function() love.graphics.scale(4) end)

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(lume.color('rgb(228, 243, 242)', 256))
end)

return S
