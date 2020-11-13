----------------------
-- Prologue Gamestate --
----------------------
local Prologue = {}
local textOffset = {x = 0, y = 0}
local tween = require("../lib/tween")
local textTween

local prologueText = [[
    "Oops, You Started an Intergalatic War"



    You are agent Zaphloyd Gyan, a diplomat attached to the starship named << I asked you not to rob Banks >>


    You will be sent as our envoy to conduct tense political negotiations with the representives of other cultures.

    An etiquette guide will be prepared for you upon arrival.



    And Zaphloyd, try to avoid causing another intergalatic war.
]]

function Prologue:enter()
    textOffset.y = 200
    textTween = tween.new(20, textOffset, {y = -180}, "linear")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0
    love.graphics.setNewFont(14)
end

function Prologue:update(dt)
    self.duration = self.duration + dt
    textTween:update(dt)

    if (self.duration > 23) then Gamestate.switch(Menu) end
end

function Prologue:draw()
    MoonshineChain.draw(function()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(prologueText, 50, math.floor(textOffset.y), 300,
                             'center')
    end)
end

function Prologue:keypressed(key) if key then Gamestate.switch(Menu) end end

function Prologue:mousepressed(_, _, button)
    if (button == 1 or button == 1) then Gamestate.switch(Menu) end
end

return Prologue
