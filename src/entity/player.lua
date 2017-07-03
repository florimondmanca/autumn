local Entity = require 'core.entity'
local utils = require 'utils'
local fsm = require 'lib.fsm'

-- renderers

local function createRenderers(player)
    local idle_left_image = require('components.staticimage'){
        filename = 'assets/img/player_left.png',
        getObject = function() return player end,
    }
    local idle_right_image = require('components.staticimage'){
        filename = 'assets/img/player_right.png',
        getObject = function() return player end,
    }

    local walkanimation_left
    do
        local image, frames = utils.loadSpriteSheet('assets/sprite/player_left_walk.png', 12, 14)
        walkanimation_left = require('components.animator'){
            image = image,
            frames = frames,
            period = .1,
            getObject = function() return player end,
        }
    end

    local walkanimation_right
    do
        local image, frames = utils.loadSpriteSheet('assets/sprite/player_right_walk.png', 12, 14)
        walkanimation_right = require('components.animator'){
            image = image,
            frames = frames,
            period = .1,
            getObject = function() return player end,
        }
    end

    return {
        idle_left = idle_left_image,
        idle_right = idle_right_image,
        walk_left = walkanimation_left,
        walk_right = walkanimation_right,
    }
end

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

    self.renderers = createRenderers(self)

    local function setRenderer(name, setup)
        setup = setup or function() end
        local old = self.renderer
        self.renderer = self.renderers[name]
        setup(self.renderer, old)
    end

    self.updaters = {
        idle = function() end,
        walk_left = function(dt) self.x = self.x - self.speed * dt end,
        walk_right = function(dt) self.x = self.x + self.speed * dt end,
    }

    local function setUpdater(name, setup)
        setup = setup or function() end
        self.updater = self.updaters[name]
        setup(self.updater)
    end

    self.fsm = fsm{
        events = {
            startup = {
                from = 'none',
                to = 'idle',
                trigger = function() return true end,
                on_after = function()
                    setRenderer('idle_right')
                    setUpdater('idle')
                end,
            },

            walk_left = {
                from = 'idle', to = 'walking_left',
                trigger = function()
                    return love.keyboard.isDown('left')
                end,
                on_after = function()
                    setRenderer('walk_left', function(r) r:start() end)
                    setUpdater('walk_left')
                end,
            },

            walk_right = {
                from = 'idle', to = 'walking_right',
                trigger = function()
                    return love.keyboard.isDown('right')
                end,
                on_after = function()
                    setRenderer('walk_right', function(r) r:start() end)
                    setUpdater('walk_right')
                end,
            },

            rest_left = {
                from = 'walking_left', to = 'idle',
                trigger = function() return not love.keyboard.isDown('left') end
            },

            rest_right = {
                from = 'walking_right', to = 'idle',
                trigger = function() return not love.keyboard.isDown('right') end
            },
        },

        callbacks = {

            on_leave_walking_left = function(self)
                setRenderer('idle_left', function(_, old) old:stop() end)
                setUpdater('idle')
            end,

            on_leave_walking_right = function(self)
                setRenderer('idle_right', function(_, old) old:stop() end)
                setUpdater('idle')
            end,
        }
    }
end

function Player:update(dt)
    self.fsm:update(dt)
    if self.updater then self.updater(dt) end
end

function Player:draw()
    if self.renderer then self.renderer:draw() end
end

return Player
