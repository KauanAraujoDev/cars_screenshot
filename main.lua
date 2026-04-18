local currentIndex = 1
local currentVehicle = nil
local currentCam = nil

local function cleanup()
    if currentCam then
        SetCamActive(currentCam, false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(currentCam, false)
        currentCam = nil
    end

    if currentVehicle and DoesEntityExist(currentVehicle) then
        DeleteEntity(currentVehicle)
        currentVehicle = nil
    end
end

local function processVehicle()
    if currentIndex > #CONFIG.VEHICLE_LIST then
        print("[cars_screenshot] Processo finalizado.")
        return
    end

    local modelName = CONFIG.VEHICLE_LIST[currentIndex]
    local model = GetHashKey(modelName)

    RequestModel(model)

    local timeout = 0
    while not HasModelLoaded(model) do
        Wait(100)
        timeout = timeout + 1
        if timeout >= 50 then
            print("[cars_screenshot] Modelo nao carregou: " .. modelName)
            SetModelAsNoLongerNeeded(model)
            currentIndex = currentIndex + 1
            processVehicle()
            return
        end
    end

    local veh = CreateVehicle(model, CONFIG.SPAWN_COORDS.x, CONFIG.SPAWN_COORDS.y, CONFIG.SPAWN_COORDS.z, CONFIG.SPAWN_COORDS.w, false, false)

    local spawnTimeout = 0
    while not DoesEntityExist(veh) do
        Wait(100)
        spawnTimeout = spawnTimeout + 1
        if spawnTimeout >= 30 then
            print("[cars_screenshot] Veiculo nao spawnou: " .. modelName)
            SetModelAsNoLongerNeeded(model)
            currentIndex = currentIndex + 1
            processVehicle()
            return
        end
    end

    currentVehicle = veh

    SetEntityVisible(veh, true, false)
    SetVehicleOnGroundProperly(veh)
    FreezeEntityPosition(veh, true)
    SetModelAsNoLongerNeeded(model)

    local camPos = vector3(
        CONFIG.SPAWN_COORDS.x + CONFIG.CAM_OFFSET.x,
        CONFIG.SPAWN_COORDS.y + CONFIG.CAM_OFFSET.y,
        CONFIG.SPAWN_COORDS.z + CONFIG.CAM_OFFSET.z
    )

    currentCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(currentCam, camPos.x, camPos.y, camPos.z)
    PointCamAtEntity(currentCam, veh, 0.0, 0.0, 0.0, true)
    SetCamActive(currentCam, true)
    RenderScriptCams(true, false, 0, true, true)

    Wait(800)

    TriggerServerEvent('cars_screenshot:saveImage', modelName)

    Wait(1000)

    cleanup()
    currentIndex = currentIndex + 1
    Wait(300)
    processVehicle()
end

RegisterCommand('purple:runScreenshot', function ()
  processVehicle()
end)