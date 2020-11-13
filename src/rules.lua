local Topics = require("Topics")

local Rules = {}

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end
    return false
end

local BASE_RULES = {
    {
        label = "Talk To Underlings First",
        penalty = -5,
        reward = 15,
        checkOn = "talk",
        incompatableWith = {1, 2},
        check = function(rule, who, topic, time)
            if (#who.underlings == 0) then return rule.reward end
            if (who.underlings[1].state.hasBeenTalkedTo and
                who.underlings[2].state.hasBeenTalkedTo) then
                return rule.reward
            else
                return rule.penalty
            end
        end
    }, {
        label = "Talk To Boss First",
        penalty = -15,
        reward = 10,
        checkOn = "talk",
        incompatableWith = {1, 2},
        check = function(rule, who, topic, time)
            if (who.bossNode == nil) then return rule.reward end
            if (who.bossNode.state.hasBeenTalkedTo) then
                return rule.reward
            else
                return rule.penalty
            end
        end
    }, {
        label = "Don't mention X to anyone",
        penalty = -10,
        reward = 0,
        checkOn = "talk",
        init = function()
            return {topic = Topics[math.random(1, #Topics)]}
        end,
        toString = function(rule)
            return "Don't mention " .. rule.values.topic .. " to anyone"
        end,
        check = function(rule, who, topic, time)
            if (topic == rule.values.topic) then return rule.penalty end
            return 0
        end
    }, {
        label = "Don't mention X to someone",
        penalty = -15,
        reward = 0,
        checkOn = "talk",
        init = function()
            return {
                topic = Topics[math.random(1, #Topics)],
                who = Hierarchy:getRandomCharacter()
            }
        end,
        toString = function(rule)
            return "Don't mention " .. rule.values.topic .. " to:"
        end,
        check = function(rule, who, topic, time)
            if (who == rule.values.who and topic == rule.values.topic) then
                return rule.penalty
            end
            return 0
        end
    }, {
        label = "Wear the same hat",
        penalty = -5,
        reward = 10,
        checkOn = "approach",
        incompatableWith = {5, 6, 7},
        check = function(rule, who, myHat)
            if (who.hatNumber == myHat) then
                return rule.reward
            else
                return rule.penalty
            end
        end
    }, {
        label = "Wear a different hat",
        penalty = -15,
        reward = 10,
        checkOn = "approach",
        incompatableWith = {5, 6, 7},
        check = function(rule, who, myHat)
            if (myHat ~= 0 and who.hatNumber ~= myHat) then
                return rule.reward
            else
                return rule.penalty
            end
        end
    }, {
        label = "Wear their bosses's hat",
        penalty = -15,
        reward = 20,
        checkOn = "approach",
        incompatableWith = {5, 6, 7},
        check = function(rule, who, myHat)
            if (who.bossNode == nil) then return 0 end
            if (who.bossNode.hatNumber == myHat) then
                return rule.reward
            else
                return rule.penalty
            end
        end
    }, {
        label = "Within the first 30 seconds talk to this guy ->",
        penalty = -5,
        reward = 10,
        checkOn = "talk",
        incompatableWith = {8},
        init = function() return {who = Hierarchy:getRandomCharacter()} end,
        check = function(rule, who, topic, time)
            if (who.state.hasBeenTalkedTo) then return 0 end
            if (time > 30 and who == rule.values.who) then
                return rule.penalty
            else
                if (who == rule.values.who) then
                    return rule.reward
                end
            end
            return 0
        end
    }, {
        label = "Don't repeat yourself",
        penalty = -5,
        reward = 5,
        checkOn = "talk",
        incompatableWith = {9},
        init = function() return {topicsDiscussed = {}} end,
        check = function(rule, who, topic, time)
            if (not rule.values.topicsDiscussed[who]) then
                rule.values.topicsDiscussed[who] = {}
            end
            if (has_value(rule.values.topicsDiscussed[who], topic)) then
                return rule.penalty
            else
                table.insert(rule.values.topicsDiscussed[who], topic)
                return rule.reward
            end
            return 0
        end
    }
}

local MODES = {
    {
        name = "Easy",
        rules = 4,
        startingHappiness = 50,
        maxHappiness = 100,
        lossPerSecond = 0.1
    }, {
        name = "Medium",
        rules = 6,
        startingHappiness = 25,
        maxHappiness = 50,
        lossPerSecond = 0.2
    }, {
        name = "Hard",
        rules = 12,
        ruleBookChecks = 2,
        ruleBookPenalty = 1,
        startingHappiness = 15,
        maxHappiness = 25,
        lossPerSecond = 0.3
    }
}

local function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end
    return false
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

    -- score
    self.score = MODES[mode].startingHappiness
    self.maxHappiness = MODES[mode].maxHappiness
    self.lossPerSecond = MODES[mode].lossPerSecond
    self.ruleLog = {}
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

function Rules:checkApproach(who, myHat)
    for _, rule in ipairs(self.activeRules) do
        if (rule.checkOn == "approach") then
            local adjustment = rule.check(rule, who, myHat)
            if (not self.ruleLog[rule]) then self.ruleLog[rule] = 0 end
            if (self.score + adjustment > self.maxHappiness) then
                adjustment = self.maxHappiness - self.score
            end
            self.ruleLog[rule] = self.ruleLog[rule] + adjustment
            self.score = self.score + adjustment
        end
    end
end

function Rules:checkTalk(who, topic, time)
    for _, rule in ipairs(self.activeRules) do
        if (rule.checkOn == "talk") then
            local adjustment = rule.check(rule, who, topic, time)
            if (not self.ruleLog[rule]) then self.ruleLog[rule] = 0 end
            if (self.score + adjustment > self.maxHappiness) then
                adjustment = self.maxHappiness - self.score
            end
            self.ruleLog[rule] = self.ruleLog[rule] + adjustment
            self.score = self.score + adjustment
        end
    end
end

function Rules:update(dt) self.score = self.score - (dt * self.lossPerSecond) end

return Rules
