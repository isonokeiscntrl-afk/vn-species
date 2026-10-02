-- Survey 8x8 in snake pattern
-- Start: (7,0), facing SOUTH

for column = 1, 8 do

    print("[VN] Survey column " .. column)

    -- Traverse current column
    for move = 1, 7 do

        world.scan(nav)

        if not energySafe(1) then
            print("[VN] Energy boundary reached.")
            nav.home()
            world.report()
            return
        end

        if not nav.forward() then
            print("[VN] Path blocked.")
            nav.home()
            world.report()
            return
        end
    end

    world.scan(nav)

    -- Last column: finished
    if column == 8 then
        break
    end

    -- Move one block WEST into next column
    if column % 2 == 1 then

        -- We are facing SOUTH
        -- SOUTH -> WEST
        nav.right()

        if not nav.forward() then
            print("[VN] Cannot enter next column.")
            nav.home()
            return
        end

        -- WEST -> NORTH
        nav.right()

    else

        -- We are facing NORTH
        -- NORTH -> WEST
        nav.left()

        if not nav.forward() then
            print("[VN] Cannot enter next column.")
            nav.home()
            return
        end

        -- WEST -> SOUTH
        nav.left()
    end
end

print("[VN] Survey complete.")

world.report()

nav.home()

print("[VN] HOME.")
print("[VN] v0.4 complete.")
