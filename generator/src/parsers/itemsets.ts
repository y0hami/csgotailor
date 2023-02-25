import { getTranslation, repairKV } from '../util'
import STATIC_SKINS from '../static/skins.json'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  itemsGame.item_sets = repairKV(itemsGame.item_sets)

  const sets: ItemSet[] = Object.keys(itemsGame.item_sets)
    .filter(key => !key.includes('characters'))
    .map(key => ({
      classname: key,
      ...itemsGame.item_sets[key]
    }))
    .map(set => ({
      classname: set.classname,
      name: getTranslation(set.name),
      items: Object.keys(set.items)
        .map(item => {
          const [, paint, weapon]: string[] = item
            .match(/^\[(.*?)\](.*?)$/) ?? []
          return {
            paint,
            weapon
          }
        })
    }))

  const weaponPaints: Record<string, Paint[]> = {}

  // loop item sets and add the paint to the corresponding weapons
  sets.forEach(set => {
    set.items.forEach(item => {
      const paint = Object.values(data.paints).find(p =>
        p.classname === item.paint)
      const weapon = Object.values(data.weapons).find(w =>
        w.classname === item.weapon)

      if (paint !== undefined && weapon !== undefined) {
        if (weaponPaints[weapon.classname] === undefined) {
          weaponPaints[weapon.classname] = []
        }

        weaponPaints[weapon.classname].push(paint)
      }
    })
  })

  // add any missing skins to the weapons (currently only Howl for M4A4)
  Object.keys(STATIC_SKINS).forEach(weaponClassname => {
    (STATIC_SKINS as any)[weaponClassname].forEach((defIndex: number) => {
      const paint = Object.values(data.paints).find(p =>
        p.defIndex === defIndex)
      const weapon = Object.values(data.weapons).find(w =>
        w.classname === weaponClassname)

      if (paint !== undefined && weapon !== undefined) {
        if (weaponPaints[weapon.classname] === undefined) {
          weaponPaints[weapon.classname] = []
        }

        weaponPaints[weapon.classname].push(paint)
      }
    })
  })

  // sort weapon skins A-Z
  Object.values(data.weapons).forEach(weapon => {
    weapon.paints = weaponPaints[weapon.classname]
      .sort((a, b) => a.name.localeCompare(b.name))
      .map(p => p.classname)
  })

  data.item_sets = sets
}
