-- Pluepet Rare Contract. Frostbuy's Items and Other rack sells "Pluepet Rare Finds" for 50,000 Gold
-- while one of the player's Rare Items is lost (sold, donated or discarded, and not owned now), or a
-- character's own gear that a chest brings back (Rick's By Road and armor, Kouhime's Poison Dango,
-- Crane's Stealth Suit: the character recruited and none owned). After
-- the purchase Pluepet asks which one to find; 3 successful exploration quests later, back in town, it
-- comes to Rance's Room with the item, made as a chest makes it (the level the game gives it on its
-- return), and the game autosaves. One contract at a time; it is never in a chest.
-- Lua owns every rule; the loader gives the purchase's refusal (rq.shop.on_can_buy), the receipt that
-- cannot be sold (keep), the game's item moment in a scene (s.item) and its autosave (loader 2.50.0).

local PRICE = 50000
local QUESTS = 3            -- successful exploration quests before the delivery
local SHOP, VAULT = 6, 7
local PLUEPET, RANCE = 2816, 2005
local MORE = 9999           -- the choice's row for the next page
local PER_PAGE = 18         -- the game's choice menu takes 20 rows and does not scroll

local SALE_INFO = "The Pluepet Company will track$down one of your lost Rare Items...$for a price. "
  .. "Delivered after$3 successful exploration quests."

local FINDS = rq.item.define({
  id = "pluepet-rare-contract:finds",
  name = "Pluepet Rare Finds",
  type = "none",
  classes = {},
  icon = "icons/contract.webp",
  price = PRICE,
  info = SALE_INFO,
  keep = true,
})

-- The rare items -----------------------------------------------------------------

-- The Trivia page's Rare Items: each item number and the counter the game raises each time one is
-- sold, donated or discarded (FA, Ｔアイテム寄付売却捨てる前). A counter of 1 or more and none owned is
-- lost. Chaos the Darksword (100) can never go, so it is not here. owner: whose item the choice says.
local RARE = {
  { no = 7, fa = 240, group = "A", owner = "Lia" },
  { no = 10, fa = 241, group = "A" },
  { no = 27, fa = 243, group = "A" },
  { no = 70, fa = 245, group = "A", owner = "Lia" },
  { no = 69, fa = 246, group = "A", owner = "Copandon" },
  { no = 84, fa = 247, group = "A" },
  { no = 169, fa = 249, group = "A" },
  { no = 171, fa = 250, group = "A", owner = "Maria" },
  { no = 178, fa = 252, group = "A" },
  { no = 125, fa = 305, group = "A" },
  { no = 165, fa = 319, group = "A" },
  { no = 54, fa = 244, group = "B" },
  { no = 24, fa = 242, group = "B" },
  { no = 22, fa = 208, group = "B" },
  { no = 64, fa = 211, group = "B" },
  { no = 40, fa = 209, group = "B" },
  { no = 52, fa = 210, group = "B" },
  { no = 83, fa = 212, group = "B" },
  { no = 97, fa = 213, group = "B" },
  { no = 114, fa = 214, group = "B" },
  { no = 129, fa = 215, group = "B" },
  { no = 144, fa = 216, group = "B" },
  { no = 168, fa = 218, group = "B" },
  { no = 157, fa = 217, group = "B" },
}
-- A character's own gear that a chest also brings back (レアアイテムを選ぶ, the same walk as group A):
-- the character comes with it, and a chest makes another copy while the character is in the roster
-- and none is owned. No counter: lost is the chest's own rule. A chest's copy has no level, but in
-- the 2nd and 3rd worlds an item of kind rank 11, 21 or 31 gets the world's mark (Ｉ生成／データ１),
-- which the copy the character came with never has (made with キャラ生成時): world_mark.
local GEAR = {
  { no = 2, chara = 23, owner = "Crane" },                        -- Stealth Suit, rank 41
  { no = 118, chara = 20, owner = "Kouhime", world_mark = true }, -- Poison Dango, rank 11
  { no = 131, chara = 93, owner = "Rick", world_mark = true },    -- By Road, rank 31
  { no = 34, chara = 93, owner = "Rick" },                        -- Leazas Red General Armor, rank 30
}

local RARE_OF = {}
for _, r in ipairs(RARE) do RARE_OF[r.no] = r end
for _, g in ipairs(GEAR) do RARE_OF[g.no] = g end

