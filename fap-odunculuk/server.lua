ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('balta', function(source)
	TriggerClientEvent('fap-odun:eleaxe', source)
end)


RegisterServerEvent('fap-odun:giveodun')
AddEventHandler('fap-odun:giveodun', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	local xItem = xPlayer.getInventoryItem("wood")

	xPlayer.addInventoryItem("wood", 2)

	TriggerClientEvent('okokNotify:Alert', source ,"Ağaç Yıktın", "+2 Odun", 3000, "info")
end)

RegisterServerEvent('fap-odun:givePara')
AddEventHandler('fap-odun:givePara', function(odunmik, mik)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	local itemQuantity = xPlayer.getInventoryItem('wood').count

	if itemQuantity < odunmik then
		TriggerClientEvent('wiro_notify:show', source, "error", "Malesef Odun Miktarın Yeterli Değil.", 3000)
	else
		xPlayer.removeInventoryItem("wood", odunmik)
		xPlayer.addMoney(mik)
	end
end)

RegisterServerEvent('fap-odun:arac')
AddEventHandler('fap-odun:arac', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if Config.aracfiyat < xPlayer.getMoney() then
		xPlayer.removeMoney(Config.aracfiyat)
		TriggerClientEvent('fap-odun:AracOlustur', _source)
	else
		TriggerClientEvent('wiro_notify:show', _source, "error", "Yeterli Paranız yok", 4000)
	end
end)

RegisterServerEvent('fap-odun:paraver')
AddEventHandler('fap-odun:paraver', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	xPlayer.addMoney(Config.aracfiyat)
end)