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


    You will be sent as our Cultural representative to conduct tense political negotiations with other cultures.
    If you manage not to embarras us for 45 seconds that'll probably be enough.

    They'll slowly grow to dislike you so keep an eye on the bar in the lower right corner.

    You'll need to talk to them about different topics, but be careful not to mention anything uncouth.

    An etiquette guide will be prepared for you upon your arrival, accessable from the Action Wheel (right click).


    And Zaphloyd, try to avoid causing another intergalatic war.

    (WASD is D-Pad, Mouse Scroll is Crank, Left click is A, Right click is B)

    (Press anything to exit)
]]

local TIME_TO_FINISH = 38

function Prologue:enter()
    textOffset.y = 200
    textTween = tween.new(38, textOffset, {y = -380}, "linear")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0
    love.graphics.setNewFont(14)
end

function Prologue:update(dt)
    self.duration = self.duration + dt
    textTween:update(dt)

    -- if (self.duration > TIME_TO_FINISH + 3) then Gamestate.switch(Menu) end
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
    if (button == 1 or button == 2) then Gamestate.switch(Menu) end
end

return Prologue
