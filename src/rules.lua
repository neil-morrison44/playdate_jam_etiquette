local Rules = {}

local BASE_RULES = {
    {
        label = "Talk To Underlings First",
        penalty = -5,
        reward = 10,
        checkOn = "talk",
        incompatableWith = {1, 2},
        check = function(rule, who, topic, time)
            -- local underlings = hierarchy:getAllBelow(who)
            -- for each underling not talked to subtract penalty
            -- if all have been talked to add reward
        end
    }, {
        label = "Talk To Betters First",
        penalty = -15,
        reward = 20,
        checkOn = "talk",
        incompatableWith = {1, 2},
        check = function(rule, who, topic, time)
            -- local betters = hierarchy:getAllAbove(who)
            -- for each better not talked to subtract penalty
            -- if all have been talked to reward with reward
        end
    }, {
        label = "Don't mention X to anyone",
        penalty = -25,
        reward = 0,
        checkOn = "talk",
        init = function()
            -- self.topic = topics:getRandomTopic
            return {topic = "war"}
        end,
        toString = function(rule)
            return "Don't mention the " .. rule.values.topic .. " to anyone"
        end,
        check = function(rule, who, topic, time)
            -- if topic === self.topic then subtract self.penalty
        end
    }, {
        label = "Don't mention X to someone",
        penalty = -35,
        reward = 0,
        checkOn = "talk",
        init = function()
            return {topic = "hello", who = Hierarchy:getRandomCharacter()}
        end,
        toString = function(rule)
            return "Don't mention the " .. rule.values.topic ..
                       " to this guy ->"
        end,
        check = function(rule, who, topic, time)
            -- if topic === self.topic && who === self.who then subtract self.penalty
        end
    }, {
        label = "Wear the same hat",
        penalty = -5,
        reward = 10,
        checkOn = "approach",
        incompatableWith = {5, 6, 7},
        check = function(rule, who, theirHat, myHat)
            -- if theirHat === myHat reward
            -- else penalty
        end
    }, {
        label = "Wear a different hat",
        penalty = -15,
        reward = 10,
        checkOn = "approach",
        incompatableWith = {5, 6, 7},
        check = function(rule, who, theirHat, myHat)
            -- if theirHat != myHat reward
            -- else penalty
        end
    }, {
        label = "Wear their bosses's hat",
        penalty = -15,
        reward = 20,
        checkOn = "approach",
        incompatableWith = {5, 6, 7},
        check = function(rule, who, theirHat, myHat)
            -- local boss = hierarchy:getDirectBoss(who)
            -- if !boss return
            -- if boss.hat == myHat reward
            -- else penalty
        end
    }, {
        label = "Talk quickly to this guy ->",
        penalty = -5,
        reward = 10,
        checkOn = "talk",
        incompatableWith = {8},
        init = function()
            -- self.who = hierarchy:getRandomPerson()
            return {who = Hierarchy:getRandomCharacter()}
        end,
        check = function(rule, who, topic, time)
            if (time > 30) then
                -- subtract penalty
            else
                -- add reward
            end
        end
    }
}

local MODES = {
    {name = "Easy", rules = 4, startingHappiness = 50, maxHappiness = 100},
    {name = "Medium", rules = 6, startingHappiness = 25, maxHappiness = 50}, {
        name = "Hard",
        rules = 16,
        ruleBookChecks = 2,
        ruleBookPenaltyPerSec = 1,
        startingHappiness = 5,
        maxHappiness = 25
    }
}

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end
    return false
end

function Rules:initNewRule(baseRule)
    local activeRule = {}
    for k, v in pairs(baseRule) do activeRule[k] = v end

    if (activeRule.init) then activeRule.values = activeRule:init() end
    -- print(dump(baseRule))
    -- print(dump(activeRule))
    return activeRule
end

function Rules:checkCompatibility(newRuleIndex)
    for index, rule in ipairs(self.activeRules) do
        if (rule.incompatableWith ~= nil and
            has_value(rule.incompatableWith, newRuleIndex)) then
            return false
        end
    end
    return true
end

function Rules:generate(mode)
    self.activeRules = {}
    while (#self.activeRules < MODES[mode].rules) do
        -- pick a rule that none of the activeRules are incompatableWith
        local ruleIndex = math.floor(love.math.random(1, #BASE_RULES))
        if (self:checkCompatibility(ruleIndex)) then
            table.insert(self.activeRules,
                         self:initNewRule(BASE_RULES[ruleIndex]))

        end
    end

    print(#self.activeRules)
end

return Rules
