local SceneBuilder = require 'core.scenebuilder'

local w, h = love.graphics.getDimensions()
love.graphics.scale(4)

local S = SceneBuilder()

S:addObjectAs('player', {
    script = 'entity.player',
    arguments = {
        x = w/2,
        y = h - 14,
        speed = 15,
    }
})

return S
