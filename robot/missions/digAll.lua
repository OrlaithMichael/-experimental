--following class/missionInterface

--this mission class uses positioning patterns of class internalPositioning

local mission = {}
mission.IN = require ("class/internalPositioning")
local class = require ("class/singleton")
obj = class.new()
local robot = require("robot")
local component = require("component")
mission.name = "digAll"
mission.stop = false


function mission.barrier(direction)

    if (direction == "up")
        then
        return mission.barrierGateUp()
        elseif (direction == "down") then
        return mission.barrierGateDown()
        elseif (direction == "straight") then
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
    local facing = obj.pC.getFacing()

    if (facing == 2)
        then
        pos.z = pos.z - 1
        return pos
        elseif(facing == 3) then
        pos.z = pos.z + 1
        return pos
        elseif (facing == 4) then
        pos.x = pos.x - 1
        return pos
        elseif (facing == 5) then
        pos.x = pos.x + 1
        return pos
    end
    print("unbelivable error! unreal facing!")
end

function mission.saveCondition()
    return true
end

function mission.fail(reason)
    print(reason)
    obj.eC.dropTimer("autocharge")
    obj.eC.dropTimer("autodrop")
    obj.eC.dropTimer("autoequip")
end

function mission.afterCharge()
    obj.mC.moveTo(obj.pC.points.lootchest)
    local selected = robot.select()
    local dropLoot = require("actions/dropLoot")
    dropLoot(obj.pC.points.lootchest)
    robot.select(selected)
    local durability = robot.durability()
    if durability == nil then durability = 0 end
    if (durability < 0.05) then
        obj.mC.moveTo(obj.pC.points.brokentoolchest)
        component.inventory_controller.equip()
        robot.dropDown()
        obj.mC.moveTo(obj.pC.points.toolchest)
        robot.suckDown()
        component.inventory_controller.equip()
    end



end

function mission.afterDrop()

    local durability = robot.durability()
    if durability == nil then durability = 0 end
        if (durability < 0.05) then
            obj.mC.moveTo(obj.pC.points.brokentoolchest)
            component.inventory_controller.equip()
            robot.dropDown()
            obj.mC.moveTo(obj.pC.points.toolchest)
            robot.suckDown()
            component.inventory_controller.equip()
        end

    obj.mC.moveTo(obj.pC.points.charger)
    local charge = require("actions/charge")
    charge()

end

function mission.afterEquip()
    obj.mC.moveTo(obj.pC.points.charger)
    local charge = require("actions/charge")
    charge()
end

function mission.restoreCondition()
        repeat
        obj.mC.moveTo(obj.pC.points.lastaction)
        until obj.pC.comparePositions(obj.pC.points.lastaction, obj.pC.getRelativePosition())
end

function mission.getProgress()
 local math = require ("math")
 if mission.IN.isInit == false then return "mission has not yet begun" end
 local curvol = mission.IN.getCurrentVolumeDone(obj.pC.points.lastaction)
 if curvol == false then return "wrong position, restart the mission" end
 local prog = curvol/mission.IN.getVolume()
 prog = prog * 10000
 prog = math.floor(prog)
 local strprog = tostring(prog/100).."%"
 return strprog
end

function mission.getName()
 return mission.name
end

function mission.close()

    if (obj.pC.points.lastaction ~= nil) then
        obj.pC.unset("lastaction")
    end
    mission.fail("")
    return true
end

function mission.pause()
    mission.stop = true
end

