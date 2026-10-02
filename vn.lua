-- VN-0001 v0.2
-- Navigation + persistent memory + return home

local VERSION = "VN-0001 v0.2"

local MIN_X = 0
local MAX_X = 7
local MIN_Z = 0
local MAX_Z = 7

local HOME_X = 7
local HOME_Z = 0

local STATE_FILE = "vn_state"

local state = {
    x = 7,
    z = 0,
    facing = 2
}

-- Directions:
-- 0 = north
-- 1 = east
-- 2 = south
-- 3 = west

local names = {
    [0] = "NORTH",
    [1] = "EAST",
    [2] = "SOUTH",
    [3] = "WEST"
}

local function log(msg)
    print("[VN] " .. msg)
end

local function saveState()
    local file = fs.open(STATE_FILE, "w")

    file.writeLine(state.x)
    file.writeLine(state.z)
    file.writeLine(state.facing)

    file.close()
end

local function loadState()
    if not fs.exists(STATE_FILE) then
        log("No memory found.")
        log("Creating initial memory.")
        saveState()
        return
    end

    local file = fs.open(STATE_FILE, "r")

    state.x = tonumber(file.readLine())
    state.z = tonumber(file.readLine())
    state.facing = tonumber(file.readLine())

    file.close()

    log("Memory loaded.")
end

local function printPosition()
    log(
        "Position X=" ..
        state.x ..
        " Z=" ..
        state.z ..
        " Facing=" ..
        names[state.facing]
    )
end

local function turnLeft()
    turtle.turnLeft()

    state.facing = (state.facing + 3) % 4
    saveState()
end

local function turnRight()
    turtle.turnRight()

    state.facing = (state.facing + 1) % 4
    saveState()
end

local function targetPosition()
    local x = state.x
    local z = state.z

    if state.facing == 0 then
        z = z - 1
    elseif state.facing == 1 then
        x = x + 1
    elseif state.facing == 2 then
        z = z + 1
    elseif state.facing == 3 then
        x = x - 1
    end

    return x, z
end

local function forward()
    local nx, nz = targetPosition()

    -- NEVER leave our 8x8 test area
    if nx < MIN_X or nx > MAX_X
    or nz < MIN_Z or nz > MAX_Z then

        log("BOUNDARY!")
        log("Movement refused.")
        return false
    end

    if turtle.getFuelLevel() == 0 then
        log("NO FUEL!")
        return false
    end

    local success, reason = turtle.forward()

    if success then
        state.x = nx
        state.z = nz

        saveState()
        printPosition()

        return true
    end

    log("Movement blocked.")

    if reason then
        log(reason)
    end

    return false
end

local function face(direction)

    while state.facing ~= direction do

        local difference =
            (direction - state.facing) % 4

        if difference == 3 then
            turnLeft()
        else
            turnRight()
        end

    end
end

local function goHome()

    log("RETURN HOME")

    -- First correct X
    while state.x ~= HOME_X do

        if state.x < HOME_X then
            face(1) -- east
        else
            face(3) -- west
        end

        if not forward() then
            log("Cannot reach HOME.")
            return false
        end

    end

    -- Then correct Z
    while state.z ~= HOME_Z do

        if state.z < HOME_Z then
            face(2) -- south
        else
            face(0) -- north
        end

        if not forward() then
            log("Cannot reach HOME.")
            return false
        end

    end

    -- Original orientation
    face(2)

    log("HOME reached.")
    printPosition()

    return true
end


-- ========================
-- BOOT
-- ========================

print("")
print("=== " .. VERSION .. " ===")

loadState()
printPosition()

log("Beginning navigation test.")

-- Test route:
-- Start 7,0 facing SOUTH
--
-- move 3 south
-- turn west
-- move 3 west

face(2)

for i = 1, 3 do
    if not forward() then
        break
    end
end

face(3)

for i = 1, 3 do
    if not forward() then
        break
    end
end

log("Exploration test finished.")

printPosition()

sleep(2)

goHome()

log("TEST COMPLETE")
