local lume = require 'lib.lume'

local utils = {}

----- asserts that a table has certain arguments
-- Parameters:
-- table t: the arguments table
-- string objectName: name of the object (used for error printing only)
-- table args: table listing the type of each argument, as {arg=argType}
function utils.assertHas(t, objectName, args)
    local missing = {}
    for argName, argType in pairs(args) do
        if type(t[argName]) ~=  argType then
            table.insert(missing, argType .. ' ' .. argName)
        end
    end
    if #missing > 0 then
        error(objectName .. ' requires ' .. table.concat(missing, ', '))
    end
end

----- loads a sprite sheet.
-- You can either pass the frameWidth and frameHeight (the sprite sheet will
-- then be automatically cut into whole numbers of frameWidth and frameHeight)
-- or a table containing frame shapes as {x=x, y=y, w=w, h=h} for each frame.
--
-- Usage:
-- image, frames = loadSpriteSheet(filename, frameWidth, frameHeight)
-- image, frames = loadSpriteSheet(filename, frameShapes)
function utils.loadSpriteSheet(file, fwidth, fheight)
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

return utils
