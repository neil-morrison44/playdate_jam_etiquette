----------------------
-- Game Gamestate --
----------------------
local Game = {}
local tween = require("../lib/tween")
local characters = require("./Characters")
local Topics = require("Topics")
local GamePodFlight = love.graphics.newImage("assets/img/game_pod_flight.png")
local GamePodLanding = love.graphics.newImage("assets/img/game_pod_landing.png")
local GamePodLanded = love.graphics.newImage("assets/img/game_pod_landed.png")
local PodImages = {GamePodFlight, GamePodLanding, GamePodLanded}

local centerX, centerY
local podTween
local sceneTween

local landingTime = 5
local panningTime = 2
local floorHeight = (240 - 28)

local levelLength = 1400
local levelMinX = -160
local startingY = -120
local startingPlayerX = 200

local hatsImage, hatQuads = require("Hats")()

local function shuffle(x)
    local shuffled = {}
    for i, v in ipairs(x) do
        local pos = math.random(1, #shuffled + 1)
        table.insert(shuffled, pos, v)
    end
    return shuffled
end

local function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end
    return false
end

function Game:enter()
    self.state = {
        x = 0,
        y = startingY,
        image = 1,
        podY = startingY - 100,
        playerX = startingPlayerX,
        playerY = floorHeight,
        characterPositions = {},
        nearestCharacter = nil,
        uiMessage = nil,
        uiMessageTimestamp = 0,
        timeLeft = 45
    }
    podTween = tween.new(landingTime, self.state, {podY = -10, image = 3},
                         "outBounce")
    sceneTween = tween.new(panningTime, self.state, {y = 0}, "linear")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0

    self.playerHasMovedThisFrame = false
    self.showActionWheel = false
    self.screenshot = nil

    self.backgroundImage = Game:generateBackground()
    self.actionWheelOptions = {}
    self.playerHat = 0

    -- position characters
    local characterXStart = centerX * 2.25
    for index, who in ipairs(shuffle(Hierarchy.tree)) do
        self.state.characterPositions[who] =
            {
                x = characterXStart +
                    (((levelLength - characterXStart) / (#Hierarchy.tree)) *
                        (index - 1)),
                y = floorHeight + love.math.random(2, 6)
            }
    end

end

function Game:generateBackground()
    local canvas = love.graphics.newCanvas((levelLength / 2) + 400,
                                           floorHeight - startingY)
    local imageData = canvas:newImageData()

    imageData:mapPixel(function()
        if (math.random() < 0.05) then return 0, 0, 0, 1 end
        return 1, 1, 1, 1
    end)

    return love.graphics.newImage(imageData)
end

function Game:update(dt)
    self.playerHasMovedThisFrame = false
    self.duration = self.duration + dt
    podTween:update(dt)
    sceneTween:update(dt)

    if (self.state.uiMessageTimestamp < (self.duration - 5)) then
        self.state.uiMessage = nil
    end

    if (Rules.score <= 0) then
        Gamestate.push(GameOver)
        return
    else
        if (self.state.timeLeft <= 0) then
            Gamestate.push(GameOver)
            return
        end
    end

    -- things to do only after we've landed

    if (self.duration > landingTime) then
        Rules:update(dt)
        self.state.timeLeft = self.state.timeLeft - dt

        -- handle held keys

        if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
            self.state.playerX = self.state.playerX - love.math.random(1, 2)

            self.playerHasMovedThisFrame = true
        end
        if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
            self.state.playerX = self.state.playerX + love.math.random(1, 2)
            self.playerHasMovedThisFrame = true
        end

        if (self.state.playerX < levelMinX) then
            self.state.playerX = levelMinX
        end
        if (self.state.playerX > levelLength) then
            self.state.playerX = levelLength
        end
        self.state.x = self.state.playerX - startingPlayerX
    end

    -- find closest character
    self.state.previousNearestCharacter = self.state.nearestCharacter
    local smallestDistance = 50
    self.state.nearestCharacter = nil
    for index, who in ipairs(Hierarchy.tree) do
        local characterPos = self.state.characterPositions[who]
        local distanceBetween = distance(self.state.playerX, self.state.playerY,
                                         characterPos.x, characterPos.y)
        if (distanceBetween < smallestDistance) then
            smallestDistance = distanceBetween
            self.state.nearestCharacter = who
        end
    end

    if (self.state.previousNearestCharacter == nil and
        self.state.nearestCharacter ~= nil) then
        -- you've approached someone

        if (not self.state.nearestCharacter.state.hasBeenApproached) then
            print("Approached someone for the first time")
            self.state.nearestCharacter.state.hasBeenApproached = true
            Rules:checkApproach(self.state.nearestCharacter, self.playerHat)
        end
    end

    -- take screenshot then show action wheel

    if (self.showActionWheel) then
        love.graphics.captureScreenshot(function(imageData)
            self.screenshot = imageData
            Gamestate.push(ActionWheel, self.actionWheelOptions)
            self.showActionWheel = false
        end)
    end
end

function Game:renderCharacter(character, hat, x, y, centerOnHatPos)
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 1)
    local image = characters[character].image
    local xPos = math.floor(x - (image:getWidth() / 2))
    local yPos = math.floor(y - (image:getHeight()))

    if (centerOnHatPos) then
        yPos = math.floor(y - characters[character].hatPos[2])
    end

    love.graphics.draw(image, xPos, yPos)
    if (hat ~= 0) then
        local xHatPos = (xPos + characters[character].hatPos[1]) - 34
        local yHatPos = (yPos + characters[character].hatPos[2]) - 48
        love.graphics.draw(hatsImage, hatQuads[hat], xHatPos, yHatPos)
    end
    love.graphics.pop()
end

function Game:draw()
    MoonshineChain.draw(function()
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, 400, 240)

        love.graphics.push()

        love.graphics.translate(-math.floor(self.state.x / 2),
                                -math.floor(self.state.y))

        love.graphics.draw(self.backgroundImage, levelMinX / 2, -120)

        love.graphics.pop()

        love.graphics.push()

        love.graphics.translate(-math.floor(self.state.x),
                                -math.floor(self.state.y))

        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(2)

        love.graphics.line(levelMinX, floorHeight, levelLength + 400,
                           floorHeight)
        love.graphics.line(-1, 0, -1, floorHeight)
        love.graphics.line(levelLength, 0, levelLength, floorHeight)

        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(PodImages[math.floor(self.state.image)], 0,
                           math.floor(self.state.podY))

        -- render other characters

        for _, who in pairs(Hierarchy.tree) do
            Game:renderCharacter(who.characterNumber, who.hatNumber,
                                 self.state.characterPositions[who].x,
                                 self.state.characterPositions[who].y)
        end

        -- render player character

        if (self.duration > landingTime) then
            local characterY = floorHeight + 6
            if (self.playerHasMovedThisFrame and (math.random() > 0.5)) then
                characterY = characterY - 2
            end
            Game:renderCharacter(1, self.playerHat, self.state.playerX,
                                 characterY)
        end

        love.graphics.pop()

        love.graphics.push()
        love.graphics.translate(0, -math.floor(self.state.y))

        -- UI
        love.graphics.setColor(0, 0, 0)
        if (self.state.uiMessage) then
            love.graphics.printf(self.state.uiMessage, 20, floorHeight + 4, 400,
                                 "left")
        elseif (self.state.nearestCharacter ~= nil) then
            love.graphics.printf("Talk", 0, floorHeight + 4, 400, "center")
        end

        love.graphics.printf(self.state.timeLeft, 0, 0, 400, "right")

        Game:renderScore()

        --
        love.graphics.pop()

    end)
end

function Game:renderScore()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", 280, floorHeight + 4, 100, 14)

    if (Rules.score < 25 and (math.floor((self.duration * 4) % 2) == 0)) then
        return
    end
    love.graphics.rectangle("fill", 280, floorHeight + 4, Rules.score, 14)
end

function Game:mousepressed(x, y, button)
    if (self.duration < landingTime) then return end
    if (button == 1) then
        self.actionWheelOptions = {"hats", "guide"}
        if (self.state.nearestCharacter ~= nil) then
            table.insert(self.actionWheelOptions, "talk")
        end
        self.showActionWheel = true
    end
    if (button == 2) then -- do nothing
    end
end

function Game:resume(_, choice)
    if (choice == "guide") then Gamestate.push(Guide) end
    if (choice == "hats") then
        self.actionWheelOptions = {0}
        for key, value in ipairs(hatQuads) do
            table.insert(self.actionWheelOptions, value)
        end
        self.showActionWheel = true
    end
    if (choice == "talk") then
        self.actionWheelOptions = Topics
        self.showActionWheel = true
    end

    if (has_value(Topics, choice)) then
        self.state.uiMessage = "You talked about " .. choice
        self.state.uiMessageTimestamp = self.duration
        self.state.nearestCharacter.state.hasBeenTalkedTo = true
        Rules:checkTalk(self.state.nearestCharacter, choice, self.duration)
    end

    if (type(choice) == "userdata" and choice.type and choice:type() == "Quad") then
        for index, value in ipairs(hatQuads) do
            if (value == choice) then
                if (self.playerHat == 0) then
                    self.state.uiMessage = "You put on a hat"
                else
                    self.state.uiMessage = "You changed your hat"
                end
                self.playerHat = index
                self.state.uiMessageTimestamp = self.duration
            end
        end
    end
    if (choice == 0) then
        if (self.playerHat == 0) then
            self.state.uiMessage = "You decided against putting on a hat"
        else
            self.state.uiMessage = "You removed your hat"
        end
        self.playerHat = 0
        self.state.uiMessageTimestamp = self.duration
    end
end

return Game
