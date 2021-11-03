ESX				 = nil
kontrol          = 2000
kontrol2         = 2000
axe            = false
local zone       = nil
local sayac      = 60
local anliktoken = 0
local alabilir   = false
local var        = false
local vehicle    = nil
sesler = { "woodhit"}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Create Blips
Citizen.CreateThread(function()
    for k,v in pairs(Config.Blips) do
        v.blip = AddBlipForCoord(v.Location, v.Location, v.Location)
        SetBlipSprite(v.blip, v.id)
        SetBlipAsShortRange(v.blip, true)
	    BeginTextCommandSetBlipName("STRING")
        SetBlipColour(v.blip, 0)
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(v.blip)
    end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0) -- bozulursa 0 yap

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
                kontrol = 0
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 180.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            else
                kontrol = 1000
            end
		end
	end
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0) -- bozulursa 0 yap

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones2) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 85.0) then
                kontrol2 = 0
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 180.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            else
                kontrol2 = 2000
            end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(kontrol)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 3.0 then
                kontrol = 0
				isInMarker  = true
				currentZone = k
			end
		end

        for k,v in pairs(Config.Zones2) do
			if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 1.5 then
                kontrol2 = 0
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('fap-odun:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('fap-odun:hasExitedMarker', LastZone)
		end
        
	end
end)

function OpenMenu()
	local elements = {
		{label = "Araç al", value = 'aracal'},
        {label = "Odun Sat", value = 'odunsat'},
        {label = "Araç koy", value = 'arackoy'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Odunculuk', {
		title    = "Odunculuk",
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'odunsat' then
			OdunVerMenu()
		elseif data.current.value == 'aracal' then
            AracOlustur()
        elseif data.current.value == 'arackoy' then
            AracSil()
		end
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('fap-odun:eleaxe')
AddEventHandler('fap-odun:eleaxe', function()
    eleaxe()
end)

function eleaxe()
    if axe == false then
        axem = CreateObject(GetHashKey("prop_ld_fireaxe"), 0, 0, 0, true, true, true) 
        AttachEntityToEntity(axem, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, false, false, false, 1, true)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'))
        TriggerEvent('fap-odun:vuramaz')
        TriggerEvent('fap-odun:vuramaz2')
        axe = true
    else
        axe = false
        DetachEntity(axem, 1, true)
        DeleteEntity(axem)
        DeleteObject(axem)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'))
        TriggerEvent('fap-odun:vuramaz')
        TriggerEvent('fap-odun:vuramaz2')
    end
end

function AracOlustur()
    if vehicle == nil then
        TriggerServerEvent('fap-odun:arac')
    else
        TriggerEvent('wiro_notify:show', "error", "Zaten bir aracınız var")
    end
end

RegisterNetEvent('fap-odun:AracOlustur')
AddEventHandler('fap-odun:AracOlustur', function ()
    if vehicle == nil then
        local modelHash = GetHashKey("Rebel")
        RequestModel(modelHash)
        local isLoaded = HasModelLoaded(modelHash)
        while isLoaded == false do
            Citizen.Wait(100)
        end
        vehicle = CreateVehicle(modelHash, Config.AracSpawnCords, 145.50, 1, 0)
        plate = GetVehicleNumberPlateText(vehicle)
        TriggerEvent('wiro_notify:show', "success", "Aracınız oluşturuldu")
    else
        TriggerEvent('wiro_notify:show', "error", "Zaten bir aracınız var")
    end
end)

function AracSil()
    if vehicle ~= nil then
        if plate == GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true)) then
            DeleteEntity(vehicle)
            DeleteVehicle(vehicle)
            ESX.Game.DeleteVehicle(vehicle)
            vehicle = nil
            TriggerEvent('wiro_notify:show', "success", "Aracınız silindi")
            TriggerServerEvent('fap-odun:paraver')
        else
            TriggerEvent('wiro_notify:show', "inform", "İş aracınıza binip inip tekrar deneyin")
        end
    end
end

