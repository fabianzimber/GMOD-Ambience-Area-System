---------------------------------------
---------------------------------------
--      Herr der Ringe Roleplay      --
--             (HDR:RP)              --
--                                   --
--                                   --
--              Author:              --
--      Fabian 'Mekphen' Zimber      --
--                                   --
---------------------------------------
---------------------------------------

---------------------------------------
--        Client | PlainModule       --
---------------------------------------

Area = Area or {}

function Area:EnterArea(areaTable, id)
	local text = "You enter "..areaTable.Name

	LocalPlayer():ChatPrint(text)
	LocalPlayer().Areas = LocalPlayer().Areas or {}
	if LocalPlayer().Areas[id] and (type(LocalPlayer().Areas[id]) == "IGModAudioChannel") then
		LocalPlayer().Areas[id]:Stop()
	end 
	LocalPlayer().Areas[id] = {}

	if not LocalPlayer().AmbientSoundsMuted and areaTable.Sound then 

		timer.Remove("Area.SoundFadeIn")
		sound.PlayFile("sound/"..areaTable.Sound, "", function(station)
	
			if station then
				if not areaTable.FadeIn then
					station:SetVolume(0.0)
					LocalPlayer().FadeInVolume = 0
					timer.Create("Area.SoundFadeIn", 0.1, 50, function()
						if station and IsValid(station) then
							LocalPlayer().FadeInVolume = LocalPlayer().FadeInVolume + 0.0025
							station:SetVolume(LocalPlayer().FadeInVolume)
						end
					end)
	
					LocalPlayer().Areas[id] = station
					station:EnableLooping(true)
				else
					station:SetVolume(0.3)
					LocalPlayer().Areas[id] = station
				end
			end
			
		end)
	end

	if EnterAreaPanel then
		EnterAreaPanel:Remove()
		EnterAreaPanel = nil
	end

	if LeaveAreaPanel then
		LeaveAreaPanel:Remove()
		LeaveAreaPanel = nil
	end

	EnterAreaPanel = vgui.Create("DPanel")
	EnterAreaPanel:SetSize(RWidth(700), RHeight(100))
	EnterAreaPanel:SetPos(RWidth(610), RHeight(50))
	EnterAreaPanel:SetBackgroundColor(Color(0, 0, 0, 200))

	local label = vgui.Create("DLabel", EnterAreaPanel)
	label:SetFont("Trebuchet24")
	label:SetContentAlignment(5)
	label:Dock( FILL )
	label:SetText(text)
	label:Center()
	label:SetTextColor(Color(255,255,255))

	timer.Simple(10, function()
		if EnterAreaPanel then
			EnterAreaPanel:Remove()
			EnterAreaPanel = nil
		end
	end)
end


function Area:LeaveArea(areaTable, id)
	local text = "You're leaving "..areaTable.Name

	timer.Remove("Area.SoundFadeIn")

	LocalPlayer():ChatPrint(text)
	LocalPlayer().Areas = LocalPlayer().Areas or {}
	if LocalPlayer().Areas[id] and (type(LocalPlayer().Areas[id]) == "IGModAudioChannel") and IsValid(LocalPlayer().Areas[id]) then
		LocalPlayer().FadeInVolume = 0.125
		timer.Create("Area.SoundFadeOut", 0.1, 50, function()
			if LocalPlayer().Areas[id] and (type(LocalPlayer().Areas[id]) == "IGModAudioChannel") and IsValid(LocalPlayer().Areas[id]) then
				LocalPlayer().FadeInVolume = LocalPlayer().FadeInVolume - 0.0025
				LocalPlayer().Areas[id]:SetVolume(LocalPlayer().FadeInVolume)
			end
		end) 
		timer.Simple(10, function()
			if LocalPlayer().Areas[id] and IsValid(LocalPlayer().Areas[id]) then
				LocalPlayer().Areas[id]:Stop() 
			end
		end)
	end
	
	if EnterAreaPanel then
		EnterAreaPanel:Remove()
		EnterAreaPanel = nil
	end

	if LeaveAreaPanel then
		LeaveAreaPanel:Remove()
		LeaveAreaPanel = nil
	end

	LeaveAreaPanel = vgui.Create("DPanel")
	LeaveAreaPanel:SetSize(RWidth(700), RHeight(100))
	LeaveAreaPanel:SetPos(RWidth(610), RHeight(50))
	LeaveAreaPanel:SetBackgroundColor(Color(0, 0, 0, 200))

	local label = vgui.Create("DLabel", LeaveAreaPanel)
	label:SetFont("Trebuchet24")
	label:SetContentAlignment(5)
	label:Dock( FILL )
	label:SetText(text)
	label:Center()
	label:SetTextColor(Color(255,255,255))

	timer.Simple(10, function()
		if LeaveAreaPanel then
			LeaveAreaPanel:Remove()
			LeaveAreaPanel = nil
		end
	end)
