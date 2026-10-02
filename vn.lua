-- VN-0001
-- Species Core v0.4
-- Autonomous 8x8 Survey

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
        fuel.requiredToReturn(nav.state, nav.HOME)
        + (extraMoves or 1)

    return fuel.tryRefuel(needed)
end

print("[VN] Sensors online.")
print("[VN] Beginning survey.")

-- =========================================================
-- 8x8 SNAKE SURVEY
--
-- Start:
-- X=7 Z=0 facing SOUTH
--
-- Pattern:
--
-- (0,0) ↓  ↑  ↓  ↑  ↓  ↑  ↓  ↑ (7,0)
--       ↓  ↑  ↓  ↑  ↓  ↑  ↓  ↑
--       ↓  ↑  ↓  ↑  ↓  ↑  ↓  ↑
--       ↓  ↑  ↓  ↑  ↓  ↑  ↓  ↑
--       ↓  ↑  ↓  ↑  ↓  ↑  ↓  ↑
--       ↓  ↑  ↓  ↑  ↓  ↑  ↓  ↑
--       ↓  ↑  ↓  ↑  ↓  ↑  ↓  ↑
-- (0,7) →  ←  →  ←  →  ←  →  ← (7,7)
-- =========================================================

for column = 1, 8 do

    print("")
    print("[VN] Survey column " .. column)

    -- Scan starting/current cell
    world.scan(nav)

    -- Travel seven blocks through this column
    for move = 1, 7 do

        if not energySafe(1) then
            print("[VN] ENERGY LIMIT.")
            print("[VN] Aborting survey.")

            nav.home()
            world.report()
            return
        end

        if not nav.forward() then
            print("[VN] PATH BLOCKED.")
            print("[VN] Aborting survey.")

            nav.home()
            world.report()
            return
        end

        -- Scan after entering new cell
        world.scan(nav)
    end

    -- Column 8 = entire field surveyed
    if column == 8 then
        break
    end

    -- ==========================================
    -- Shift exactly one block WEST
    -- ==========================================

    if column % 2 == 1 then

        -- Currently facing SOUTH.
        --
        -- SOUTH
        --   ↓
        -- WEST
        nav.right()

        if not energySafe(1) then
            print("[VN] ENERGY LIMIT.")
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

        -- WEST -> NORTH
        nav.right()

    else

        -- Currently facing NORTH.
        --
        -- NORTH
        --   ↓
        -- WEST
        nav.left()

        if not energySafe(1) then
            print("[VN] ENERGY LIMIT.")
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

        -- WEST -> SOUTH
        nav.left()
    end
end

print("")
print("======================")
print("[VN] SURVEY COMPLETE")
print("======================")

world.report()

print("")
print("[VN] Returning HOME.")

if nav.home() then
    print("[VN] HOME.")
else
    print("[VN] ERROR: Could not reach HOME.")
    return
end

nav.position()
fuel.status(nav.state, nav.HOME)

print("")
print("[VN] v0.4 complete.")
