-- VN Species - Fuel System v0.3

local fuel = {}

fuel.SAFETY_RESERVE = 20

local function log(msg)
    print("[FUEL] " .. msg)
end

function fuel.level()
    return turtle.getFuelLevel()
end

function fuel.distanceHome(state, home)
    return math.abs(state.x - home.x)
         + math.abs(state.z - home.z)
end

function fuel.requiredToReturn(state, home)
    return fuel.distanceHome(state, home)
         + fuel.SAFETY_RESERVE
end

function fuel.tryRefuel(target)
    local level = turtle.getFuelLevel()

    if level == "unlimited" then
        return true
    end

    if level >= target then
        return true
    end

    log("Fuel low: " .. level)
    log("Target: " .. target)

    local oldSlot = turtle.getSelectedSlot()

    for slot = 1, 16 do
        turtle.select(slot)

        -- Check without consuming
        if turtle.refuel(0) then
            local item = turtle.getItemDetail()

            if item then
                log(
                    "Fuel found: "
                    .. item.name
                    .. " x"
                    .. item.count
                )
            end

            -- Consume ONE item at a time.
            -- Don't burn the entire inventory unnecessarily.
            while turtle.getFuelLevel() < target do

                if turtle.getItemCount(slot) == 0 then
                    break
                end

                if not turtle.refuel(1) then
                    break
                end
            end
        end

        if turtle.getFuelLevel() >= target then
            break
        end
    end

    turtle.select(oldSlot)

    level = turtle.getFuelLevel()

    log("Fuel now: " .. level)

    return level >= target
end

function fuel.canExplore(state, home)
    local required =
        fuel.requiredToReturn(state, home)

    return fuel.tryRefuel(required)
end

function fuel.status(state, home)
    local level = turtle.getFuelLevel()
    local distance = fuel.distanceHome(state, home)
    local required = fuel.requiredToReturn(state, home)

    print("")
    print("=== ENERGY ===")
    print("Fuel:     " .. tostring(level))
    print("Home:     " .. distance .. " moves")
    print("Reserve:  " .. fuel.SAFETY_RESERVE)
    print("Required: " .. required)
    print("==============")
end

return fuel