end


function Area:SetupAreaUI(startVector, endVector)
	local background = vgui.Create("DFrame")
    background:MakePopup()
    background:ShowCloseButton( true )
    background:SetSize(RWidth(400), RHeight(850))
    background:Center()

    local nameTextEntry = vgui.Create("DTextEntry", background)
    nameTextEntry:SetText("Area-Name")
    nameTextEntry:SetSize(RWidth(300), RHeight(150))
    nameTextEntry:SetPos(RWidth(50), RHeight(50))

    local idTextEntry = vgui.Create("DTextEntry", background)
    idTextEntry:SetText("ID")
    idTextEntry:SetSize(RWidth(300), RHeight(150))
    idTextEntry:SetPos(RWidth(50), RHeight(225))

    local comboBox = vgui.Create("DComboBox", background)
    comboBox:SetSize(RWidth(300), RHeight(150))
    comboBox:SetPos(RWidth(50), RHeight(400))

    local fadeInCheckbox = vgui.Create("DCheckBox", background)
    fadeInCheckbox:SetSize(RWidth(60), RHeight(60))
    fadeInCheckbox:SetPos(RWidth(285), RHeight(575))
    fadeInCheckbox:SetValue(true)

    local fadeInLabel = vgui.Create("DLabel", background)
    fadeInLabel:SetSize(RWidth(200), RHeight(60))
    fadeInLabel:SetPos(RWidth(50), RHeight(575))
    fadeInLabel:SetText("No Fade-In?")
    fadeInLabel:SetFont("Trebuchet24")

    for k, v in pairs(Area.Sounds) do
    	comboBox:AddChoice(v)
    end

    local createAreaButton = vgui.Create("DButton", background)
    createAreaButton:SetSize(RWidth(300), RHeight(150))
    createAreaButton:SetPos(RWidth(50), RHeight(650))
    createAreaButton:SetText("Create area")


    function createAreaButton:DoClick()
    	net.Start("Area.CreateArea")
    	net.WriteString(comboBox:GetSelected())
    	net.WriteString(nameTextEntry:GetText())
    	net.WriteString(idTextEntry:GetText())
    	net.WriteBool(fadeInCheckbox:GetValue())
    	net.WriteVector(startVector)
    	net.WriteVector(endVector)
    	net.SendToServer()
    end

end

function Area:ToggleSound()
	if not LocalPlayer().AmbientSoundsMuted then
		for k, v in pairs(LocalPlayer().Areas or {}) do
			if LocalPlayer().Areas[k] and (type(LocalPlayer().Areas[k]) == "IGModAudioChannel") and IsValid(LocalPlayer().Areas[k]) then
				LocalPlayer().FadeInVolume = 0.125
				timer.Create("Area.SoundFadeOut", 0.1, 50, function()
					if LocalPlayer().Areas[k] and (type(LocalPlayer().Areas[k]) == "IGModAudioChannel") and IsValid(LocalPlayer().Areas[k]) then
						LocalPlayer().FadeInVolume = LocalPlayer().FadeInVolume - 0.0025
						LocalPlayer().Areas[k]:SetVolume(LocalPlayer().FadeInVolume)
					end
				end) 
				timer.Simple(10, function()
					if LocalPlayer().Areas[k] and IsValid(LocalPlayer().Areas[k]) then
						LocalPlayer().Areas[k]:Stop() 
					end
				end)
			end
		end
	
		LocalPlayer().AmbientSoundsMuted = true
		LocalPlayer():ChatPrint("You have muted ambient sounds.")
	else
		LocalPlayer().AmbientSoundsMuted = false
		LocalPlayer():ChatPrint("You enabled ambient sounds.")
	end   
end

net.Receive("Area.ToggleSound", function()
	Area:ToggleSound()
end)

net.Receive("Area.SendSounds", function()
	Area.Sounds = net.ReadTable()
end)

hook.Add( "InitPostEntity", "Area.ClientReady", function()
	net.Start( "Area.ClientReady" )
	net.SendToServer()
end )


---------------
-- Desc: Helper Function to turn simpel px to a relative value by screensize
-- Note: Calculated on the base of full hd resolution
---------------
function RWidth(pixel)
    return ScrW() / (1920 / pixel)
end

---------------
-- Desc: Helper Function to turn simpel px to a relative value by screensize
-- Note: Calculated on the base of full hd resolution
---------------
function RHeight(pixel)
    return ScrH() / (1080 / pixel)
end

net.Receive("Area.LeaveArea", function() Area:LeaveArea(net.ReadTable(), net.ReadString()) end)
net.Receive("Area.EnterArea", function() Area:EnterArea(net.ReadTable(), net.ReadString()) end)
net.Receive("Area.SetupArea", function() Area:SetupAreaUI(net.ReadVector(), net.ReadVector()) end)