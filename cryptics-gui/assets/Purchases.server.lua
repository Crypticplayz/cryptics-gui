-- Purchases (Script in ServerScriptService) — the server half of a Cryptic's GUI shop.
-- Skill Made By : Crypticplay_RBLX - Only on Youtube
--
-- What it does:
--   * Developer products (Robux, can be bought many times): ProcessReceipt grants exactly once per
--     PurchaseId, even if the player leaves or the server crashes mid-purchase.
--   * Gamepasses (Robux, bought once): checks ownership on join and right after a purchase, then sets the
--     Player attribute  Pass_<passId> = true  so the UI (UIKit.watchPass) can show OWNED.
--   * In-game currency items: the client asks, the SERVER checks price and balance, spends, grants.
--     The client never decides what anyone owns.
--
-- You fill in three things below: PRODUCTS, PASSES and SHOP_ITEMS, plus the Economy functions that read
-- and change your game's own data (leaderstats, a ProfileStore profile, a DataStore table...).
-- Publish the game and enable Studio API access (Game Settings > Security) to test purchases in Studio.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------------------------------------------------------------------------
-- 1) YOUR CATALOG
------------------------------------------------------------------------------------------------
-- Developer products: productId -> function(player) that grants it and returns true when done.
local PRODUCTS: { [number]: (Player) -> boolean } = {
	-- [1234567] = function(player) return Economy.add(player, "Coins", 5000) end,
}

-- Gamepasses: passId -> function(player) run once per session when the player owns it.
local PASSES: { [number]: (Player) -> () } = {
	-- [7654321] = function(player) player:SetAttribute("LuckMultiplier", 2) end,
}

-- Items bought with in-game currency: itemId -> { currency, price, grant(player) -> boolean }
local SHOP_ITEMS: { [string]: { currency: string, price: number, grant: (Player) -> boolean } } = {
	-- ["luck_potion"] = { currency = "Coins", price = 2500, grant = function(p) return Economy.addItem(p, "LuckPotion", 1) end },
}

------------------------------------------------------------------------------------------------
-- 2) YOUR ECONOMY (replace with your own data layer; leaderstats is only the simplest example)
------------------------------------------------------------------------------------------------
local Economy = {}

function Economy.get(player: Player, currency: string): number
	local ls = player:FindFirstChild("leaderstats")
	local v = ls and ls:FindFirstChild(currency)
	return (v and (v :: any).Value) or 0
end

function Economy.spend(player: Player, currency: string, amount: number): boolean
	local ls = player:FindFirstChild("leaderstats")
	local v = ls and ls:FindFirstChild(currency) :: any
	if not v or v.Value < amount then return false end
	v.Value -= amount
	return true
end

function Economy.add(player: Player, currency: string, amount: number): boolean
	local ls = player:FindFirstChild("leaderstats")
	local v = ls and ls:FindFirstChild(currency) :: any
	if not v then return false end
	v.Value += amount
	return true
end

------------------------------------------------------------------------------------------------
-- 3) PRICES AND IDS FROM THE CONTENT SHEETS (ReplicatedStorage.UIContent, built from shop.csv)
-- So the price on a button is always the price the server charges. Rows fill in what you didn't
-- write by hand above. `gives` = "<currencyId>:<amount>" (e.g. "coins:5000") is granted automatically;
-- anything else needs a function in GRANTS / PASS_PERKS keyed by the row id.
------------------------------------------------------------------------------------------------
local GRANTS: { [string]: (Player) -> boolean } = {
	-- ["starter"] = function(player) ... return true end,
}
local PASS_PERKS: { [string]: (Player) -> () } = {
	-- ["vip"] = function(player) player:SetAttribute("CoinMultiplier", 1.5) end,
}

local function grantFromGives(gives: string?): ((Player) -> boolean)?
	if type(gives) ~= "string" then return nil end
	local cur, amount = string.match(gives, "^%s*([%w_]+)%s*:%s*(%d+)%s*$")
	if not cur then return nil end
	local n = tonumber(amount) :: number
	return function(player: Player) return Economy.add(player, cur, n) end
end

