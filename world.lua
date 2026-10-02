-- VN Species - World Model v0.4

local world = {}

world.FILE = "vn_world"

local function key(x, y, z)
    return x .. "," .. y .. "," .. z
end

local function load()
    local map = {}

    if not fs.exists(world.FILE) then
        return map
    end

    local f = fs.open(world.FILE, "r")

    while true do
        local line = f.readLine()
        if not line then break end

        local x, y, z, name =
            line:match("([^,]+),([^,]+),([^,]+),(.+)")

        if x then
            map[key(
                tonumber(x),
                tonumber(y),
                tonumber(z)
            )] = name
        end
    end

    f.close()
    return map
end

world.map = load()

local function saveBlock(x, y, z, name)
    local k = key(x, y, z)

    if world.map[k] == name then
        return
    end

    world.map[k] = name

    local f = fs.open(world.FILE, "a")
    f.writeLine(
        x .. "," ..
        y .. "," ..
        z .. "," ..
        name
    )
    f.close()
end

local function classify(name)
    if name:find("coal") then
        return "FUEL"
    elseif name:find("iron") then
        return "IRON"
    elseif name:find("redstone") then
        return "REDSTONE"
    elseif name:find("diamond") then
        return "DIAMOND"
    elseif name:find("copper") then
        return "COPPER"
    elseif name:find("gold") then
        return "GOLD"
    elseif name:find("ore") then
        return "ORE"
    end

    return nil
end

function world.record(x, y, z, data)
    saveBlock(x, y, z, data.name)

    local resource = classify(data.name)

    if resource then
        print(
            "[WORLD] " ..
            resource ..
            " @ " ..
            x .. "," ..
            y .. "," ..
            z
        )
    end
end

function world.scan(nav)
    local s = nav.state

    -- block underneath
    local ok, data = turtle.inspectDown()

    if ok then
        world.record(s.x, -1, s.z, data)
    end

    -- block above
    ok, data = turtle.inspectUp()

    if ok then
        world.record(s.x, 1, s.z, data)
    end

    -- block in front
    ok, data = turtle.inspect()

    if ok then
        local x = s.x
        local z = s.z

        if s.facing == 0 then
            z = z - 1
        elseif s.facing == 1 then
            x = x + 1
        elseif s.facing == 2 then
            z = z + 1
        else
            x = x - 1
        end

        world.record(x, 0, z, data)
    end
end

function world.report()
    print("")
    print("=== WORLD KNOWLEDGE ===")

    local resources = 0

    for position, name in pairs(world.map) do
        local type = classify(name)

        if type then
            print(
                type ..
                " " ..
                position ..
                " " ..
                name
            )

            resources = resources + 1
        end
    end

    print("Resources known: " .. resources)
    print("=======================")
end

return world
