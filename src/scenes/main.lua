local lume = require 'lib.lume'
local utils = require 'utils'
local SceneBuilder = require 'core.scenebuilder'

local w, h = love.graphics.getDimensions()

local S = SceneBuilder()

S:addObject{
    script = 'entity.staticimage',
    arguments = {z = -100, filename = 'assets/img/background.png'}
}

S:addObjectAs('player', {
    script = 'entity.player',
    arguments = {
        x = w/8,
        y = 0,
        speed = 15,
    }
})

local player_walkanimation_left
do
    local image, frames = utils.loadSpriteSheet('assets/sprite/player_left_walk.png', 12, 14)
    player_walkanimation_left = require('components.animator'){
        image = image,
        frames = frames,
        period = .1,
        getObject = function() return S.scene.objects.player end,
    }
end

local player_walkanimation_right
do
    local image, frames = utils.loadSpriteSheet('assets/sprite/player_right_walk.png', 12, 14)
    player_walkanimation_right = require('components.animator'){
        image = image,
        frames = frames,
        period = .1,
        getObject = function() return S.scene.objects.player end,
    }
end

S:addObjectAs('player_statemachine', {
    script = 'components.statemachine',
    arguments = {
        getObject = function() return S.scene.objects.player end,
        initial = 'idle',
        states = {
            idle = {
                data = {
                    images = {
                        left =  love.graphics.newImage(
                            'assets/img/player_left.png'),
                        right = love.graphics.newImage(
                            'assets/img/player_right.png'),
                    },
                    side = 'right',
                },
                draw = function(self, object)
                    love.graphics.draw(self.data.images[self.data.side], object.x, object.y)
                end,
                transitions = {
                    to_walk_left = {
                        on = function() return love.keyboard.isDown('left') end,
                        action = function(switchTo)
                            player_walkanimation_left:start()
                            switchTo 'walk_left'
                        end
                    },
                    to_walk_right = {
                        on = function() return love.keyboard.isDown('right') end,
                        action = function(switchTo)
                            player_walkanimation_right:start()
                            switchTo 'walk_right'
                        end
                    },
                }
            },

            walk_left = {
                data = {},
                update = function(self, object, dt)
                    object.x = object.x - object.speed * dt
                end,
                draw = function(self) player_walkanimation_left:draw() end,
                transitions = {
                    to_idle = {
                        on = function() return not love.keyboard.isDown('left') end,
                        action = function(switchTo)
                            player_walkanimation_left:stop()
                            switchTo('idle', {side='left'})
                        end
                    },
                },
            },

            walk_right = {
                data = {},
                update = function(self, object, dt)
                    object.x = object.x + object.speed * dt
                end,
                draw = function(self) player_walkanimation_right:draw() end,
                transitions = {
                    to_idle = {
                        on = function() return not love.keyboard.isDown('right') end,
                        action = function(switchTo)
                            player_walkanimation_right:stop()
                            switchTo('idle', {side='right'})
                        end
                    },
                },
            },
        },
    }
})

S:addDrawTransformation(function() love.graphics.scale(4) end)

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(lume.color('rgb(228, 243, 242)', 256))
end)

return S
