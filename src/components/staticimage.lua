local Component = require 'core.component'

local StaticImage = Component:extend()

local init = StaticImage.init
function StaticImage:init(t)
    init(self, t)
    if type(t.filename) == 'string' then
        self.image = love.graphics.newImage(t.filename)
    else
        self.image = t.image or error('StaticImage requires love.graphics.Image image or string filename')
    end
end

function StaticImage:draw()
    love.graphics.draw(self.image, self:getObject().x, self:getObject().y)
end

return StaticImage
