-- VN Species - Navigation v0.3

local nav = {}

nav.MIN_X = 0
nav.MAX_X = 7
nav.MIN_Z = 0
nav.MAX_Z = 7

nav.HOME = {
    x = 7,
    z = 0
}

nav.STATE_FILE = "vn_state"

nav.state = {
    x = 7,
    z = 0,
    facing = 2
}

nav.names = {
    [0] = "NORTH",
    [1] = "EAST",
    [2] = "SOUTH",
    [3] = "WEST"
}

local function save()
    local f = fs.open(nav.STATE_FILE, "w")

    f.writeLine(nav.state.x)
    f.writeLine(nav.state.z)
    f.writeLine(nav.state.facing)

    f.close()
end

function nav.load()

    if not fs.exists(nav.STATE_FILE) then
        save()
        return
    end

    local f = fs.open(nav.STATE_FILE, "r")

    nav.state.x = tonumber(f.readLine())
    nav.state.z = tonumber(f.readLine())
    nav.state.facing = tonumber(f.readLine())

    f.close()
end

function nav.position()

    print(
        "[NAV] X="
        .. nav.state.x
        .. " Z="
        .. nav.state.z
        .. " Facing="
        .. nav.names[nav.state.facing]
    )
end

function nav.left()

    turtle.turnLeft()

    nav.state.facing =
        (nav.state.facing + 3) % 4

    save()
end

function nav.right()

    turtle.turnRight()

    nav.state.facing =
        (nav.state.facing + 1) % 4

    save()
end

function nav.face(direction)

    while nav.state.facing ~= direction do

        local difference =
            (direction - nav.state.facing) % 4

        if difference == 3 then
            nav.left()
        else
            nav.right()
        end
    end
end

local function target()

    local x = nav.state.x
    local z = nav.state.z

    if nav.state.facing == 0 then
        z = z - 1

    elseif nav.state.facing == 1 then
        x = x + 1

    elseif nav.state.facing == 2 then
        z = z + 1

    else
        x = x - 1
    end

    return x, z
end

function nav.forward()

    local x, z = target()

    if x < nav.MIN_X
    or x > nav.MAX_X
    or z < nav.MIN_Z
    or z > nav.MAX_Z then

        print("[NAV] Boundary reached.")
        return false
    end

    local ok, reason = turtle.forward()

    if not ok then
        print("[NAV] Blocked: " .. tostring(reason))
        return false
    end

    nav.state.x = x
    nav.state.z = z

    save()

    return true
end

function nav.home()

    print("[NAV] Returning HOME.")

    while nav.state.x ~= nav.HOME.x do

        if nav.state.x < nav.HOME.x then
            nav.face(1)
        else
            nav.face(3)
        end

        if not nav.forward() then
            return false
        end
    end

    while nav.state.z ~= nav.HOME.z do

        if nav.state.z < nav.HOME.z then
            nav.face(2)
        else
            nav.face(0)
        end

        if not nav.forward() then
            return false
        end
    end

    nav.face(2)

    print("[NAV] HOME reached.")

    return true
end

return nav
