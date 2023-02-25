import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const items = repairKV(itemsGame.items)
  const lootLists = repairKV(itemsGame.client_loot_lists)

  const capsules: StickerCapsule[] = Object.keys(items)
    .filter(key => key !== 'default')
    .map(key => ({
      defIndex: Number(key),
      ...items[key]
    }))
    .filter(item => item.prefab === 'sticker_capsule')
    .map(capsule => {
      const lists = lootLists[capsule.name] ??
        lootLists[`${capsule.name as string}_lootlist`]

      const stickers = Object.keys(lists)
        .map(crate => Object.keys(lootLists[crate]))
        .reduce((acc, cv) => [...acc, ...cv], [])
        .map(item => (item.match(/^\[(.*?)\]sticker$/) ?? [])[1])
        .filter(classname => classname !== undefined)
        .map(classname => data.stickers.stickers[classname])

      return {
        defIndex: capsule.defIndex,
        classname: capsule.name,
        name: getTranslation(capsule.item_name),
        stickers: stickers.sort((a, b) => a.name.localeCompare(b.name))
          .map(s => s.classname)
      }
    })

  capsules
    .sort((a, b) => a.defIndex - b.defIndex)
    .forEach(capsule => {
      data.stickers.capsules[capsule.classname] = capsule
    })
}
