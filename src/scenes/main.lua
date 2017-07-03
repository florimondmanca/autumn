local lume = require 'lib.lume'
local utils = require 'utils'
local SceneBuilder = require 'core.scenebuilder'

local w, h = love.graphics.getDimensions()

local S = SceneBuilder()

S:addObject{
    script = 'entity.staticimage',
    arguments = {filename = 'assets/img/background.png'}
}

S:addObjectAs('player', {
    script = 'entity.player',
    arguments = {
        x = w/2,
        y = h - 14,
        speed = 15,
    }
})

do
    local image, frames = utils.loadSpriteSheet('assets/sprite/player_left_walk.png', 12, 14)
    S:addObjectAs('player_walkanimation_left', {
        script = 'components.animator',
        arguments = {
            image = image,
            frames = frames,
            period = .5,
            getObject = function() return S.scene.objects.player end,
        }
    })
end

do
    local image, frames = utils.loadSpriteSheet('assets/sprite/player_right_walk.png', 12, 14)
    S:addObjectAs('player_walkanimation_right', {
        script = 'components.animator',
        arguments = {
            image = image,
            frames = frames,
            period = .5,
            getObject = function() return S.scene.objects.player end,
        }
    })
end

-- S:addObjectAs('player_statemachine', {
--     script = 'components.statemachine',
--     arguments = {
--     }
-- })

S:addDrawTransformation(function() love.graphics.scale(4) end)

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(lume.color('rgb(228, 243, 242)', 256))
end)

return S
