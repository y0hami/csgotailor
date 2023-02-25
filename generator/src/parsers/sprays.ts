import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const stickerKits = repairKV(itemsGame.sticker_kits)

  Object.keys(stickerKits)
    .map(key => ({
      defIndex: Number(key),
      ...stickerKits[key]
    }))
    .filter((spray: any) => spray.item_name.startsWith('#SprayKit') === true ||
      spray.name.startsWith('spray_') === true ||
      spray.name.endsWith('_graffiti') === true)
    .map((spray: any) => ({
      defIndex: spray.defIndex,
      classname: spray.name,
      name: getTranslation(spray.item_name),
      material: spray.sticker_material,
      rarity: spray.item_rarity
    }))
    .filter((spray: any) => spray.name !== undefined)
    .sort((a: any, b: any) => a.name.localeCompare(b.name))
    .forEach(spray => {
      data.sprays[spray.classname] = spray
    })
}
