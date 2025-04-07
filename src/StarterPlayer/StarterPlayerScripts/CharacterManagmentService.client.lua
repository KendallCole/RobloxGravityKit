local Players = game:GetService("Players")

local myPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function listenToCharacter(character)

    local hum = character:WaitForChild("Humanoid")


    hum.Died:Once(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = myPlayer.Character.Humanoid
    end)
end



if myPlayer.Character then
    listenToCharacter(myPlayer.Character)
end
myPlayer.CharacterAdded:Connect(listenToCharacter)