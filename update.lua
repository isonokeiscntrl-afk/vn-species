-- VN Species Updater v0.1

local BASE_URL =
    "https://raw.githubusercontent.com/isonokeiscntrl-afk/vn-species/main/"

local files = {
    "vn.lua"
    "navigation.lua",
    "fuel.lua"
}

print("=== VN Species Updater ===")

for _, name in ipairs(files) do
    print("Updating " .. name .. "...")

    local response = http.get(BASE_URL .. name)

    if not response then
        print("ERROR: Could not download " .. name)
        return
    end

    local data = response.readAll()
    response.close()

    -- Download first, replace only after success
    local temp = name .. ".new"

    local file = fs.open(temp, "w")
    file.write(data)
    file.close()

    if fs.exists(name) then
        fs.delete(name)
    end

    fs.move(temp, name)

    print("OK: " .. name)
end

print("")
print("Update complete!")
print("Run: vn")
