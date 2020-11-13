local Hierarchy = {}
local Characters = require("Characters")
local hatsImage, hatQuads = require("Hats")()

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end
    return false
end

function Hierarchy:generate()
    -- one array of just character number & hat number to avoid duplicates
    self.members = {}
    self.tree = {}

    self:addToTree(0, 3, nil)
    self:printTree()
end

function Hierarchy:printTree()
    for index, character in ipairs(self.tree) do
        print("---")
        print("The character " .. character.memberKey .. "")
        if (character.bossNode) then
            print("has a boss " .. character.bossNode.memberKey .. "")
        end

        if (#character.underlings ~= 0) then
            print("has underlings " .. character.underlings[1].memberKey ..
                      " and " .. character.underlings[2].memberKey .. "")
        end
    end
end

function Hierarchy:addToTree(currentDepth, maxDepth, bossNode)
    if (currentDepth == maxDepth) then return end
    local characterNumber, hatNumber = self:pickCharacter()

    local newNode = {
        characterNumber = characterNumber,
        hatNumber = hatNumber,
        bossNode = bossNode,
        memberKey = "" .. characterNumber .. "-" .. hatNumber,
        underlings = {}
    }
    if (bossNode) then table.insert(bossNode.underlings, newNode) end
    table.insert(self.tree, newNode)

    Hierarchy:addToTree(currentDepth + 1, maxDepth, newNode)
    Hierarchy:addToTree(currentDepth + 1, maxDepth, newNode)
end

function Hierarchy:pickCharacter()
    local memberKey = nil
    local characterNumber = nil
    local hatNumber = nil

    repeat
        characterNumber = love.math.random(2, #Characters)
        hatNumber = love.math.random(1, #hatQuads)
        memberKey = "" .. characterNumber .. "-" .. hatNumber
    until (not has_value(self.members, memberKey))
    table.insert(self.members, memberKey)

    return characterNumber, hatNumber
end

return Hierarchy
