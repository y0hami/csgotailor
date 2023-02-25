import { getTranslation, repairKV } from '../util'

const WEAPON_TYPES = ['rifle', 'secondary', 'shotgun', 'sniper_rifle', 'machinegun', 'smg']

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const items: any = repairKV(itemsGame.items)
  const prefabs: any = repairKV(itemsGame.prefabs)

  const prefabItems = Object.keys(items)
    .map(key => ({
      key,
      ...items[key]
    }))
    .filter(item => item?.prefab !== undefined)
    .map(item => {
      const prefab = prefabs[item.prefab] ?? {}

      return {
        item,
        prefab,
        type: prefab.prefab
      }
    })
    .filter(item => item.type !== undefined)

  const weaponItems = prefabItems.filter(item =>
    WEAPON_TYPES.includes(item.type))

  const weapons: Weapon[] = weaponItems
    .map(weapon => {
      const item = weapon.item
      const prefab = weapon.prefab
      const teams = Object.keys(prefab.used_by_classes ?? {})

      return {
        defIndex: Number(item.key),
        classname: item.name,
        name: getTranslation(prefab.item_name),
        team: teams.length === 2
          ? 'BOTH'
          : teams.includes('terrorists')
            ? 'T'
            : 'CT',
        stickerSlots: Object.keys(prefab.stickers ?? {}).length,
        paints: []
      }
    })

  weapons
    .sort((a, b) => a.name.localeCompare(b.name))
    .forEach(weapon => {
      data.weapons[weapon.classname] = weapon
    })
}