function mission.start()

    local eac = require("actions/enableAutoCharge")
    local ead = require("actions/enableAutoDrop")
    local eae = require("actions/enableAutoEquip")
    local sender = require("actions/messageSender")
    local component = require("component")

    if (eac()) then
        sender ("autocharging enabled, please dont disable it before mission ends")
        else
        sender ("Error! mission aborting...")
        return false
    end

    os.sleep(0.5)


    if (obj.pC.points.lootchest == nil) then
            sender("Error! cant find lootchest")
            sender("mission failed :(")
            mission.fail("checking systems fail")
            return false
            else
            sender("lootchest is found..")
    end

    if (obj.pC.points.brokentoolchest == nil) then
                sender("Error! cant find brokentoolchest")
                sender("mission failed :(")
                mission.fail("checking systems fail")
                return false
                else
                sender("brokentoolchest is found..")
    end

    if (obj.pC.points.toolchest == nil) then
            sender ("Error! where are the toolchest?!")
            sender ("mission ends... mb next time? :(")
            mission.fail("checking systems fail")
            return false
            else
            sender("toolchest is found..")
    end



    if (ead()) then
        sender ("autodrop loot enabled..")
        else
        sender ("Error! mission aborting...")
        mission.fail("checking systems fail")
        return false
    end

    os.sleep(0.5)

    if (eae()) then
        sender ("autoequip tool enabled...")
        else
        sender ("Error! mission aborting...")
        mission.fail("checking systems fail")
        return false
    end

    os.sleep(2)

    if (component.isAvailable("inventory_controller") == false) then
        sender("robot must have inventory controller for this mission")
        mission.fail("checking systems fail")
        return false
    end

    if (obj.pC.points.wzstart == nil or obj.pC.points.wzend == nil) then
        sender ("Error! pls set working zone!")
        sender ("Mission aborting...")
        mission.fail("checking systems fail")
        return false
    end


    obj.pC.reCalcWZ()
    sender("working zone ready, pls dont change it before mission ends!")
    os.sleep(5)

    os.sleep(1)
    sender ("init internal navigation...")
    mission.IN.init(obj.pC.points.borderfirst, obj.pC.points.bordersecond, 3, true, 1)


    if (mission.IN.positionAdjustment(obj.pC.points.lastaction) ~= false) then
          sender("calculating start position")
          obj.pC.setPositionRelative(mission.IN.positionAdjustment(obj.pC.points.lastaction), "lastaction")
          else
          sender("generating starting position")
          obj.pC.setPositionRelative(mission.IN.positionAdjustment(nil), "lastaction")

    end
    os.sleep(1)


    robot.select(1)
    os.sleep(6)

    mission.stop = false
    sender("moving to position...")



    repeat

    local posadj = mission.IN.positionAdjustment(obj.pC.points.lastaction)

        repeat
        obj.mC.moveTo(posadj)
        until obj.pC.comparePositions(posadj, obj.pC.getRelativePosition())

    local direction = mission.IN.getDirection(obj.pC.getRelativePosition())
    if (direction == "changelayer") then
        robot.swingUp()
        mission.IN.changeLayer(robot.swingDown, true) -- second argument mean "action then move", change Down to Up if upsidedown change
        direction = mission.IN.getDirection(obj.pC.getRelativePosition())
        elseif(direction == "mission ends") then
        obj.pC.setPosition(obj.pC.getPosition(), "lastaction")
        sender("mission done")
        print("mission done")
        mission.stop = true
        break
    end
    obj.mC.turnTo(direction)


    local actions = {}
    actions[1] = robot.swingDown
    actions[2] = robot.swing
    actions[3] = robot.swingUp


    if (mission.IN.positionAdjustment(obj.pC.getRelativePosition()) ~= false) then

        local dist = mission.IN.getDistToBorder(direction, obj.pC.getRelativePosition())
        if (dist > 30) then dist = 30 end


        for i=1, dist do
            mission.IN.doAction(actions)
            local asd = robot.forward()
            if asd == false then
                if mission.IN.positionAdjustment(obj.pC.getRelativePosition()) ~= false
                    then robot.swing()
                end
            end
        end

    end


    if (mission.IN.positionAdjustment(obj.pC.getRelativePosition()) ~= false) then
                obj.pC.setPositionRelative(mission.IN.positionAdjustment(obj.pC.getRelativePosition()), "lastaction")
    end

    os.sleep(0.15)



    until mission.stop == true





end



return mission