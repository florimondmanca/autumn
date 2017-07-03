local gamestate = require 'lib.gamestate'

require 'core.soundmanager'
math.randomseed(os.time())

-- increase pixel size
love.graphics.scale(4)

function love.load()
    gamestate.registerEvents()
    gamestate.switch(require('scenes/main'):build())
end
