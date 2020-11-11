----------------------
-- Game Gamestate --
----------------------
local Game = {}
local state = nil
local tween = require("lib/tween")
local GamePodFlight = love.graphics.newImage("assets/img/game_pod_flight.png")
local GamePodLanding = love.graphics.newImage("assets/img/game_pod_landing.png")
local GamePodLanded = love.graphics.newImage("assets/img/game_pod_landed.png")
local PodImages = {GamePodFlight, GamePodLanding, GamePodLanded}

local PlayerCharacterImage = love.graphics.newImage(
                                 "assets/img/characters/player.png")

local centerX, centerY
local podTween
local sceneTween

local landingTime = 5
local panningTime = 2
local floorHeight = (240 - 28)

local levelLength = 1200
local levelMinX = -160
local startingY = -120

function Game:enter()
    state = {
        x = 0,
        y = startingY,
        image = 1,
        podY = startingY - 100,
        playerX = 0
    }
    podTween = tween.new(landingTime, state, {podY = -10, image = 3},
                         "outBounce")
    sceneTween = tween.new(panningTime, state, {y = 0}, "linear")
    centerX, centerY = love.graphics.getWidth() / 2,
                       love.graphics.getHeight() / 2

    self.duration = 0
    -- local font = love.graphics.setNewFont(12)
    self.playerHasMovedThisFrame = false
    self.showActionWheel = false
    self.screenshot = nil

    self.backgroundImage = Game:generateBackground()
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

    if (self.duration > landingTime) then
        if (love.keyboard.isDown("a")) then
            state.playerX = state.playerX - 1
            self.playerHasMovedThisFrame = true
        end
        if (love.keyboard.isDown("d")) then
            state.playerX = state.playerX + 1
            self.playerHasMovedThisFrame = true
        end

        if (state.playerX < levelMinX) then state.playerX = levelMinX end
        if (state.playerX > levelLength) then state.playerX = levelLength end
    end

    if (self.showActionWheel) then
        love.graphics.captureScreenshot(function(imageData)
            self.screenshot = imageData
            Gamestate.push(ActionWheel, {
                "war", "peace", "love", "negotiate", "surrender", "Dance",
                "Play"
            })
            self.showActionWheel = false
        end)
    end
end

function Game:renderCharacter(character, hat, x, y) end

function Game:draw()
    MoonshineChain.draw(function()
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, 400, 240)

        love.graphics.push()

        love.graphics.translate(-math.floor(state.playerX / 2),
                                -math.floor(state.y))

        love.graphics.draw(self.backgroundImage, levelMinX / 2, -120)

        love.graphics.pop()

        love.graphics.push()

        love.graphics
            .translate(-math.floor(state.playerX), -math.floor(state.y))

        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(2)

        love.graphics.line(levelMinX, floorHeight, levelLength + 400,
                           floorHeight)
        love.graphics.line(-1, 0, -1, floorHeight)
        love.graphics.line(levelLength, 0, levelLength, floorHeight)

        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(PodImages[math.floor(state.image)], 0,
                           math.floor(state.podY))

        if (self.duration > landingTime) then
            local characterY = 0
            if (self.playerHasMovedThisFrame and (math.random() > 0.5)) then
                characterY = -2
            end
            love.graphics.draw(PlayerCharacterImage, state.playerX, characterY)
        end

        love.graphics.pop()

        love.graphics.push()
        love.graphics.translate(0, -math.floor(state.y))

        -- UI
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Hello", 20, floorHeight + 4)
        --
        love.graphics.pop()

    end)
end

function Game:keypressed(key)
    if (key == "space") then self.showActionWheel = true end
end

function Game:resume(_, choice) print(choice) end

-- function Game:mousepressed(_, _, button)
--     if (button == 1) then Gamestate.switch(Menu) end
-- end

return Game
