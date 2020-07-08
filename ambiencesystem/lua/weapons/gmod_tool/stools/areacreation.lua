TOOL.Category = "Mekphen's Addons"
TOOL.Name = "#tool.areacreation.name"

if CLIENT then
	language.Add( "tool.areacreation.name", "Area Creation" )
	language.Add( "tool.areacreation.desc", "Leftclick: Select first position. Rightclick: Select second position. Reload: Create Area" )
	language.Add( "tool.areacreation.0", "" )
end

function TOOL:LeftClick( trace )

    if not trace.Entity then return end
    if not self:GetOwner():IsAdmin() then return end

    if SERVER then
        self.PositionOne = trace.HitPos
        self:GetOwner():ChatPrint("You have selected the first position.")
    end
    return true
end

function TOOL:RightClick( trace )
    if not self:GetOwner():IsAdmin() then return end
    if SERVER then
        self.PositionTwo = trace.HitPos
        self:GetOwner():ChatPrint("You have selected the second position.")
    end

    return true
end

function TOOL:Reload()
    if not self:GetOwner():IsAdmin() then return end

    if SERVER then
        net.Start("Area.SetupArea")
        net.WriteVector(self.PositionOne)
        net.WriteVector(self.PositionTwo)
        net.Send(self:GetOwner())
    end
end

function TOOL.BuildCPanel( panel )
end