import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  itemsGame.paint_kits_rarity = repairKV(itemsGame.paint_kits_rarity)

  Object.keys(itemsGame.rarities)
    .forEach(key => {
      const rarity = itemsGame.rarities[key]

      data.rarities[key as RarityKey] = {
        name: getTranslation(rarity.loc_key),
        paint: getTranslation(rarity.loc_key_weapon),
        agent: getTranslation(rarity.loc_key_character)
      }
    })
}
