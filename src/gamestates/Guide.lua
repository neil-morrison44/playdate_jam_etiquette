----------------------
-- Guide Gamestate --
----------------------
local Guide = {}
local GuideS = {x = 0, y = 0}
local tween = require("../lib/tween")
local centerX, centerY
local labelTween
local ruleHeight = 100
local rulePadding = 10
local treeLevelHeight = ruleHeight + 20
local portraitSize = (ruleHeight - rulePadding) - 10

function Guide:enter(from, mode)
    self.page = 0
    self.translate = {x = 0, y = 0}
    -- labelTween = tween.new(5, GuideOffset, {y = -30}, "inoutEase")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0
    local font = love.graphics.setNewFont(22)

    self.rulesPageHeight = ruleHeight + (#Rules.activeRules * ruleHeight) + 10

    self.treePageHeight = 3 * treeLevelHeight
    self.characterPortraits = {}

    self.pageHeights = {
        ruleHeight + (#Rules.activeRules * ruleHeight) + 10,
        Hierarchy.levels * treeLevelHeight
    }

    for index, who in ipairs(Hierarchy.tree) do
        self.characterPortraits[who] = self:generatePortrait(who)
    end

    if (from == GameOver) then
        self.mode = "gameover"
    else
        self.mode = "normal"
    end
end

function Guide:update(dt)
    self.duration = self.duration + dt
    if (self.activeTween) then self.activeTween:update(dt) end

    -- can't see a better way to see if the tween's finished
    if (self.translate.x % 400 == 0) then self.activeTween = nil end

end

function Guide:generatePortrait(who)
    local width = portraitSize
    local height = width
    local canvas = love.graphics.newCanvas(width, height)

    love.graphics.push()
    love.graphics.setCanvas(canvas)

    love.graphics.clear()
    love.graphics.setColor(0, 0, 0, 1)

    Game:renderCharacter(who.characterNumber, who.hatNumber, width / 2,
                         (height / 2.5), true)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", 1, 1, width - 2, height - 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas()
    love.graphics.pop()

    return canvas
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
        love.graphics.rectangle("fill", 20, 40, 360, self.rulesPageHeight)

        love.graphics.setColor(0, 0, 0, 1)

        local font = love.graphics.setNewFont(20)
        love.graphics.printf("There are " .. #Rules.activeRules ..
                                 " active rules", 20, 40 + 10, 360, "center")

        for index, rule in ipairs(Rules.activeRules) do
            -- print(rule)
            self:renderRule(rule, index, (index * ruleHeight))
        end

        -- page 2

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 400 + 20, 40, 360, self.treePageHeight)

        self:renderTreeNode(Hierarchy.tree[1], 400 + 20, 40 + 10, 360)

        love.graphics.pop()

    end)
end

function Guide:renderTreeNode(who, x, y, width)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.characterPortraits[who],
                       (x + (width / 2)) - (portraitSize / 2), y)

    if (#who.underlings == 2) then
        love.graphics.setColor(0, 0, 0, 1)

        local linesHeight = treeLevelHeight - portraitSize

        love.graphics.line(x + (width / 2), y + portraitSize, x + (width / 2),
                           (y + portraitSize) + (linesHeight / 2))

        love.graphics.line(x + (width * 0.25),
                           (y + portraitSize) + (linesHeight / 2),
                           x + (width * 0.75),
                           (y + portraitSize) + (linesHeight / 2))

        love.graphics.line(x + (width * 0.25),
                           (y + portraitSize) + (linesHeight / 2),
                           x + (width * 0.25),
                           (y + portraitSize) + (linesHeight))

        love.graphics.line(x + (width * 0.75),
                           (y + portraitSize) + (linesHeight / 2),
                           x + (width * 0.75),
                           (y + portraitSize) + (linesHeight))

        Guide:renderTreeNode(who.underlings[1], x, y + treeLevelHeight,
                             width / 2)
        Guide:renderTreeNode(who.underlings[2], x + (width / 2),
                             y + treeLevelHeight, width / 2)
    end
end

function Guide:renderRule(rule, index, y)
    love.graphics.push()
    love.graphics.setColor(0, 0, 0, 1)
    local ruleText = rule.label
    if (rule.toString) then ruleText = rule:toString(rule) end

    love.graphics.rectangle("line", 25, y, 350, ruleHeight - rulePadding)

    love.graphics.printf(ruleText, 30, y + rulePadding, (350 - ruleHeight),
                         "left")

    if (rule.values and rule.values.who) then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.characterPortraits[rule.values.who],
                           ((350 + 25) - ruleHeight) + 10, y + 5)
    end

    if (self.mode == "gameover" and Rules.ruleLog[rule]) then
        local points = Rules.ruleLog[rule]
        love.graphics.printf("(" .. math.floor(points) .. " points)", 30,
                             y + (ruleHeight - rulePadding - 30),
                             (350 - ruleHeight), "right")
    end

    love.graphics.pop()
end

function Guide:transitionToPage()
    self.activeTween = tween.new(0.5, self.translate,
                                 {y = 0, x = self.page * 400}, "inOutQuad")

end

function Guide:mousepressed(_, _, button)
    if (self.mode == "gameover") then
        Gamestate.push(Title)
        return
    end
    if (self.activeTween) then return end
    if (button == 1) then
        if (self.page ~= 1) then
            self.page = 1
            self:transitionToPage()
        else
            Gamestate.pop()
        end
    end

    if (button == 2) then
        if (self.page == 0) then
            Gamestate.pop()
        else
            self.page = 0
            self:transitionToPage()
        end

    end
end

function Guide:wheelmoved(x, y)
    if (self.activeTween) then return end
    self.translate.y = self.translate.y - (y * 2)
    if (self.translate.y < 0) then self.translate.y = 0 end

    local maxHeight = self.pageHeights[self.page + 1] - centerY

    if (self.translate.y > maxHeight) then self.translate.y = maxHeight end
end

return Guide
