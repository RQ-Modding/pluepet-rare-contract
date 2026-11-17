# Pluepet Rare Contract

Lost a Rare Item? The Pluepet Company finds it again, for a price.

## What it changes

- **Pluepet Rare Finds**, on Frostbuy's Items and Other rack for **50,000 Gold**, while one of your
  Rare Items is lost: sold, donated or discarded, and not owned now. These are the 25 items of the
  Trivia page "Rare Items", groups A and B (Chaos the Darksword can never be lost). An item you never
  found is not lost.
- **A character's own gear** that a chest also brings back, though the Trivia page does not list it:
  Rick's By Road and Leazas Red General Armor, Kouhime's Poison Dango and Crane's Stealth Suit. It
  is lost while its owner is in your roster and you own no copy, as the game's chests count it. It
  has no level; in the 2nd and 3rd worlds the By Road and the Poison Dango come back with the
  world's mark (② or ③), which the copy the character came with never has.
- **One contract at a time.** Rare Finds is not on sale while a contract runs or while nothing is
  lost, and it never comes from a chest. Buying it with nothing lost is refused with "You currently
  have no lost Rare Items."
- **After the purchase**, over the shop, Pluepet asks which of your lost items to find (each one says
  its group and the level it comes back at). Rance has his say the first time, and a few items' owners
  have theirs once per save: Copandon's Omikuji Box, Maria's Tulip 1, Lia's Whip and Clothes, and the
  Oda Armor (Kouhime).
- **The receipt** stays in your vault and says what Pluepet is tracking down and how many quests are
  left. It cannot be sold, donated or discarded.
- **After 3 successful exploration quests** (cleared quests with a map; a quest given up, failed or
  left with an escape device does not count), back in town, Pluepet comes to Rance's Room with the
  item: the game's item moment, the item in your vault at the level a chest would give it back, the
  receipt gone, then the game's autosave.
- **Found it yourself first?** If a chest gave the item back before the delivery, Pluepet brings
  another lost one of your choice, or gives the 50,000 Gold back when nothing else is lost.

## Keys and settings

None.

## Saves

Rare Finds is an item the loader gives the mod (1000 and up); without the mod it shows as a plain
item. The contract (the item tracked and the quests counted) is kept in `rq.savedata` beside the save;
the game ignores it. The scenes seen once are event flags in the save.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.56.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/pluepet-rare-contract/mod.json`.

## How it works

- Lost: the game's own counter of each Rare Item's losses (`FA`, raised when one is sold, donated or
  discarded), at least 1, and none owned (`rq.items()`). A character's gear: the chest's own rule,
  the owner recruited (`rq.chara.is_recruited`) and none owned.
- Frostbuy: `rq.shop.on_stock`, `rq.shop.on_can_buy` (the refusal) and `rq.shop.on_buy`; the item:
  `rq.item.define` with `keep`.
- The scenes: `rq.scene.start`, `s.choice`, `s.seen`, `s.item` (the game's jingle and item card).
- The quests: `rq.quests.on_end`; the delivery: the game's `Ｉ生成` (as a chest makes the item) and
  `rq.saves.autosave`.

## Credits

The contract's icon, `icons/contract.webp`, is AliceSoft's art: CG 6385 of Rance Quest Magnum,
edited for this mod. All rights to it are reserved by AliceSoft; it is not covered by this mod's MIT
license.

## License

MIT, see [LICENSE](LICENSE).
