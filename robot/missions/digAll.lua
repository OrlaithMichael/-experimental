--following class/missionInterface

local mission = {}

local class = require ("class/singleton")
obj = class.new()
local robot = require("robot")


function mission.barrier(direction)

    if (direction == "up")
        then
        return mission.barrierGateUp()
        elseif (direction == "down")
        return mission.barrierGateDown()
        elseif (direction == "straight")
        return mission.barrierGateStraight()
    end
end

function mission.barrierGateUp()

    local pos = obj.pC.getRelativePosition()
    pos.y = pos.y + 1


    if (robot.durability() ~= nil and obj.pC.isWorkingZone(pos))
        then
        robot.swingUp()
        robot.up()
        else
        return true
        end
end

function mission.barrierGateDown()
    local pos = obj.pC.getRelativePosition()
    pos.y = pos.y - 1

    if (robot.durability() ~= nil and obj.pC.isWorkingZone(pos))
        then
        robot.swingDown()
        robot.down()
        else
        return true
        end
end

function mission.barrierGateStraight()
    local pos = obj.pC.getRelativePosition()
    pos = mission.posAcToFacing(pos)

    if (robot.durability() ~= nil and obj.pC.isWorkingZone(pos))
        then
        robot.swing()
        robot.forward()
        else
        return true
        end
end

function mission.posAcToFacing(pos)
    local facing = robot.getFacing()

    if (facing == 2)
        then
        pos.z = pos.z - 1
        return pos
        elseif(facing == 3)
        pos.z = pos.z + 1
        return pos
        elseif (facing == 4)
        pos.x = pos.x - 1
        return pos
        elseif (facing == 5)
        pos.x = pos.x + 1
        return pos
    end
    print("unbelivable error! unreal facing!")
end



return mission