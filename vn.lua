-- VN-0001
-- Species Core v0.3

local nav = require("navigation")
local fuel = require("fuel")

print("")
print("======================")
print("   VN SPECIES v0.3")
print("======================")

nav.load()
nav.position()

fuel.status(nav.state, nav.HOME)

print("")
print("[VN] Survival systems online.")

local required =
    fuel.requiredToReturn(
        nav.state,
        nav.HOME
    )

if not fuel.tryRefuel(required) then

    print("[VN] WARNING: Insufficient fuel.")

    if nav.state.x ~= nav.HOME.x
    or nav.state.z ~= nav.HOME.z then

        print("[VN] Attempting emergency return.")
        nav.home()

    else
        print("[VN] Already HOME.")
        print("[VN] Waiting for fuel.")
    end

    return
end

print("[VN] Energy safe.")

-- Controlled expedition test

print("")
print("[VN] Starting expedition.")

nav.face(2)

for i = 1, 5 do

    -- Before EVERY movement:
    -- ensure home + reserve remains possible.

    local needed =
        fuel.requiredToReturn(
            nav.state,
            nav.HOME
        ) + 1

    if not fuel.tryRefuel(needed) then

        print("[VN] ENERGY LIMIT.")
        break
    end

    if not nav.forward() then
        break
    end

    nav.position()
    fuel.status(nav.state, nav.HOME)
end

print("")
print("[VN] Expedition finished.")

nav.home()

fuel.status(nav.state, nav.HOME)

print("[VN] Survival cycle complete.")
