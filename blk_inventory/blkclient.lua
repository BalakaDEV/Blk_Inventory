local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

--[ CONEXÃO ]----------------------------------------------------------------------------------------------------------------------------

vRPNserver = Tunnel.getInterface("blk_inventory")

vRPC = {}
Tunnel.bindInterface("blk_inventory",vRPC)
Proxy.addInterface("blk_inventory",vRPC)
emP = Tunnel.getInterface("blk_inventory")

--[ VARIÁVEIS ]--------------------------------------------------------------------------------------------------------------------------

local invOpen = false
local animacao = false 

--[ STARTFOCUS ]-------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	SetNuiFocus(false,false)
end)

--[ INVCLOSE ]---------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("invClose",function(data)
	StopScreenEffect("MenuMGSelectionIn")
	SetCursorLocation(0.5,0.5)
	SetNuiFocus(false,false)
	SendNUIMessage({ action = "hideMenu" })
	invOpen = false
end)

--[ ABRIR INVENTARIO ]-------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local ped = PlayerPedId()
        if IsControlJustPressed(0,243) then
            if GetEntityHealth(ped) > 101 and not vRP.isHandcuffed() and not IsPedBeingStunned(ped) and not IsPlayerFreeAiming(ped) then
                if not invOpen then
                	StartScreenEffect("MenuMGSelectionIn", 0, true)
                    invOpen = true
                    SetNuiFocus(true,true)
                    SendNUIMessage({ action = "showMenu" })
                else
                	StopScreenEffect("MenuMGSelectionIn")
                    SetNuiFocus(false,false)
                    SendNUIMessage({ action = "hideMenu" })
                    invOpen = false
                end
            end
        end
    end
end)

--[ CLONEPLATES ]------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('cloneplates')
AddEventHandler('cloneplates',function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)
    local clonada = GetVehicleNumberPlateText(vehicle)
    if IsEntityAVehicle(vehicle) then
        PlateIndex = GetVehicleNumberPlateText(vehicle)
        SetVehicleNumberPlateText(vehicle,"CLONADA")
        FreezeEntityPosition(vehicle,false)
        if clonada == CLONADA then 
            SetVehicleNumberPlateText(vehicle,PlateIndex)
            PlateIndex = nil
        end
    end
end)
--[ VEHICLEANCHOR ]----------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('vehicleanchor')
AddEventHandler('vehicleanchor',function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)
    FreezeEntityPosition(vehicle,true)
end)

--[ DROPITEM ]---------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("droparItem",function(data)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then
        TriggerEvent("Notify","negado","Você não pode dropar itens quando estiver em um veículo.")
    else
        vRPNserver.dropItem(data.item,data.amount)
    end
end)

--[ SENDITEM ]---------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("enviarItem",function(data)
	vRPNserver.sendItem(data.item,data.amount)
end)

--[ USEITEM ]----------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("usarItem",function(data)
	vRPNserver.useItem(data.item,data.type,data.amount)
end)

--[ MOCHILA ]----------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("requestMochila",function(data,cb)
	local inventario,peso,maxpeso = vRPNserver.Mochila()
	if inventario then
		cb({ inventario = inventario, peso = peso, maxpeso = maxpeso })
	end
end)

--[ AUTO-UPDATE ]------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("vrp_inventario:Update")
AddEventHandler("vrp_inventario:Update",function(action)
	SendNUIMessage({ action = action })
end)

RegisterNetEvent("vrp_inventario:fechar")
AddEventHandler("vrp_inventario:fechar",function(action)
	StopScreenEffect("MenuMGSelectionIn")
    SetNuiFocus(false,false)
    SendNUIMessage({ action = "hideMenu" })
    invOpen = false
end)

--[ USO REMÉDIO ]------------------------------------------------------------------------------------------------------------------------

local usandoRemedios = false
RegisterNetEvent("remedios")
AddEventHandler("remedios",function()
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    local armour = GetPedArmour(ped)

    SetEntityHealth(ped,health)
    SetPedArmour(ped,armour)
    
    if GetEntityHealth(ped) < 300 then
        TriggerEvent("Notify","negado","<b>O remédio não fara feito, pois você precisa de tratamento</b>.",8000)
    else
        if usandoRemedios then
            return
        end

        usandoRemedios = true

        if usandoRemedios then
            repeat
                Citizen.Wait(600)
                if GetEntityHealth(ped) > 230 then
                    SetEntityHealth(ped,GetEntityHealth(ped)+1)
                end
            until GetEntityHealth(ped) >= 400 or GetEntityHealth(ped) <= 280
                TriggerEvent("Notify","sucesso","O medicamento acabou de fazer efeito.",8000)
                usandoRemedios = false
        end
    end
end)

--[ GMOCHILA ]---------------------------------------------------------------------------------------------------------------------------

RegisterCommand("mochila",function(source,args)
    if vRPNserver.checkMochila() then
        if args[1] == "1" then
            SetPedComponentVariation(PlayerPedId(),5,52,0,2) -- Deserto;
        elseif args[1] == "2" then
            SetPedComponentVariation(PlayerPedId(),5,52,1,2) -- Camuflada;
        elseif args[1] == "3" then
            SetPedComponentVariation(PlayerPedId(),5,52,2,2) -- Camuflada 2;
        elseif args[1] == "4" then
            SetPedComponentVariation(PlayerPedId(),5,52,3,2) -- Verde;
        elseif args[1] == "5" then
            SetPedComponentVariation(PlayerPedId(),5,52,4,2) -- Preta;
        elseif args[1] == "6" then
            SetPedComponentVariation(PlayerPedId(),5,52,5,2) -- Preta com azul;
        elseif args[1] == "7" then
            SetPedComponentVariation(PlayerPedId(),5,52,6,2) -- Preta com cinza;
        elseif args[1] == "8" then
            SetPedComponentVariation(PlayerPedId(),5,52,7,2) -- Preta com deserto;
        elseif args[1] == "9" then
            SetPedComponentVariation(PlayerPedId(),5,52,8,2) -- Preta com branco;
        elseif args[1] == "10" then
            SetPedComponentVariation(PlayerPedId(),5,52,9,2) -- Preta com preto;
        end
    end
end)

RegisterNetEvent("inventario:mochilaon")
AddEventHandler("inventario:mochilaon",function()
    SetPedComponentVariation(PlayerPedId(),5,52,4,2)
end)

RegisterNetEvent("inventario:mochilaoff")
AddEventHandler("inventario:mochilaoff",function()
    SetPedComponentVariation(PlayerPedId(),5,-1,0,2)
end)

function vRPC.checkVida()
    local ped = PlayerPedId()
    if GetEntityHealth(ped) >= 280 then
        return true
    end
    return false
end
