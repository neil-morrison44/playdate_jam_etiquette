----------------------
-- Guide Gamestate --
----------------------
local Guide = {}
local GuideS = {x = 0, y = 0}
local tween = require("../lib/tween")
local centerX, centerY
local labelTween

function Guide:enter()
    self.page = 0
    self.translate = {x = 0, y = 0}
    -- labelTween = tween.new(5, GuideOffset, {y = -30}, "inoutEase")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0
    local font = love.graphics.setNewFont(22)
end

function Guide:update(dt)
    self.duration = self.duration + dt
    if (self.activeTween) then self.activeTween:update(dt) end

    -- can't see a better way to see if the tween's finished
    if (self.translate.x % 400 == 0) then self.activeTween = nil end

end

function Guide:draw()
    MoonshineChain.draw(function()
        love.graphics
            .printf("Etiquette Guide", centerX - 120, 10, 240, "center")
        love.graphics.push()

        love.graphics.translate(-math.floor(self.translate.x),
                                -math.floor(self.translate.y))

        -- page 1

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 20, 40, 360, 200)

        love.graphics.setColor(0, 0, 0, 1)

        local font = love.graphics.setNewFont(20)
        love.graphics.printf("There are " .. #Rules.activeRules ..
                                 " active rules", 20, 40 + 10, 360, "center")

        love.graphics.pop()

    end)
end

function Guide:transitionToPage()
    self.activeTween = tween.new(0.5, self.translate,
                                 {y = 0, x = self.page * 400}, "inOutQuad")

end

function Guide:mousepressed(_, _, button)
    if (button == 1) then
        if (self.page ~= 1) then
            self.page = 1
            self:transitionToPage()
        end
    end

    if (button == 2) then
        if (self.activeTween) then return end
        if (self.page == 0) then
            Gamestate.pop()
        else
            self.page = 0
            self:transitionToPage()
        end

    end
end

function Guide:wheelmoved(x, y)
    self.translate.y = self.translate.y + y
    if (self.translate.y < 0) then self.translate.y = 0 end
end

return Guide
