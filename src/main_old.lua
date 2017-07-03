-- main.lua

local class = require 'lib.class'
local lume = require 'lib.lume'

love.graphics.setDefaultFilter('nearest', 'nearest')
love.graphics.setBackgroundColor(lume.color('rgb(228, 243, 242)', 256))

-- constants
local w, h = love.graphics.getDimensions()
local _p = 4  -- pixels
w = w / _p
h = h / _p

---------------
-- Utilities --
---------------

----- loads a sprite sheet.
-- You can either pass the frameWidth and frameHeight (the sprite sheet will
-- then be automatically cut into whole numbers of frameWidth and frameHeight)
-- or a table containing frame shapes as {x=x, y=y, w=w, h=h} for each frame.
--
-- Usage:
-- image, frames = loadSpriteSheet(filename, frameWidth, frameHeight)
-- image, frames = loadSpriteSheet(filename, frameShapes)
local function loadSpriteSheet(file, fwidth, fheight)
    local image = love.graphics.newImage(file)
    local iw, ih = image:getDimensions()
    local frames = {}
    if fwidth and fheight then
        assert(type(fwidth) == 'number', 'fwidth must be a number')
        assert(type(fheight) == 'number', 'fheight must be a number')
        -- auto-cut with constant width and height
        local nx = math.floor(iw / fwidth)
        local ny = math.floor(ih / fheight)
        for i = 0, nx - 1 do for j = 0, ny - 1 do
            lume.push(frames, love.graphics.newQuad(i * fwidth, j * fheight, fwidth, fheight, iw, ih))
        end end
    else
        -- assume {x=x, y=y, w=w, h=h} tables are given
        for _, frame in ipairs(fwidth) do
            lume.push(frames, love.graphics.newQuad(
                frame.x, frame.y, frame.w, frame.h, iw, ih))
        end
    end
    return image, frames
end

local function loadImage(file)
    return love.graphics.newImage(file)
end

--- Timer(period)
-- A timer that triggers itself periodically
-- @tparam number period in seconds
local Timer = class(function(self, period)
    self.time = 0
    self.period = period
end)

--- Timer:tick(dt) updates the timer
-- to be called at every frame
-- @return true once every _period_ seconds, false otherwise
function Timer:tick(dt)
    self.time = self.time + dt
    if self.time > self.period then
        self.time = 0
        return true
    end
end


local WalkAnimator = class(function(self, walkDistance, file, fwidth, fheight)
    self.image, self.frames = loadSpriteSheet(file, fwidth, fheight)
    self.timer = Timer(walkDistance)  -- a 'distance timer'
    self.current = 1
end)

function WalkAnimator:update(dx)
    if self.timer:tick(dx) then
        self.current = self.current + 1
        if self.current > #self.frames then self.current = 1 end
    end
end

function WalkAnimator:draw(x, y)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.image, self.frames[self.current], x, y)
end


-----------
-- State --
-----------

local IdleState = class(function(self, object)
    self.object = object
    self.drawables = {
        left = loadImage('assets/img/player_left.png'),
        right = loadImage('assets/img/player_right.png'),
    }
end)

function IdleState:nextState()
    local right = love.keyboard.isDown('right')
    local left = love.keyboard.isDown('left')
    if (right or left) and not (right and left) then return 'walk'
    else return 'idle' end
end

function IdleState:update()
end

function IdleState:draw()
    love.graphics.draw(
        self.drawables[self.object.face], self.object.x, self.object.y
    )
end


local WalkState = class(function(self, object)
    self.object = object
    self.drawables = {
        left = WalkAnimator(2, 'assets/sprite/player_left_walk.png', 12, 14),
        right = WalkAnimator(2, 'assets/sprite/player_right_walk.png', 12, 14),
    }
    self.facing = {left=-1, right=1}
end)

function WalkState:nextState()
    local right = love.keyboard.isDown('right')
    local left = love.keyboard.isDown('left')
    if (right or left) and not (right and left) then return 'walk'
    else return 'idle' end
end

function WalkState:update(dt)
    local dx = self.object.speed * dt
    self.object:move(self.facing[self.object.face] * dx, 0)
    self.drawables[self.object.face]:update(dx)
end

function WalkState:draw()
    self.drawables[self.object.face]:draw(self.object.x, self.object.y)
end


------------
-- Player --
------------

local player = {}
-- set initial state
player.x = w/2
player.y = h - 14 - 4*_p
player.speed = 15
player.states = {idle = IdleState(player), walk = WalkState(player)}
player.state = 'idle'
player.face = 'right'

function player:move(dx, dy)
    self.x = self.x + dx or 0
    self.y = self.y + dy or 0
end

function player:update(dt)
    -- update face
    local right = love.keyboard.isDown('right')
    local left = love.keyboard.isDown('left')
    if right and not left then self.face = 'right' end
    if left and not right then self.face = 'left' end
    -- update state
    self.state = self.states[self.state]:nextState()
    self.states[self.state]:update(dt)
    self.x = lume.clamp(self.x, 0, w - 12)
end

function player:draw()
    self.states[self.state]:draw()
end


-- background

local background = loadImage('assets/img/background.png')


---------------
-- Main loop --
---------------

local objects = {}

function love.load()
    lume.push(objects, player)
end

function love.update(dt)
    lume.each(objects, 'update', dt)
end



function love.draw()
    love.graphics.push()
    love.graphics.scale(_p)
    love.graphics.draw(background, 0, 0)
    lume.each(objects, 'draw')
    love.graphics.pop()
end


function love.keypressed(key)
    for _, object in ipairs(objects) do
        if object.keypressed then object:keypressed(key) end
    end
end
