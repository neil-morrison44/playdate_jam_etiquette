----------------------
-- Menu Gamestate --
----------------------
local Menu = {}
local centerX, centerY
local titleBackgroundImage

local options = {
    {label = "Prologue", gamestate = Prologue},
    {label = "Play (Easy)", gamestate = nil},
    {label = "Play (Medium)", gamestate = nil},
    {label = "Play (Hard)", gamestate = nil},
    {label = "Return To Title", gamestate = Title}
}

function Menu:enter()
    titleBackgroundImage = love.graphics.newImage(
                               "assets/img/title_background.png")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2
    self.duration = 0
    self.selectedOption = 1
end

function Menu:update(dt) self.duration = self.duration + dt end

function Menu:draw()
    MoonshineChain.draw(function()
        love.graphics.draw(titleBackgroundImage, 0, 0)
        love.graphics.setNewFont(20)
        love.graphics.print("Main Menu", centerX / 4, 20)
        love.graphics.setNewFont(18)
        for i, option in ipairs(options) do
            local y = 30 + (i * 30)
            local x = centerX / 4
            if (self.selectedOption == i) then
                if (math.floor(self.duration * 3) % 2 == 0) then
                    love.graphics.circle("fill", x, y + 10, 5)
                end
                x = x + 12
            end
            love.graphics.print(option.label, x, y)
        end
    end)
end

function Menu:changeSelectedOption(change)
    self.selectedOption = self.selectedOption + change

    local lastIndex = table.getn(options)
    if (self.selectedOption == 0) then self.selectedOption = lastIndex end
    if (self.selectedOption > lastIndex) then self.selectedOption = 1 end
end

function Menu:keypressed(key)
    if (key == "s" or key == "down") then self:changeSelectedOption(1) end
    if (key == "w" or key == "up") then self:changeSelectedOption(-1) end

    if (key == "space") then Menu:selectGameState() end
end

function Menu:selectGameState()
    local nextGameState = options[self.selectedOption].gamestate
    print(nextGameState)
    print(options[self.selectedOption].label)
    if (nextGameState ~= nil) then Gamestate.switch(nextGameState) end
end

function Menu:mousepressed(x, y, button)
    print(button)
    if (button == 1) then Menu:selectGameState() end
end

function Menu:wheelmoved(x, y)
    if (y > 0) then self:changeSelectedOption(1) end
    if (y < 0) then self:changeSelectedOption(-1) end
end

return Menu
