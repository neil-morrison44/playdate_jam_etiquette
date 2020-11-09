----------------------
-- ActionWheel Gamestate --
----------------------
local ActionWheel = {}
local ActionWheelOffset = {x = 0, y = 0}
local tween = require("lib/tween")
local centerX, centerY
local MAX_TEXT_SIZE = 60

function ActionWheel:enter(presenter, choices)
    ActionWheelOffset.y = -220
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0

    presenter.screenshot:mapPixel(function(x, y, r, g, b, a)
        if ((x + y) % 2 == 0) then return 1, 1, 1, 1 end
        return r, g, b, a
    end)
    self.backgroundImage = love.graphics.newImage(presenter.screenshot)
    self.choices = choices
    self.segmentSize = math.pi * 2 / table.getn(self.choices)
    self.gap = math.pi * 2 / 240
    self.selectedChoice = 1
    self.angle = math.deg(self.segmentSize / 2)

end

function ActionWheel:update(dt)
    self.duration = self.duration + dt

    local angleRadians = math.rad(self.angle)
    self.selectedChoice = math.floor(angleRadians / self.segmentSize) + 1
    if (self.angle == 360) then self.selectedChoice = 1 end
end

function ActionWheel:draw()
    MoonshineChain.draw(function()
        love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.backgroundImage, 0, 0)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Press Anything", centerX, centerY * 2)

        local startingAngle = (-self.segmentSize * 1.5) - (math.pi / 2)
        for i, choice in ipairs(self.choices) do
            love.graphics.setColor(0, 0, 0)
            local angle = startingAngle + (i * self.segmentSize)
            local radius = centerX / 2
            love.graphics.setLineWidth(2)
            local mode = "line"
            if (self.selectedChoice == i) then
                mode = "fill"
                radius = radius + 10
                love.graphics.setLineWidth(3)
            end
            love.graphics.arc(mode, "pie", centerX, centerY, radius,
                              angle + self.gap,
                              (angle + self.segmentSize) - self.gap, 100)

            local midAngle = (angle + (angle + self.segmentSize)) / 2
            love.graphics.setNewFont(18)

            if (mode == "fill") then love.graphics.setColor(1, 1, 1) end
            local x = (centerX + math.cos(midAngle) * (radius / 1.5)) -
                          (MAX_TEXT_SIZE / 2)
            local y = (centerY + math.sin(midAngle) * (radius / 1.5)) - 12
            love.graphics.printf(choice, math.floor(x), math.floor(y),
                                 MAX_TEXT_SIZE, "center")
        end
        love.graphics.pop()
    end)
end

-- function ActionWheel:keypressed(key) if key then Gamestate.switch(Menu) end end

function ActionWheel:mousepressed(_, _, button)
    if (button == 1) then Gamestate.pop(self.choices[self.selectedChoice]) end
end

function ActionWheel:wheelmoved(x, y)
    self.angle = self.angle - (y * 12)
    if (self.angle > 359) then self.angle = self.angle - 360 end
    if (self.angle < 1) then self.angle = self.angle + 360 end
end

return ActionWheel
