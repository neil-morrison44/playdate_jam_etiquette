-- Hump Gamestate Library --
Gamestate = require("lib/gamestate")

Rules = require("Rules")
Hierarchy = require("Hierarchy")

-- Your Gamestates --
Title = require("gamestates.Title")
Prologue = require("gamestates.Prologue")
Guide = require("gamestates.Guide")
GameOver = require("gamestates.GameOver")
Game = require("gamestates.Game")
ActionWheel = require("gamestates.ActionWheel")
Menu = require("gamestates.Menu")

local moonshine = require("lib/moonshine")
-- should find out how to have the font not anti-alias then use this palette
-- local palette = {{50, 47, 41}, {50, 47, 41}, {177, 174, 168}, {177, 174, 168}}
local palette = {
    {50, 47, 41}, {177, 174, 168}, {177, 174, 168}, {177, 174, 168}
}
MoonshineChain = nil

function love.load()
    local success = love.window.setMode(400, 240, {highdpi = false})
    MoonshineChain = moonshine.chain(moonshine.effects.dmg)
    MoonshineChain.parameters = {dmg = {palette = palette}}
    love.graphics.setDefaultFilter("nearest", "nearest", 1)

    Gamestate.registerEvents()
    Gamestate.switch(Title)
end
