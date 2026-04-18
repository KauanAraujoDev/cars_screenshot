local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64Decode(data)
    data = data:gsub("[^" .. b64chars .. "=]", "")
    local result = {}
    local i = 1

    while i <= #data do
        local c1 = b64chars:find(data:sub(i, i), 1, true) - 1
        local c2 = b64chars:find(data:sub(i + 1, i + 1), 1, true) - 1
        local c3c = data:sub(i + 2, i + 2)
        local c4c = data:sub(i + 3, i + 3)
        local c3 = c3c == "=" and 0 or (b64chars:find(c3c, 1, true) - 1)
        local c4 = c4c == "=" and 0 or (b64chars:find(c4c, 1, true) - 1)

        result[#result + 1] = string.char((c1 << 2) | (c2 >> 4))
        if c3c ~= "=" then result[#result + 1] = string.char(((c2 & 0xF) << 4) | (c3 >> 2)) end
        if c4c ~= "=" then result[#result + 1] = string.char(((c3 & 0x3) << 6) | c4) end

        i = i + 4
    end

    return table.concat(result)
end

local function getBase64Payload(dataUri)
    if type(dataUri) ~= "string" then
        return nil
    end

    return dataUri:match("^data:image/[%w%+%-%.]+;base64,(.+)$") or dataUri
end


RegisterNetEvent("cars_screenshot:saveImage", function(modelName)
    local src = source

    exports['screenshot-basic']:requestClientScreenshot(src, { encoding = "png" }, function(err, data)
        if err then
            print("[cars_screenshot] Erro ao capturar " .. modelName .. ": " .. tostring(err))
            return
        end

        local base64Data = getBase64Payload(data)

        if not base64Data or base64Data == "" then
            print("[cars_screenshot] Erro ao capturar " .. modelName .. ": resposta vazia do screenshot-basic")
            return
        end

        local binary = base64Decode(base64Data)
        local fileName = CONFIG.FOLDER.."/" .. modelName .. ".png"
        SaveResourceFile(GetCurrentResourceName(), fileName, binary, #binary)
        print("[cars_screenshot] Salvo: " .. fileName)
    end)
end)