do
	local mod = ReplicatedStorage:FindFirstChild("UIContent")
	local ok, content = false, nil
	if mod and mod:IsA("ModuleScript") then ok, content = pcall(require, mod) end
	if ok and type(content) == "table" then
		for _, row in ipairs(content.shop or {}) do
			local grant = GRANTS[row.id] or grantFromGives(row.gives)
			local cur = row.currency and string.lower(row.currency) or nil
			if cur == "robux" then
				if row.product_id and not PRODUCTS[row.product_id] then
					if grant then PRODUCTS[row.product_id] = grant
					else warn("Purchases: shop row '" .. tostring(row.id) .. "' has no grant (add GRANTS['" .. tostring(row.id) .. "'] or a gives value)") end
				elseif row.pass_id and not PASSES[row.pass_id] then
					PASSES[row.pass_id] = PASS_PERKS[row.id] or function() end
				end
			elseif cur and row.price and not SHOP_ITEMS[row.id] then
				if grant then
					SHOP_ITEMS[row.id] = { currency = row.currency, price = row.price, grant = grant }
				else
					warn("Purchases: shop row '" .. tostring(row.id) .. "' has no grant (add GRANTS['" .. tostring(row.id) .. "'] or a gives value)")
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------------
-- Developer products: grant once per PurchaseId
------------------------------------------------------------------------------------------------
local history = DataStoreService:GetDataStore("CrypticsPurchaseHistory")

MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		-- Not in this server (left early): Roblox will retry the receipt next time they join.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local grant = PRODUCTS[receipt.ProductId]
	if not grant then
		warn("Purchases: no handler for product " .. receipt.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local key = receipt.PlayerId .. "_" .. receipt.PurchaseId
	local alreadyGranted = false
	local ok, err = pcall(function()
		history:UpdateAsync(key, function(done)
			if done then
				alreadyGranted = true
				return nil -- keep as is
			end
			local granted = grant(player)
			if not granted then error("grant returned false") end
			return true
		end)
	end)
	if not ok then
		warn("Purchases: could not grant " .. receipt.ProductId .. " to " .. player.Name .. ": " .. tostring(err))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- IMPORTANT: if your grant changes saved data, save it before returning PurchaseGranted
	-- (or make your data layer write the grant atomically, e.g. ProfileStore receipts).
	if not alreadyGranted then player:SetAttribute("LastPurchase", receipt.ProductId) end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

------------------------------------------------------------------------------------------------
-- Gamepasses: check on join and after buying; expose as a Player attribute for the UI
------------------------------------------------------------------------------------------------
local function applyPass(player: Player, passId: number)
	if player:GetAttribute("Pass_" .. passId) == true then return end
	player:SetAttribute("Pass_" .. passId, true)
	local fn = PASSES[passId]
	if fn then
		local ok, err = pcall(fn, player)
		if not ok then warn("Purchases: pass " .. passId .. " handler failed: " .. tostring(err)) end
	end
end

local function checkPasses(player: Player)
	for passId in pairs(PASSES) do
		task.spawn(function()
			local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, passId)
			if ok and owns then applyPass(player, passId) end
		end)
	end
end

Players.PlayerAdded:Connect(checkPasses)
for _, p in ipairs(Players:GetPlayers()) do checkPasses(p) end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if purchased then applyPass(player, passId) end
end)

------------------------------------------------------------------------------------------------
-- In-game currency purchases (server-validated, rate-limited)
------------------------------------------------------------------------------------------------
local folder = ReplicatedStorage:FindFirstChild("CrypticsShop") or Instance.new("Folder")
folder.Name = "CrypticsShop"
folder.Parent = ReplicatedStorage
local buyFn = folder:FindFirstChild("BuyWithCurrency") or Instance.new("RemoteFunction")
buyFn.Name = "BuyWithCurrency"
buyFn.Parent = folder

local lastBuy: { [Player]: number } = {}
Players.PlayerRemoving:Connect(function(p) lastBuy[p] = nil end)

local buyRemote = buyFn :: RemoteFunction
buyRemote.OnServerInvoke = function(player: Player, itemId: any)
	if typeof(itemId) ~= "string" then return false, "Bad item" end
	local now = os.clock()
	if lastBuy[player] and now - lastBuy[player] < 0.4 then return false, "Slow down" end
	lastBuy[player] = now

	local item = SHOP_ITEMS[itemId]
	if not item then return false, "Unknown item" end
	local balance = Economy.get(player, item.currency)
	if balance < item.price then
		return false, "Need " .. tostring(item.price - balance) .. " more " .. item.currency
	end
	if not Economy.spend(player, item.currency, item.price) then return false, "Not enough " .. item.currency end
	local ok, granted = pcall(item.grant, player)
	if not ok or not granted then
		Economy.add(player, item.currency, item.price) -- refund
		return false, "Try again"
	end
	return true, "Bought!"
end
