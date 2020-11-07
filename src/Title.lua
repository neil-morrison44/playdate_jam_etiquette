----------------------
-- Title Gamestate --
----------------------
local Title = {}
local titleOffset = {x = 0, y = 0}
local tween = require("lib/tween")
local titleTextImage = love.graphics.newImage("assets/img/title_text.png")
local titleBackgroundImage = love.graphics.newImage(
                                 "assets/img/title_background.png")
local centerX, centerY
local labelTween

function Title:enter()
    titleOffset.y = -220
    labelTween = tween.new(5, titleOffset, {y = -30}, "outBounce")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0
    love.graphics.setNewFont(12)
end

function Title:update(dt)
    self.duration = self.duration + dt
    labelTween:update(dt)
end

function Title:draw()
    love.graphics.draw(titleBackgroundImage, 0, 0)
    love.graphics.draw(titleTextImage, 0, math.floor(titleOffset.y))
    if ((self.duration > 3) and (math.floor(self.duration) % 2 == 0)) then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics
            .rectangle("fill", centerX - 32, (centerY * 2) - 20, 90, 18)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Press Anything", centerX - 32, (centerY * 2) - 20)
    end
end

function Title:keypressed(key) if key then Gamestate.switch(Menu) end end

function Title:mousepressed(_, _, button)
    if (button == 1) then Gamestate.switch(Menu) end
end

return Title
