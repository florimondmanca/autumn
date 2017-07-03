local Entity = require 'core.entity'

local StaticImage = Entity:extend()

function StaticImage:init(t)
    if type(t.filename) == 'string' then
        self.image = love.graphics.newImage(t.filename)
    else
        self.image = t.image or error('StaticImage requires love.graphics.Image image or string filename')
    end
    self.x = t.x or 0
    self.y = t.y or 0
end

function StaticImage:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

return StaticImage
