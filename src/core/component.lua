local class = require 'lib.class'

local Component = class()

function Component:init(t)
    t = t or {}
    assert(type(t.getObject) == 'function', 'Component requires function getObject')
    self.getObject = function(self) return t.getObject() end
end

return Component
