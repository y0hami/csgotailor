declare type Team = 'CT' | 'T' | 'BOTH'

declare type RarityKey = 'default' | 'common' | 'uncommon' | 'rare' | 'mythical'
| 'legendary' | 'ancient' | 'immortal' | 'unusual'

declare interface Data {
  weapons: {
    [classname: string]: Weapon
  }
  knifes: {
    [classname: string]: Knife
  }
  gloves: {
    [classname: string]: Gloves
  }
  paints: {
    [classname: string]: Paint
  }
  stickers: {
    capsules: {
      [classname: string]: StickerCapsule
    }
    stickers: {
      [classname: string]: Sticker
    }
    teams: {
      [team: string]: {
        id: string
        key: string
        name: string
        geo: string
        stickers: string[]
      }
    }
    players: {
      [player: string]: {
        id: number
        code: string
        name: string
        geo: string
        stickers: string[]
      }
    }
  }
  agents: {
    [classname: string]: Agent
  }
  patches: {
    capsules: {
      [classname: string]: PatchCapsule
    }
    patches: {
      [classname: string]: Patch
    }
  }
  music_kits: {
    [classname: string]: MusicKit
  }
  pins: {
    [classname: string]: Pin
  }
  ranks: {
    [index: number]: Rank
  }
  xp_levels: {
    [index: number]: XPLevel
  }
  sprays: {
    [classname: string]: Spray
  }
  item_sets: ItemSet[]
  rarities: {
    [key in RarityKey]: Rarity
  }
}

declare interface PaintSeedPreset {
  name: string
  value: number
}

declare interface Paint {
  defIndex: number
  classname: string
  name: string
  rarity: RarityKey
  seeds?: {
    [classname: string]: PaintSeedPreset[]
  }
}

declare interface Weapon {
  defIndex: number
  classname: string
  name: string
  team: Team
  stickerSlots: number
  paints: string[]
}

declare interface Knife {
  defIndex: number
  classname: string
  name: string
  paints: string[]
}

declare interface Gloves {
  defIndex: number
  classname: string
  name: string
  paints: string[]
}

declare interface Sticker {
  defIndex: number
  classname: string
  name: string
  rarity: RarityKey
}

declare interface StickerCapsule {
  defIndex: number
  classname: string
  name: string
  stickers: string[]
}

declare interface Agent {
  defIndex: number
  classname: string
  name: string
  faction: string
  model: string
  rarity: RarityKey
}

declare interface Patch {
  defIndex: number
  classname: string
  name: string
  rarity: RarityKey
}

declare interface PatchCapsule {
  defIndex: number
  classname: string
  name: string
  patches: string[]
}

declare interface MusicKit {
  defIndex: number
  classname: string
  name: string
  artists: string
}

declare interface Pin {
  defIndex: number
  classname: string
  name: string
  rarity: RarityKey
}

declare interface Rank {
  index: number
  name: string
}

declare interface XPLevel {
  index: number
  name: string
}

declare interface Spray {
  defIndex: number
  classname: string
  name: string
  material: string
  rarity: RarityKey
}

declare interface ItemSetItem {
  paint: string
  weapon: WeaponClass
}

declare interface ItemSet {
  classname: string
  name: string
  items: ItemSetItem[]
}

declare interface Rarity {
  name: string
  paint: string
  agent: string
}
