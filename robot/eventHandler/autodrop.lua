return function()

local class = require("class/singleton")
obj = class.new()
local computer = require("computer")
local robot = require("robot")
local selectedSlot = robot.select()




if (obj.iC.selectEmptySlotFor(nil) == false) then

    local reserveParams = {}
    local class = require ("class/singleton")
    obj = class.new()
    local mis = obj.mission
    local dropLoot = require ("actions/dropLoot")

    reserveParams.events = obj.eC.events
    reserveParams.timers = obj.eC.timers
    obj.eC.dropAllEvents()
    obj.eC.dropAllTimers()

    obj.eC.addEvent("charging", "modem_message", "chargingmessage")


    mis.saveCondition()
        repeat
        obj.mC.moveTo(obj.pC.points.lootchest)
        until obj.pC.comparePositions(obj.pC.points.lootchest, obj.pC.getRelativePosition())

    if (dropLoot(obj.pC.points.lootchest) ~= true) then
            sender("Error! mission failed (miss the way to lootchest")
            mis.fail("drop loot")
    end

    robot.select(selectedSlot)

    mis.afterDrop()
    obj.eC.dropEvent("charging")
    obj.eC.restoreTimers(reserveParams.timers)
    obj.eC.restoreEvents(reserveParams.events)
    mis.restoreCondition()

end
robot.select(selectedSlot)

end