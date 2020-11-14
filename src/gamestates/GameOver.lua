----------------------
-- GameOver Gamestate --
----------------------
local GameOver = {}
local loseBackgroundImage = love.graphics.newImage(
                                "assets/img/gameover_lose.png")
local winBackgroundImage = love.graphics.newImage("assets/img/gameover_win.png")
local centerX, centerY

function GameOver:enter()
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0
    local font = love.graphics.setNewFont(16)
end

function GameOver:update(dt) self.duration = self.duration + dt end

function GameOver:draw()
    MoonshineChain.draw(function()
        if (Rules.score <= 0) then
            love.graphics.draw(loseBackgroundImage, 0, 0)
        else
            love.graphics.draw(winBackgroundImage, 0, 0)
        end
        if ((self.duration > 2)) then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("Press anything to see why", 0, 0, 400,
                                 "center")
        end
    end)
end

function GameOver:keypressed(key) if key then Gamestate.switch(Guide) end end

function GameOver:mousepressed(_, _, button)
    if (button == 1 or button == 2) then Gamestate.switch(Guide) end
end

return GameOver