RegisterNetEvent('fap-odun:vuramaz')
AddEventHandler('fap-odun:vuramaz', function()
    Citizen.CreateThread(function()
        while axe do
            Citizen.Wait(0)
            DisablePlayerFiring(PlayerPedId(), true)
            if IsControlJustPressed(1,  346) then
                FreezeEntityPosition(PlayerPedId(), true)
                if currentBar ~= nil then
                    ESX.Streaming.RequestAnimDict("amb@world_human_hammering@male@base", function()
                        TaskPlayAnim(PlayerPedId(), "amb@world_human_hammering@male@base", "base", 1.0, -1.0, 1000, 49, 1, false, false, false)
                        EnableControlAction(0, 32, true) -- w
                        EnableControlAction(0, 34, true) -- a
                        EnableControlAction(0, 8, true) -- s
                        EnableControlAction(0, 9, true) -- d
                        EnableControlAction(0, 22, true) -- space
                        EnableControlAction(0, 36, true) -- ctrl
                        EnableControlAction(0, 21, true) -- SHIFT
                        TriggerEvent('InteractSound_CL:PlayOnOne', sesler[ math.random( #sesler ) ], 0.3)
                        Citizen.Wait(1500)
                        DisablePlayerFiring(PlayerPedId(), true)
                        FreezeEntityPosition(PlayerPedId(), false)
                        DisablePlayerFiring(PlayerPedId(), true)
                        BarEkle()
                    end)
                else
                    DisablePlayerFiring(PlayerPedId(), true)
                    FreezeEntityPosition(PlayerPedId(), false)
                    TriggerEvent('wiro_notify:show', "error", "Yakınında taş yok.", 3000)
                end
            end
        end
    end)
end)

RegisterNetEvent('fap-odun:vuramaz2')
AddEventHandler('fap-odun:vuramaz2', function()
    Citizen.CreateThread(function()
        while axe do
            Citizen.Wait(0)
            DisablePlayerFiring(PlayerPedId(), true)
        end
    end)
end)

loadModel = function(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end

function OdunVerMenu()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Odun Satma', {
		title = "Satılacak  Odun Miktarı",
	}, function (data2, menu)
		local tokenMik = tonumber(data2.value)
		if tokenMik < 0 or tokenMik == nil then
			TriggerEvent('wiro_notify:show', "error", "Bak şuan buga soktun", 3000)
		else
            TriggerServerEvent('fap-odun:givePara', tokenMik, tokenMik * Config.BirOdunFiyat)
			menu.close()
		end
	end, function (data2, menu)
		menu.close()
	end)
end

RegisterNetEvent('fap-odun:verchance')
AddEventHandler('fap-odun:verchance', function(bool)
    var = bool
end)

AddEventHandler('fap-odun:hasEnteredMarker', function(zone)
    currentBar = zone
    if (zone ~= "tokenal" and zone ~= "kayaver" and zone ~= "odunsat") then
        SetDisplay(zone, "block")
        kontrol = 0
    else
        for k,v in pairs(Config.Zones2) do
            if zone == k then
                mesajGoster(v.Message, k)
            end
		end
        kontrol2 = 0
    end
end)

AddEventHandler('fap-odun:hasExitedMarker', function(zone)
    closeAll()
    currentBar = nil
end)

RegisterNUICallback("gaya", function(data)
    if data.gaya then
        TriggerServerEvent('fap-odun:giveodun')
    end
end)

function SetDisplay(bar, bool)
    --SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = bar,
        status = bool,
    })
end

function BarEkle(zonee) 
    SendNUIMessage({
        type = "ekle",
        bar = currentBar,
    })
end

function closeAll()
    SendNUIMessage({
        type = "bar1",
        status = "none",
    })
    SendNUIMessage({
        type = "bar2",
        status = "none",
    })
    SendNUIMessage({
        type = "bar3",
        status = "none",
    })
    SendNUIMessage({
        type = "bar4",
        status = "none",
    })
    SendNUIMessage({
        type = "bar5",
        status = "none",
    })
    SendNUIMessage({
        type = "bar6",
        status = "none",
    })
end