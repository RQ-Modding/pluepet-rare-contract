# Testing Pluepet Rare Contract

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Loading pluepet-rare-contract` and the line `Pluepet Rare Contract: item <n>`, which gives Rare
Finds' number.

## What it adds

- **Frostbuy:** Pluepet Rare Finds on the Items and Other rack (`rack-items`), 50,000 Gold, when a
  Rare Item is lost and no contract runs. It is restocked on a visit (`rq.shop.on_stock`).
- **Lost:** a Trivia Rare Item whose `FA` counter is 1 or more with no copy owned; or a character's
  gear (`GEAR`: Stealth Suit 2 of Crane 23, Poison Dango 118 of Kouhime 20, By Road 131 and Leazas
  Red General Armor 34 of Rick 93) with its owner recruited and no copy owned, the rule of the
  chest's rare pick. Gear rows come after the Trivia items; their comment is "<owner>'s gear." and
  "It comes back as it was.", or "It comes back at ②, this world's mark." (③) for the By Road and
  the Poison Dango in the 2nd and 3rd worlds, where the game's copy is named "By Road ②".
- **The refusal:** buying it with nothing lost (the rack's drag or `rq.item.buy`) shows the game's
  notice "You currently have no lost Rare Items." (`select`, one button, OK, which `rqmod-ctl` names
  `yes`). With a contract running: "Pluepet is already tracking down one of your Rare Items."
- **The purchase scene**, over the shop, at the next frames after the purchase: Pluepet's lines, then
  the game's choice menu with one row per lost item (each row's id from its label, the item's name;
  each row's comment its group and level). No Return row: an item must be chosen. Past 19 lost items, a "More..." row turns the page. A long page goes up to fit on the screen (loader 2.56.0): page 1 runs from about y 132 to 759.
- **The receipt** in the vault: its text names the item and the quests left. DISCARD, SELL and
  DONATE refuse it.
- **The delivery**, on the hub once 3 quests are counted: Rance's Room, Pluepet's line, the game's
  item card (a click closes it; while it shows, `rq.ui.get` lists the hub under it), Pluepet's last
  line; then the game's "~~Auto-Saving~~" message on the hub.
- **Log:** `Pluepet Rare Contract: delivered <name> (item <no>, instance <ii>)`, and
  `Pluepet Rare Contract: no autosave (<why>)` when the game did not save.

## How to check it

1. Sell or donate a Rare Item (the Omikuji Box, say). Leave Frostbuy and come back: Rare Finds is on
   the Items and Other rack.
2. Buy it. Pluepet thanks you and asks which item; pick one. The first time, Rance has two lines;
   the Omikuji Box, Tulip 1, Lia's Whip, Lia's Clothes and the Oda Armor have one owner's line once.
3. The receipt is in the vault: `Delivery after 3 more successful exploration quests.` DISCARD, SELL
   and DONATE refuse it, and Rare Finds is no longer on the rack.
4. Clear 3 quests with a map. Back on the hub, Pluepet comes with the item: it is in the vault at the
   level the item card shows, the receipt is gone, and the game autosaved.
5. Give up a quest, or clear one without a map: the count does not move.
6. With Rick (93) recruited, sell his By Road: Rare Finds is on the rack, and the choice lists the
   By Road as "Rick's gear.". Its delivery is a chest's copy, no level (`rarity` 0); in the 2nd or
   3rd world it is named "By Road ②" or "By Road ③". With Rick not recruited, a missing By Road is
   not lost.

## Forcing it for a test

`require("pluepet-rare-contract")` (from another mod) or `rq.mod.get("pluepet-rare-contract")`
returns `FINDS`, `PRICE`, `QUESTS`, `RARE` (the items, with their `FA` counters), `GEAR` (the
characters' gear: `no`, `chara`, `owner`, `world_mark`), `EGGS` (the owners' lines by item number),
`lost_list()`, `owned(no)`, `level_of(no)` (0 for gear), `world_mark(no)` (2 or 3 when a copy made now
has the world's mark, else nil), `receipt_text(c)`, `stock()`, `quest_end(ctx)` (the `rq.quests.on_end`
callback: `{ quest = no, cleared = true }`), `contract()`, `set_contract(c)` (`{ ii, target,
quests, paid }` or nil; it also rewrites the receipt's text) and `rearm()`, which lets a scene start
again for the same contract after it ran since the load. A lost item can be made by setting its
counter (`rq.ain.set_global("FA", 246, 1)` for the Omikuji Box) and removing every copy. Do not
hide an owned copy by setting its place to 0: that is a free slot, and the next item the game makes
(`rq.item.info` makes one) can take it over. Work on a copy of the save.

## Test Lab

`rare-contract` (with this mod installed): the lost list from the counters, the stock rule, the
refusal (the game's drag and `rq.item.buy`), the receipt that cannot go, the purchase scene with its
lines once, the quests counted, the delivery's item, level and autosave, an item found before the
delivery, and the characters' gear: lost by the chest's rule, the world's mark in the 2nd world, a
gear's delivery (the Lab save is missing Kouhime's Poison Dango) and its row on the second page.
