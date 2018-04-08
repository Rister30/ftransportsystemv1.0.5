AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include('shared.lua')

util.AddNetworkString("FHS:Player:OpenMenu")

function ENT:Initialize()

	self:SetModel( FTS.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
end 

function ENT:AcceptInput( Name, Activator, Caller )	
	if Name == "Use" && IsValid( Caller ) && Caller:IsPlayer() then
		if Caller:GetPos():DistToSqr(self:GetPos())<200 then
			if (!self.nextUse or CurTime() >= self.nextUse) then
				if file.Read( "ftransportsystem/admin/taxivariables.txt", "DATA") == FTransportSystem.Language[FTS_BaseLang].Value1 then 
					net.Start( "FHS:Player:OpenMenu" )
						net.WriteEntity( self )
					net.Send( Caller )
					self.nextUse = CurTime() + 1	
				else
					DarkRP.notify(Caller, 1, 5, FTransportSystem.Language[FTS_BaseLang].DisabledNotify) 
				end 
			end
		end
	end 
end
