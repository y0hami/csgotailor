import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const stickerKits = repairKV(itemsGame.sticker_kits)
  const kits = Object.keys(stickerKits)
    .map(key => ({
      defIndex: Number(key),
      ...stickerKits[key]
    }))

  const patches = kits.filter(kit => kit.defIndex !== 0 && kit.item_name.startsWith('#PatchKit'))
  kits.forEach(kit => {
    if (kit.name.includes('teampatch') === true) {
      patches.push(kit)
    }
  })

  patches
    .map(patch => ({
      defIndex: patch.defIndex,
      classname: patch.name,
      name: getTranslation(patch.item_name),
      rarity: patch.item_rarity
    }))
    .sort((a, b) => a.name.localeCompare(b.name))
    .forEach(patch => {
      data.patches.patches[patch.classname] = patch
    })
}
