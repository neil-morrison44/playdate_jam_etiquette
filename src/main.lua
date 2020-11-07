
-- Hump Gamestate Library --
Gamestate = require("lib/gamestate")

-- Your Gamestates --
Title = require("Title")

function love.load()
  success = love.window.setMode( 400, 240, { highdpi=false } )
  Gamestate.registerEvents()
  Gamestate.switch(Title)
end
