local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")

local Numbers = require(game.ReplicatedStorage.Modules:WaitForChild("Numbers"))

local RebirthsOrderedDataStore = DataStoreService:GetOrderedDataStore("Rebirths")

local RebirthsLeaderboard = script.Parent
local RebirthsLeaderboardGui = RebirthsLeaderboard:WaitForChild("RebirthsLeaderboardGui")
local RebirthsLeaderboardFrame = RebirthsLeaderboardGui:WaitForChild("RebirthsLeaderboardFrame")
local ItemsContainer = RebirthsLeaderboardFrame:WaitForChild("Items")
local ItemTemplate = script:WaitForChild("Item")

local Updating = false

local function UpdateRebirthsLeaderboard()
	if Updating then return end
	Updating = true

	for _, Item in ipairs(ItemsContainer:GetChildren()) do
		if Item:IsA("Frame") then
			Item:Destroy()
		end
	end

	local Success, Page = pcall(function()
		return RebirthsOrderedDataStore:GetSortedAsync(false, 100, 1)
	end)

	if not Success or not Page then
		Updating = false
		return
	end

	local Data = Page:GetCurrentPage()
	for Index, Entry in ipairs(Data) do
		local UserId = tonumber(Entry.key)
		if UserId and UserId > 0 then
			task.spawn(function()
				local Item = ItemTemplate:Clone()
				Item.LayoutOrder = Index
				Item.Parent = ItemsContainer

				Item.Index.Text = "#" .. tostring(Index)
				Item.Rebirths.Text = Numbers.Format(Entry.value or 0)

				local Thumbnail = Item:FindFirstChild("Thumbnail")
				if Thumbnail then
					Thumbnail.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", UserId)
				end

				local UserSuccess, Info = pcall(function()
					return UserService:GetUserInfosByUserIdsAsync({UserId})
				end)

				if UserSuccess and Info and #Info > 0 then
					local User = Info[1]

					Item.Name = User.Username
					Item.Player.Text = string.format("%s (@%s)", User.DisplayName, User.Username)
				end

				Item.Visible = true
			end)

			task.wait(0.1)
		end
	end

	Updating = false
end

while true do
	pcall(UpdateRebirthsLeaderboard)
	task.wait(60)
end
