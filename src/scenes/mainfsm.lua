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

-- define the player's rendering state machine
do
    local player_idle_left_image = require('components.staticimage'){
        filename = 'assets/img/player_left.png',
        getObject = function() return S.scene.objects.player end,
    }
    local player_idle_right_image = require('components.staticimage'){
        filename = 'assets/img/player_right.png',
        getObject = function() return S.scene.objects.player end,
    }

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

    S:addObjectAs('player_fsm', {
        script = 'components.statemachine2',
        arguments = {
            getObject = function() return S.scene.objects.player end,
            mockup = {
                initial = 'idle',
                events = {
                    walk_left = {
                        from = 'idle', to = 'walking_left',
                        trigger = function()
                            return love.keyboard.isDown('left')
                        end
                    },
                    walk_right = {
                        from = 'idle', to = 'walking_right',
                        trigger = function()
                            return love.keyboard.isDown('right')
                        end
                    },
                    rest_left = {
                        from = 'walking_left', to = 'idle',
                        trigger = function()
                            return not love.keyboard.isDown('left')
                        end
                    },
                    rest_right = {
                        from = 'walking_right', to = 'idle',
                        trigger = function()
                            return not love.keyboard.isDown('right')
                        end
                    },
                },
                callbacks = {
                    on_after_startup = function(self)
                        S.scene.objects.player.draw = function(self)
                            player_idle_left_image:draw()
                        end
                    end,
                    on_after_walk_left = function(self)
                        player_walkanimation_left:start()
                        S.scene.objects.player.draw = function(self)
                            player_walkanimation_left:draw()
                        end
                        S.scene.objects.player.update = function(self, dt)
                            self.x = self.x - self.speed * dt
                        end
                    end,
                    on_leave_walking_left = function(self)
                        player_walkanimation_left:stop()
                        S.scene.objects.player.draw = function(self)
                            player_idle_left_image:draw()
                        end
                        S.scene.objects.player.update = function() end
                    end,
                    on_after_walk_right = function(self)
                        player_walkanimation_right:start()
                        S.scene.objects.player.draw = function(self)
                            player_walkanimation_right:draw()
                        end
                        S.scene.objects.player.update = function(self, dt)
                            self.x = self.x + self.speed * dt
                        end
                    end,
                    on_leave_walking_right = function(self)
                        player_walkanimation_right:stop()
                        S.scene.objects.player.draw = function(self)
                            player_idle_right_image:draw()
                        end
                        S.scene.objects.player.update = function() end
                    end,
                }
            },
        }
    })
end

S:addDrawTransformation(function() love.graphics.scale(4) end)

S:addCallback('enter', function(self)
    love.graphics.setBackgroundColor(lume.color('rgb(228, 243, 242)', 256))
end)

return S
