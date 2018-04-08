
--[[-------------------------------------------------------------------------
	Initialize Network
---------------------------------------------------------------------------]]

util.AddNetworkString("FTransportSystem:SwitchClient:User:Admin")
util.AddNetworkString("FTransportSystem:SwitchClient:DrawHUDPaint")
util.AddNetworkString("FTransportSystem:SwitchServer:Destination")
util.AddNetworkString("FTransportSystem:SwitchServer:AdminAction")
util.AddNetworkString("FTransportSystem:DestinationPlayer:Freeze")

--[[-------------------------------------------------------------------------
	Initialize
---------------------------------------------------------------------------]]

hook.Add( "Initialize", "FTransportSystem:Initialize:Serverside", function()
	if not file.IsDir( "ftransportsystem", "DATA" ) then
		file.CreateDir( "ftransportsystem" )
	end

	if not file.IsDir( "ftransportsystem/admin", "DATA" ) then
		file.CreateDir( "ftransportsystem/admin" )
	end
	
	if not file.Exists( "ftransportsystem/admin/taxivariables.txt", "DATA" ) then	
		file.Write( "ftransportsystem/admin/taxivariables.txt", FTransportSystem.Language[FTS_BaseLang].Value1 ) 
	end 
end)

--[[-------------------------------------------------------------------------
	Functions 
---------------------------------------------------------------------------]]

net.Receive("FTransportSystem:SwitchServer:Destination", function( len, ply )
    local v = net.ReadUInt(32)
    local self = net.ReadEntity()
	
	if self:GetModel() == FTS.Model then 
	
		if (ply:getDarkRPVar("money") > TaxiDestinations[v].Price) then 
		
			if ply:GetPos():DistToSqr(self:GetPos())<200 then
			
				if IsValid( ply ) && ply:IsPlayer() && ply:Alive() then
				
					ply:addMoney(-TaxiDestinations[v].Price)
					ply:SetPos(TaxiDestinations[v].VectorPos)
					
					DarkRP.notify(ply, 0, 5, TaxiDestinations[v].Notify .. "(" .. TaxiDestinations[v].Price .. FTS.ServerCurrency .. ")")
					
				end
				
			end
			
		end 
		
	end 
	
end )

net.Receive("FTransportSystem:SwitchServer:AdminAction", function( len, ply )
	local number_saved = net.ReadUInt( 8 ) 
	local text = net.ReadString( 32 ) 
	local author = net.ReadString( 16 )
	local fts_lang = FTransportSystem.Language[FTS_BaseLang]
	
	if IsValid( ply ) && ply:IsPlayer() && ply:Alive() then
	
		for _,v in pairs(player.GetAll()) do 
			if number_saved == 2 then 
				
				if FTS.AllowedAdmins[ ply:GetUserGroup() ] then 
					file.Write( "ftransportsystem/admin/taxivariables.txt", fts_lang.Value1 ) 
				
					DarkRP.notify(v, 2, 5, fts_lang.ActivedNotify)
				end
				
			elseif number_saved == 3 then
			
				if FTS.AllowedAdmins[ ply:GetUserGroup() ] then 
					file.Write( "ftransportsystem/admin/taxivariables.txt", fts_lang.Value2 )
				
					DarkRP.notify(v, 2, 5, fts_lang.DisabledNotify)
				end 
 				
			elseif number_saved == 4 then
				
				if FTS.AllowedAdmins[ ply:GetUserGroup() ] then
				
					net.Start("FTransportSystem:SwitchClient:DrawHUDPaint")
						net.WriteString( text )
						net.WriteString( author )
					net.Send( v )
					
				end 
				
			end 
		end 
		
	end
end )

net.Receive("FTransportSystem:DestinationPlayer:Freeze", function( len, ply )
	local admin_number = net.ReadUInt( 8 ) 
	local self = net.ReadEntity()
	
	if self:GetModel() == FTS.Model then 
	
		if ply:GetPos():DistToSqr(self:GetPos())<200 then 
		
			if ply:Alive() && IsValid( ply ) && ply:IsPlayer() then 
		
				if admin_number == 4 then
			
					ply:Freeze( true )
				
				elseif admin_number == 8 then
			
					ply:Freeze( false )
				
				end 
			
			end 
			
		end 
		
	end 
	
end )

--[[-------------------------------------------------------------------------
	Player Say 
---------------------------------------------------------------------------]]

hook.Add( "PlayerSay", "FTransportSystem:Player:Say", function( ply, text )
	if text == FTS.AdminInterfaceCommand then	
		if not FTS.AllowedAdmins[ ply:GetUserGroup() ] then return end
		
		if IsValid( ply ) && ply:IsPlayer() && ply:Alive() then 

			net.Start("FTransportSystem:SwitchClient:User:Admin")
			net.Send(ply)	
		
		end 
		
	end
end)
