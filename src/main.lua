local gamestate = require 'lib.gamestate'

require 'core.soundmanager'
math.randomseed(os.time())
-- nearest neigbor interpolation
love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
    gamestate.registerEvents()
    gamestate.switch(require('scenes/main'):build())
end
