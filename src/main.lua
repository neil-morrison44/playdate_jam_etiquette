-- Hump Gamestate Library --
Gamestate = require("lib/gamestate")

-- Your Gamestates --
Title = require("Title")
Prologue = require("Prologue")
Menu = require("Menu")

function love.load()
    local success = love.window.setMode(400, 240, {highdpi = false})
    Gamestate.registerEvents()
    Gamestate.switch(Title)
end