-- A character's line once per item, in each save: face and line, in order.
local EGGS = {
  [69] = { { 2291, "\"Rance! Quit tossin' my box away! Do it one more time and I'll beat ya up, I mean it!\"" } },
  [171] = { { 2770, "\"Tulip 1 got lost...? H-How did that even happen?\"" } },
  [70] = {
    { 2150, "\"Oh, Darling, you care about me so much!\"" },
    { 2151, "\"Eheheh... We can put that whip to good use later, if you want.\"" },
  },
  [7] = {
    { 2152, "\"Darling, you meanie!!\"" },
    { 2151, "\"If you wanted to see me naked, you could've just asked!\"" },
  },
  [27] = { { 2113, "\"Th-That armor... I hope it isn't broken...\"" } },
}

local CIRCLED = { "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨" }

local function name_of(no)
  local ok, info = pcall(rq.item.info, no)
  if ok and info and info.name and info.name ~= "" then return info.name end
  return "Rare Item " .. no
end

local function counter(r)
  if not r.fa then return 0 end
  local ok, n = pcall(rq.ain.global, "FA", r.fa)
  return ok and math.type(n) == "integer" and n or 0
end

local function recruited(chara)
  local ok, yes = pcall(rq.chara.is_recruited, chara)
  return ok and yes == true
end

-- The world's mark a chest's copy of this gear gets now (2 or 3), or nil.
local function world_mark(g)
  if not g.world_mark then return nil end
  local ok, w = pcall(rq.world.current)
  if ok and math.type(w) == "integer" and w >= 2 then return w end
  return nil
end

-- The level a copy made now has (Ｉ生成 reads the counter for these items, at most 9).
local function level_of(r)
  return math.max(1, math.min(9, counter(r)))
end

-- Item numbers the player owns now, where the game counts them (Ｉ有無: the vault, the storage,
-- quest storage, worn).
local function owned_set()
  local set = {}
  for _, row in ipairs(rq.items()) do
    local p = row.place
    if p == VAULT or p == 11 or p == 8 or (p and p >= 20) then set[row.no] = true end
  end
  return set
end

local function owned(no)
  return owned_set()[no] == true
end

-- The lost rare items, in the Trivia page's order, then the characters' gear in the chest's order:
-- { no, name, comment }.
local function lost_list()
  local have = owned_set()
  local out = {}
  for _, r in ipairs(RARE) do
    if counter(r) >= 1 and not have[r.no] then
      local who = r.owner and (", " .. r.owner .. "'s") or ""
      out[#out + 1] = {
        no = r.no,
        name = name_of(r.no),
        comment = ("Rare Item %s%s.\nIt comes back at %s."):format(r.group, who, CIRCLED[level_of(r)]),
      }
    end
  end
  for _, g in ipairs(GEAR) do
    if recruited(g.chara) and not have[g.no] then
      local w = world_mark(g)
      out[#out + 1] = {
        no = g.no,
        name = name_of(g.no),
        comment = w and ("%s's gear.\nIt comes back at %s, this world's mark."):format(g.owner, CIRCLED[w])
          or ("%s's gear.\nIt comes back as it was."):format(g.owner),
      }
    end
  end
  return out
end

-- The contract, kept in the save -----------------------------------------------------------------

-- { ii = the receipt, target = the item number (nil until chosen), quests = successful quests }
local function contract()
  local c = rq.savedata.get("contract")
  if type(c) ~= "table" then return nil end
  return c
end

local function set_contract(c)
  rq.savedata.set("contract", c)
end

local function receipt_text(c)
  if not c.target then return SALE_INFO end
  local left = QUESTS - (c.quests or 0)
  local head = "Pluepet is tracking down:$" .. name_of(c.target) .. ".$"
  if left <= 0 then return head .. "Delivery when you're back$in town!" end
  return head .. ("Delivery after %d more successful$exploration quest%s."):format(left, left == 1 and "" or "s")
end

local function update_receipt(c)
  if c and c.ii and rq.item.get(c.ii) then rq.item.set(c.ii, { info = receipt_text(c) }) end
end

-- The receipt in the vault, the storage or worn (never: it has no class), or nil.
local function receipt()
  local list = rq.item.find(FINDS, { place = { "vault", "storage", "quest", "worn" } })
  return list[1]
end

-- The receipt each scene last started for: one try per contract and load, so a scene that fails
-- does not start again each frame. A contract that opens or ends clears them: the game gives a
-- removed receipt's instance number to the next item it makes, the next receipt too.
local asked_for, delivered_for

-- Ends the contract: the receipt goes.
local function close_contract(c)
  asked_for, delivered_for = nil, nil
  if c and c.ii and rq.item.get(c.ii) then rq.item.remove(c.ii) end
  for _, ii in ipairs(rq.item.find(FINDS, { place = { "vault", "storage", "quest", "worn" } })) do
    rq.item.remove(ii)
  end
  set_contract(nil)
