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
--            Server | Area          --
---------------------------------------
 
util.AddNetworkString("Area.EnterArea")
util.AddNetworkString("Area.LeaveArea")
util.AddNetworkString("Area.CreateArea")
util.AddNetworkString("Area.SetupArea")
util.AddNetworkString("Area.ToggleSound")
util.AddNetworkString("Area.SendSounds")
util.AddNetworkString("Area.ClientReady")

function Area:AddArea(sound, name, id, fadeIn, startVector, endVector)
	Area.Areas = Area.Areas or {}
	Area.Areas[id] = Area.Areas[id] or {}
	Area.Areas[id].Sound = sound
	Area.Areas[id].Name = name
	Area.Areas[id].FadeIn = fadeIn
	Area.Areas[id].StartingVector = startVector
	Area.Areas[id].EndingVector = endVector


	Area:SaveAreas()
end


function Area:PlayerMove(ply, mv)
	Area.Areas = Area.Areas or {}
	ply.CurrentAreas = ply.CurrentAreas or {}
	for id, area in pairs(Area.Areas) do
		if ply:GetPos():WithinAABox(area.StartingVector, area.EndingVector) then
			if not ply.CurrentAreas[id] then
				Area:DisplayAreaEnter(ply, id)
				ply.CurrentAreas[id] = true
			end 
		else
			if ply.CurrentAreas[id] then
				ply.CurrentAreas[id] = nil
				Area:DisplayAreaLeave(ply, id)
			end
		end
	end
end

function Area:DisplayAreaEnter(ply, id)
	net.Start("Area.EnterArea")
	net.WriteTable(Area.Areas[id])
	net.WriteString(id)
	net.Send(ply)
end

function Area:DisplayAreaLeave(ply, id)
	net.Start("Area.LeaveArea")
	net.WriteTable(Area.Areas[id])
	net.WriteString(id)
	net.Send(ply)
end

function Area:RemoveArea(id)
	Area.Areas[id] = nil
	Area:SaveAreas()
end

function Area:SaveAreas()
	Area.Areas = Area.Areas or {}
	local json = util.TableToJSON(Area.Areas, true)

	file.Write("ambientsystem-areas.txt", json)
end

function Area:LoadAreas()
	local json = file.Read("ambientsystem-areas.txt")

	if json then
		Area.Areas = util.JSONToTable(json)
	else
		Area.Areas = {}
	end
end

function Area:SaveSounds()
	Area.Areas = Area.Areas or {}
	local json = util.TableToJSON(Area.Areas, true)

	file.Write("ambientsystem-sounds.txt", json)

	for k, v in pairs(player.GetAll()) do
		net.Start("Area.SendSounds")
		net.WriteTable(Area.Sounds)
		net.Send(v)
	end
end

function Area:LoadSounds()
	local json = file.Read("ambientsystem-sounds.txt")

	if json then
		Area.Sounds = util.JSONToTable(json)
		
		Area.Sounds["forest"] = "forest.ogg"
		Area.Sounds["village"] = "dorfambient.ogg" 
		Area.Sounds["mine"] = "mineambient.ogg" 
		Area.Sounds["pond"] = "pond.ogg"
	else
		Area.Sounds = {}
		Area.Sounds["forest"] = "forest.ogg"
		Area.Sounds["village"] = "dorfambient.ogg" 
		Area.Sounds["mine"] = "mineambient.ogg" 
		Area.Sounds["pond"] = "pond.ogg"

		Area:SaveSounds()
	end
	
end


function Area:AddSound(name, path)
	Area.Sounds = Area.Sounds or {}
	Area.Sounds[name] = path

	Area:SaveSounds()

end

function Area:RemoveSound(name)
	Area.Sounds = Area.Sounds or {}
	Area.Sounds[name] = nil

	Area:SaveSounds()
end

concommand.Add("DeleteArea", function(player, command, args)
	if not args[1] then return end
	if not player:IsAdmin() then return end

	Area:RemoveArea(args[1])
end)

concommand.Add("AddSound", function(ply, command, args)
	if not args[1] then 
		ply:ChatPrint("This is not a valid sound name")
		return 
	end

	if not args[2] then
		ply:ChatPrint("This is not a valid sound path")
		return 
	end

	if not ply:IsAdmin() then return end

	Area:AddSound(args[1], args[2])

	ply:ChatPrint("Added sound")
end)

concommand.Add("RemoveSound", function(ply, command, args)
	if not args[1] or not IsString(args[1]) then 
		ply:ChatPrint("This is not a valid sound name")
		return 
	end

	if not player:IsAdmin() then return end

	Area:RemoveSound(args[1])

	ply:ChatPrint("Removed sound")
end)

concommand.Add("PrintAreas", function(player, command, args)
	if not player:IsAdmin() then return end

	player:ChatPrint("Following Areas existing:")
	for k, v in pairs(Area.Areas) do
		player:ChatPrint("- "..k)
	end
end)

Area:LoadAreas()
Area:LoadSounds()

hook.Add("PlayerSay", "Area.MuteCommand", function(ply, text)
	if text and string.StartWith(text, "/toggleambience") then
		net.Start("Area.ToggleSound")
		net.Send(ply)
		return ""
	end
end)

net.Receive("Area.CreateArea", function(len, ply) Area:AddArea(net.ReadString(), net.ReadString(), net.ReadString(), net.ReadBool(), net.ReadVector(), net.ReadVector()) end)

hook.Add("Move", "Area.Move", function(ply, mv) 
	if Area.MoveTimeout and Area.MoveTimeout > CurTime() then
		Area.MoveTimeout = CurTime()
		return
	else
		Area:PlayerMove(ply, mv)
		Area.MoveTimeout = CurTime() + 1
	end 
end)


net.Receive("Area.ClientReady", function(len, ply)
	net.Start("Area.SendSounds")
	net.WriteTable(Area.Sounds)
	net.Send(ply)
end)  