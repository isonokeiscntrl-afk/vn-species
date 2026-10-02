-- VN-0001
-- Species Core v0.4

local nav = require("navigation")
local fuel = require("fuel")
local world = require("world")

print("")
print("======================")
print("   VN SPECIES v0.4")
print("======================")

nav.load()
nav.position()

local function energySafe(extraMoves)

    local needed =
        fuel.requiredToReturn(
            nav.state,
            nav.HOME
        ) + (extraMoves or 1)

    return fuel.tryRefuel(needed)
end

local function step()

    world.scan(nav)

    if not energySafe(1) then
        print("[VN] Energy boundary reached.")
        return false
    end

    if not nav.forward() then
        print("[VN] Path blocked.")
        return false
    end

    return true
end

print("[VN] Sensors online.")
print("[VN] Beginning survey.")

world.scan(nav)

-- Survey the 8x8 field in rows.
-- Start = 7,0 facing SOUTH.
--
-- We travel south along X=7,
-- move one cell west,
-- travel north along X=6,
-- etc.

for column = 1, 8 do

    for move = 1, 7 do
        if not step() then
            print("[VN] Survey interrupted.")
            nav.home()
            world.report()
            return
        end
    end

    world.scan(nav)

    if column < 8 then

        -- Move one column west while preserving
        -- the snake pattern.

        if nav.state.facing == 2 then
            nav.right()
            nav.right()
            nav.right()
        else
            nav.left()
        end

        if not energySafe(1) then
            print("[VN] Energy limit.")
            nav.home()
            world.report()
            return
        end

        if not nav.forward() then
            print("[VN] Cannot enter next column.")
            nav.home()
            world.report()
            return
        end

        if nav.state.facing == 3 then
            if column % 2 == 1 then
                nav.right()
            else
                nav.left()
            end
        end
    end
end

print("[VN] Survey complete.")

world.report()

nav.home()

print("[VN] HOME.")
print("[VN] v0.4 complete.")