end

-- Frostbuy ------------------------------------------------------------------------------------

local function on_sale()
  return rq.item.find(FINDS, { place = SHOP })
end

-- One copy on the Items and Other rack while no contract runs and something is lost; none otherwise.
local function stock()
  local want = not contract() and not receipt() and #lost_list() > 0
  local shelf = on_sale()
  for i, ii in ipairs(shelf) do
    if not want or i > 1 then rq.item.remove(ii) end
  end
  if want and #shelf == 0 then rq.shop.stock(FINDS) end
end

rq.shop.on_stock(stock)

rq.shop.on_can_buy(function(ctx)
  if ctx.no ~= FINDS then return end
  if contract() or receipt() then return false, "Pluepet is already tracking down one of your Rare Items." end
  if #lost_list() == 0 then return false, "You currently have no lost Rare Items." end
end)

rq.shop.on_buy(function(ctx)
  if ctx.no ~= FINDS then return end
  asked_for, delivered_for = nil, nil
  set_contract({ ii = ctx.ii, quests = 0, paid = ctx.price })
end)

-- The scenes -----------------------------------------------------------------------------------

-- The lost items in the game's choice menu, 18 to a page with "More..." past 19.
local function pick(s, list)
  local page = 1
  local paged = #list > PER_PAGE + 1
  local pages = paged and math.ceil(#list / PER_PAGE) or 1
  while true do
    local rows = {}
    local from = paged and (page - 1) * PER_PAGE + 1 or 1
    local to = paged and math.min(#list, from + PER_PAGE - 1) or #list
    for i = from, to do
      local e = list[i]
      rows[#rows + 1] = { id = e.no, text = e.name, comment = e.comment }
    end
    if paged then
      rows[#rows + 1] = { id = MORE, text = page < pages and "More..." or "Back...",
        comment = page < pages and "The other lost Rare Items." or "The first page." }
    end
    local no = s.choice(rows)
    if no ~= MORE and RARE_OF[no] then return no end
    page = page % pages + 1
  end
end

local function say(s, face, text, o)
  s.say(face, text, o)
end

-- Whether the delivery's autosave waits for the scene's end.
local save_after = false

local function refund(s, c)
  say(s, PLUEPET, "\"And there's nothing left to find... Then here are your 50,000 Gold back. "
    .. "The Pluepet Company is an honest business! Heheh~\"")
  rq.game.add_gold(c.paid or PRICE)
  close_contract(c)
  save_after = true
end

-- Over Frostbuy, after the purchase: the choice, then Rance's and the item's lines once.
local function purchase_scene(s)
  local c = contract()
  if not c or c.target then return end
  local list = lost_list()
  say(s, PLUEPET, "\"Hellooo! Thanks very much for choosing the Pluepet Company's finding services, Mr. Rance!\"")
  if #list == 0 then
    refund(s, c)
    return
  end
  say(s, PLUEPET, "\"Now then, which of your lost treasures shall we track down?\"", { wait = false })
  local no = pick(s, list)
  s.clear_text()
  c.target = no
  c.quests = c.quests or 0
  set_contract(c)
  update_receipt(c)
  local name = name_of(no)
  say(s, PLUEPET, ("\"The %s! Heheh~ We've already picked up its trail.\""):format(name))
  say(s, PLUEPET, "\"We'll have it delivered to your castle by the time you've cleared 3 quests. See ya!\"")
  if not s.seen("pluepet-rare-contract:rance") then
    s.seen("pluepet-rare-contract:rance", true)
    say(s, RANCE, "\"Uh, yeah. Just find that shit already.\"")
    say(s, RANCE, "\"Who knew it'd be such a damn pain to get that stuff back...\"")
  end
  local egg = EGGS[no]
  local flag = "pluepet-rare-contract:item-" .. no
  if egg and not s.seen(flag) then
    s.seen(flag, true)
    for _, l in ipairs(egg) do say(s, l[1], l[2]) end
  end
end

-- The item as a chest makes it (its level from the game's counter), in the vault.
local function make(no)
  local ii = rq.ain.call("Ｉ生成", no, 0)
  if math.type(ii) ~= "integer" or ii <= 0 then return nil end
  rq.item.set(ii, { place = VAULT })
  return ii
end

-- In Rance's Room, back in town after the third quest.
local function delivery_scene(s)
  local c = contract()
  if not c or not c.target or (c.quests or 0) < QUESTS then return end
  s.set(5510, 5280, 0, 0)
  s.music(93)
  s.narrate("\n <clack>")
  local no = c.target
  if owned(no) then
    say(s, PLUEPET, ("\"Oh my! It seems you found the %s on your own, Mr. Rance.\""):format(name_of(no)))
    local list = lost_list()
    if #list == 0 then
      refund(s, c)
      return
    end
    say(s, PLUEPET, "\"Not to worry! We've kept an eye on your other lost treasures too. Which one shall we bring?\"",
      { wait = false })
    no = pick(s, list)
  else
    say(s, PLUEPET, "\"Hellooo! Mr. Rance, the Pluepet Company has found the equipment you requested!\"")
  end
  s.clear_text()
  local ii = make(no)
  if not ii then
    rq.log("Pluepet Rare Contract: the game has no free item slot; the money goes back")
    refund(s, c)
    return
  end
  close_contract(c)
  rq.log(("Pluepet Rare Contract: delivered %s (item %d, instance %d)"):format(name_of(no), no, ii))
  s.item(ii)
  say(s, PLUEPET, "\"Thanks very much for your order! Feel free to call on us again if anything else goes missing. Heheh~\"")
  save_after = true
end

-- The quests ------------------------------------------------------------------------------------

-- A cleared quest with a map counts (as Return Bonsai counts a bonsai's uses): given up, failed or
-- left with an escape device, it does not.
local function quest_end(ctx)
  local c = contract()
  if not c or not c.target or (c.quests or 0) >= QUESTS or not ctx.cleared then return end
  local ok, q = pcall(rq.quests.get, ctx.quest)
  if not ok or not q or q.kind ~= "quest" then return end
  c.quests = (c.quests or 0) + 1
  set_contract(c)
  update_receipt(c)
end

rq.quests.on_end(quest_end)

-- Each frame: the purchase's scene, the delivery, the autosave after it ----------------------------------

-- The footer's mode (システムバー_モード): 10 the hub, 12 Frostbuy. rq.ui.get builds the whole screen,
-- so it only confirms, every 15 frames.
local HUB, FROSTBUY = 10, 12
local SHOP_SCREENS = { ["shop-buy"] = true, frostbuy = true, hub = true }
local tick = 0

local function footer()
  local ok, mode = pcall(rq.ain.call, "システムバー_モード")
  return ok and mode or -1
end

rq.on_frame(function()
  if rq.scene.active() then return end
  local c = contract()
  if not c and not save_after then return end
  tick = tick + 1
  if tick % 15 ~= 0 then return end
  local mode = footer()
  if save_after then
    if mode ~= HUB or rq.ui.get().screen ~= "hub" then return end
    save_after = false
    local ok, why = rq.saves.autosave()
    if not ok then rq.log("Pluepet Rare Contract: no autosave (" .. tostring(why) .. ")") end
    return
  end
  if not c.target then
    if asked_for ~= c.ii and (mode == HUB or mode == FROSTBUY) and SHOP_SCREENS[rq.ui.get().screen] then
      if rq.scene.start(purchase_scene) then asked_for = c.ii end
    end
  elseif (c.quests or 0) >= QUESTS then
    if delivered_for ~= c.ii and mode == HUB and rq.ui.get().screen == "hub" then
      if rq.scene.start(delivery_scene) then delivered_for = c.ii end
    end
  end
end)

-- A receipt without a contract (the save's mod data lost): Pluepet asks again.
rq.saves.on_load(function()
  if contract() then return end
  local ii = receipt()
  if ii then set_contract({ ii = ii, quests = 0 }) end
end)

rq.on_reset(function()
  save_after, asked_for, delivered_for = false, nil, nil
end)

rq.log(("Pluepet Rare Contract: item %d"):format(FINDS))

-- For the Lab and other mods.
return {
  FINDS = FINDS,
  PRICE = PRICE,
  QUESTS = QUESTS,
  RARE = RARE,
  GEAR = GEAR,
  EGGS = EGGS,
  lost_list = lost_list,
  owned = owned,
  -- The level a copy made now has: the counter's, 0 for a character's gear.
  level_of = function(no)
    local r = RARE_OF[no]
    if not r then return nil end
    return r.fa and level_of(r) or 0
  end,
  world_mark = function(no) return RARE_OF[no] and world_mark(RARE_OF[no]) or nil end,
  receipt_text = receipt_text,
  stock = stock,
  -- The rq.quests.on_end callback, for a test that counts quests without playing them.
  quest_end = quest_end,
  -- The mod's rq.savedata, read and written from its own file (the store is the caller's mod's).
  contract = contract,
  set_contract = function(c)
    set_contract(c)
    update_receipt(c)
  end,
  -- Lets a test start a scene again after it ran once since the load.
  rearm = function() asked_for, delivered_for = nil, nil end,
}
