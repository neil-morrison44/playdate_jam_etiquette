local hatsImage = love.graphics.newImage("assets/img/hats.png")

local hatQuads = {
    love.graphics.newQuad(60 * 0, 0, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 1, 0, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 2, 0, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 3, 0, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 4, 0, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 5, 0, 60, 60, hatsImage:getDimensions()),

    love.graphics.newQuad(60 * 0, 60, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 1, 60, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 2, 60, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 3, 60, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 4, 60, 60, 60, hatsImage:getDimensions()),
    love.graphics.newQuad(60 * 5, 60, 60, 60, hatsImage:getDimensions())
}

local function returner() return hatsImage, hatQuads end

return returner
