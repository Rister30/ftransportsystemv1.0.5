AddCSLuaFile()
surface.CreateFont( "FTransportSystem:BroadcastModule:Font340",
 {
	font = "Lato", 
	size = 20,
	weight = 0,
	blursize = 0,
} )

--[[-------------------------------------------------------------------------
	Blur Texture
---------------------------------------------------------------------------]]

local blur = Material("pp/blurscreen")
local function DrawBlur( p, a, d )
	local x, y = p:LocalToScreen( 0, 0 )
	
	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( blur )
	
	for i = 1, d do
		blur:SetFloat( "$blur", (i / d ) * ( a ) )
		blur:Recompute()
		
		render.UpdateScreenEffectTexture()
		
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end
end

--[[-------------------------------------------------------------------------
	Taxi Menu
---------------------------------------------------------------------------]]

net.Receive( "FHS:Player:OpenMenu", function()	
	local fts_lang = FTransportSystem.Language[FTS_BaseLang]
	local self = net.ReadEntity()
	
	local SimpleBaseFrame = vgui.Create("DFrame")
    SimpleBaseFrame:SetSize(ScrW() / 3.5, ScrH() / 1.5)
	SimpleBaseFrame:SetPos( ScrW() / 2.7, ScrH() * 2 ) 
	SimpleBaseFrame:MoveTo( ScrW() / 2.7, ScrH() / 5.5, 0.7, 0, 4)
	SimpleBaseFrame:SetTitle( "" )
	SimpleBaseFrame:ShowCloseButton( false )
    SimpleBaseFrame:SetDraggable( false )
	SimpleBaseFrame:MakePopup()
    SimpleBaseFrame.Paint = function( self, w, h )
		DrawBlur( self, 6, 25 )
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 47, 59, 225 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 40, Color( 27, 37, 47 ) )
		
		draw.SimpleText(fts_lang.FrameTitle, "Trebuchet18", w / 2, h / 30, Color(255,255,255,255), 1, 1)
    end
	
	local Avatar = vgui.Create( "AvatarImage", SimpleBaseFrame )
	Avatar:SetSize( 32, 32 )
	Avatar:SetPos( 5, 5 )
	Avatar:SetPlayer( LocalPlayer(), 64 )
	
	local SimpleCloseButton = vgui.Create("DButton", SimpleBaseFrame )
	SimpleCloseButton:SetText( "X" )
	SimpleCloseButton:SetPos( 355, 8 )
	SimpleCloseButton:SetSize( 45, 25 )
	SimpleCloseButton:SetFont( 'Trebuchet24' )
	SimpleCloseButton:SetTextColor(  Color( 255, 255, 255, 200 ) )
	SimpleCloseButton.OnCursorEntered = function( self ) self.hover = true surface.PlaySound("UI/buttonrollover.wav") end
	SimpleCloseButton.OnCursorExited = function( self ) self.hover = false end
	SimpleCloseButton.Slide = 0
	SimpleCloseButton.Paint = function( self, w, h )
		draw.RoundedBox(2, 0, 0, w, h, Color( 255, 0, 0 ) )
	end
	SimpleCloseButton.DoClick = function()
	
		SimpleBaseFrame:MoveTo( ScrW() / 3, ScrH() * 2, 0.7, 0, 4)
		
		timer.Simple(0.7, function() SimpleBaseFrame:Remove() end )
		
	end 
	
	local ButtonsList = vgui.Create( "DScrollPanel", SimpleBaseFrame )
	ButtonsList:SetSize( 400, SimpleBaseFrame:GetTall() - 30 )
	ButtonsList:Center()
	
	local sbar = ButtonsList:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
	end
	
	for k,v in pairs(TaxiDestinations) do
		local ButtonFrame = vgui.Create( 'DButton', ButtonsList )
		ButtonFrame:SetText( v.Name .. " (" .. v.Price .. FTS.ServerCurrency .. ")") 
		ButtonFrame:SetPos( v.PosX, v.PosY )
		ButtonFrame:SetSize( 350, 40 )
		ButtonFrame:SetFont( 'Trebuchet24' )
		ButtonFrame:SetTextColor(  Color( 255, 255, 255, 200 ) )
		ButtonFrame.OnCursorEntered = function( self ) self.hover = true surface.PlaySound("UI/buttonrollover.wav") end
		ButtonFrame.OnCursorExited = function( self ) self.hover = false end
		ButtonFrame.Slide = 0
		ButtonFrame.Paint = function( self, w, h )
			if self.hover then
				self.Slide = Lerp( 0.03, self.Slide, w )

				draw.RoundedBox(2, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
				draw.RoundedBox(1, 0, 0, self.Slide, h, Color( 255, 50, 50 ) )
			else
				self.Slide = Lerp( 0.03, self.Slide, 0 )
									
				draw.RoundedBox(2, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
				draw.RoundedBox(1, 0, 0, self.Slide, h, Color( 255, 50, 50 ) )
			end
		end
		ButtonFrame.DoClick = function()
			SimpleBaseFrame:MoveTo( ScrW() / 3, ScrH() * 2, 0.7, 0, 4)
			timer.Simple(0.7, function() SimpleBaseFrame:Remove() end )
			
			if (LocalPlayer():getDarkRPVar("money") > v.Price) then 
			
				DrawWaitingElements()
				surface.PlaySound("vehicles/v8/v8_turbo_on_loop1.wav")
				
				net.Start("FTransportSystem:DestinationPlayer:Freeze")
					net.WriteUInt( 4, 32 )
					net.WriteEntity( self )
				net.SendToServer()
				
				timer.Simple(19.9, function()
					RunConsoleCommand("stopsound") 
				end )
				
				timer.Simple(20, function()
					net.Start("FTransportSystem:SwitchServer:Destination")
						net.WriteUInt(k, 32)
						net.WriteEntity( self )
					net.SendToServer()

					
					net.Start("FTransportSystem:DestinationPlayer:Freeze")
						net.WriteUInt( 8, 32 )
						net.WriteEntity( self )
					net.SendToServer()
				end )
				
			else
				return chat.AddText(Color(255,0,0), "[FTransportSystem] : ", color_white, fts_lang.NotEnoughMoney)
			end
		end 
	end 
end )

function DrawWaitingElements()
	local W, H = ScrW(), ScrH()
	local fts_lang = FTransportSystem.Language[FTS_BaseLang]
	local TimerDrive = 20
	
	timer.Create( "DTimer", 1, 20, function()
		hook.Add("HUDPaint", "FTransportSystem:DrivingInterface", function()
			draw.RoundedBox(4, 0, 0, W, H, Color(41, 47, 59))
			draw.DrawText(fts_lang.DrivingInterfaceText .. " (" .. TimerDrive .. "s" .. ")", "DermaLarge", ScrW() / 2 + 10, ScrH() / 2 - 50, color_white, TEXT_ALIGN_CENTER)
		end)
		TimerDrive = TimerDrive - 1
	end)
	
	timer.Simple(TimerDrive + 0.1, function()
		hook.Remove( "HUDPaint", "FTransportSystem:DrivingInterface" )
	end )
end

--[[-------------------------------------------------------------------------
	Admin Menu
---------------------------------------------------------------------------]]

net.Receive("FTransportSystem:SwitchClient:User:Admin", function()
	local fts_lang = FTransportSystem.Language[FTS_BaseLang]

	local BaseDFrame = vgui.Create( "DFrame" )
	BaseDFrame:SetSize( ScrW() / 2, ScrH() / 3.5 )
	BaseDFrame:Center()
	BaseDFrame:SetTitle( "" )
	BaseDFrame:MakePopup()
	BaseDFrame:SetDraggable( false )
	BaseDFrame:ShowCloseButton( false )
	BaseDFrame.Paint = function( self, w, h )
		DrawBlur( self, 6, 25 )
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 47, 59, 225 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 40, Color( 27, 37, 47 ) )
		
		draw.SimpleText("FTransportSystem", "Trebuchet24", w / 2, h / 12, Color(255,255,255,255), 1, 1)
	end
	
	local Avatar = vgui.Create( "AvatarImage", BaseDFrame )
	Avatar:SetSize( 32, 32 )
	Avatar:SetPos( 5, 5 )
	Avatar:SetPlayer( LocalPlayer(), 64 )
	
	local SimpleCloseButton = vgui.Create("DButton", BaseDFrame )
	SimpleCloseButton:SetText( "X" )
	SimpleCloseButton:SetPos( 665, 8 )
	SimpleCloseButton:SetSize( 45, 25 )
	SimpleCloseButton:SetFont( 'Trebuchet24' )
	SimpleCloseButton:SetTextColor(  Color( 255, 255, 255, 200 ) )
	SimpleCloseButton.OnCursorEntered = function( self ) self.hover = true surface.PlaySound("UI/buttonrollover.wav") end
	SimpleCloseButton.OnCursorExited = function( self ) self.hover = false end
	SimpleCloseButton.Slide = 0
	SimpleCloseButton.Paint = function( self, w, h )
		draw.RoundedBox(2, 0, 0, w, h, Color( 255, 0, 0 ) )
	end
	SimpleCloseButton.DoClick = function()
		BaseDFrame:MoveTo( ScrW() / 4, ScrH() * 2, 0.7, 0, 4)
		timer.Simple(0.7, function() BaseDFrame:Remove() end )
	end
	
	local DComboBox = vgui.Create( "DComboBox", BaseDFrame )
	DComboBox:SetPos( 5, 50 )
	DComboBox:SetSize( 700, 40 )
	DComboBox:SetValue( fts_lang.ChoiceValue )
	DComboBox:AddChoice( fts_lang.Value1 )
	DComboBox:AddChoice( fts_lang.Value2 )
	DComboBox.OnSelect = function( panel, index, value )
		if DComboBox:GetText() == "" then return end 
	
		BaseDFrame:MoveTo( ScrW() / 4, ScrH() * 2, 0.7, 0, 4)
		timer.Simple(0.7, function() BaseDFrame:Remove() end )
		
		if DComboBox:GetText() == fts_lang.Value1 then 
			net.Start("FTransportSystem:SwitchServer:AdminAction")
				net.WriteUInt( 2, 8 )
			net.SendToServer()
		elseif DComboBox:GetText() == fts_lang.Value2 then
		
			net.Start("FTransportSystem:SwitchServer:AdminAction")
				net.WriteUInt( 3, 8 )
			net.SendToServer()	
		end 
	end
	
	local ButtonFrame = vgui.Create( 'DButton', BaseDFrame )
	ButtonFrame:SetText( fts_lang.BroadcastAdmin ) 
	ButtonFrame:SetPos( 60, 210 )
	ButtonFrame:SetSize( 600, 40 )
	ButtonFrame:SetFont( 'Trebuchet24' )
	ButtonFrame:SetTextColor(  Color( 255, 255, 255, 200 ) )
	ButtonFrame.OnCursorEntered = function( self ) self.hover = true surface.PlaySound("UI/buttonrollover.wav") end
	ButtonFrame.OnCursorExited = function( self ) self.hover = false end
	ButtonFrame.Slide = 0
	ButtonFrame.Paint = function( self, w, h )
		if self.hover then
			self.Slide = Lerp( 0.03, self.Slide, w )

			draw.RoundedBox(2, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
			draw.RoundedBox(1, 0, 0, self.Slide, h, Color( 255, 50, 50 ) )
		else
			self.Slide = Lerp( 0.03, self.Slide, 0 )
									
			draw.RoundedBox(2, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
			draw.RoundedBox(1, 0, 0, self.Slide, h, Color( 255, 50, 50 ) )
		end
	end
	ButtonFrame.DoClick = function()
		BaseDFrame:MoveTo( ScrW() / 4, ScrH() * 2, 0.7, 0, 4)
		timer.Simple(0.7, function() BaseDFrame:Remove() end )
		
		local TextDFrame = vgui.Create( "DFrame" )
		TextDFrame:SetSize( ScrW() / 3.5, ScrH() / 4 )
		TextDFrame:Center()
		TextDFrame:SetTitle( fts_lang.BroadcastFrame )
		TextDFrame:SetDraggable( false )
		TextDFrame:MakePopup()
		TextDFrame.Paint = function(self, w, h) 
			DrawBlur( self, 6, 25 )
		
			draw.RoundedBox( 0, 0, 0, w, h, Color( 41, 47, 59, 225 ) )
		
			draw.RoundedBox( 0, 0, 0, w, 40, Color( 27, 37, 47 ) )
		end
		
		local ValueText = vgui.Create( "DTextEntry", TextDFrame )
		ValueText:SetPos( 10, 70 )
		ValueText:SetMultiline( true )
		ValueText:SetSize( TextDFrame:GetTall() * 1.750, TextDFrame:GetTall() / 4 )
		
		local MenuPanelButton1 = vgui.Create( "DButton", TextDFrame )
		MenuPanelButton1:SetSize( 150, 40 )
		MenuPanelButton1:SetPos( 10, 160 )
		MenuPanelButton1:SetText( fts_lang.SendAnnouncement )
		MenuPanelButton1:SetFont( 'Trebuchet24' )
		MenuPanelButton1:SetTextColor(  Color( 255, 255, 255, 200 ) )
		MenuPanelButton1.OnCursorEntered = function( self ) self.hover = true surface.PlaySound("UI/buttonrollover.wav") end
		MenuPanelButton1.OnCursorExited = function( self ) self.hover = false end
		MenuPanelButton1.Slide = 0
		MenuPanelButton1.Paint = function( self, w, h )
			if self.hover then
				self.Slide = Lerp( 0.2, self.Slide, w )

				draw.RoundedBox(2, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
				draw.RoundedBox(1, 0, 0, self.Slide, h, Color( 255, 50, 50 ) )
			else
				self.Slide = Lerp( 0.2, self.Slide, 0 )
							
				draw.RoundedBox(2, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
				draw.RoundedBox(1, 0, 0, self.Slide, h, Color( 255, 50, 50 ) )
			end
		end
		MenuPanelButton1.DoClick = function()
			if ValueText:GetValue() == "" then return end 
		
			TextDFrame:MoveTo( ScrW() / 2.8, ScrH() * 2, 0.7, 0, 4)
			timer.Simple(0.7, function() TextDFrame:Remove() end )	
			
			net.Start("FTransportSystem:SwitchServer:AdminAction")
				net.WriteUInt( 4, 8 )
				net.WriteString( ValueText:GetValue(), 32 )
				net.WriteString( LocalPlayer():Nick(), 64 )
			net.SendToServer()
		end
	end
end )

--[[-------------------------------------------------------------------------
	Admin Announcement (HUDPaint)
---------------------------------------------------------------------------]]

net.Receive("FTransportSystem:SwitchClient:DrawHUDPaint", function()
	local text = net.ReadString( 32 )
	local author = net.ReadString( 16 )
	local W, H = ScrW() / 1.025, ScrH() / 20
	
	hook.Add("HUDPaint", "FTransportSystem:Announcement:DrawHUDPaint", function()
		draw.RoundedBox(0, 20, 10, W, H, Color(255, 50, 50))
		draw.DrawText("FTransportSystem - (" .. author .. ") : " .. text, "FTransportSystem:BroadcastModule:Font340", ScrW() / 2 - 50, ScrH() / 40, color_white, TEXT_ALIGN_CENTER)
	end)
	
	timer.Simple(20, function()
		hook.Remove( "HUDPaint", "FTransportSystem:Announcement:DrawHUDPaint" )
	end )
end )
