import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const items = repairKV(itemsGame.items)

  Object.keys(items)
    .map(i => ({
      defIndex: Number(i),
      ...items[i]
    }))
    .filter((item: any) => item.prefab === 'attendance_pin')
    .map((pin: any) => {
      const classname = pin.image_inventory.split('/')

      return {
        defIndex: Number(pin.defIndex),
        classname: classname[classname.length - 1],
        name: getTranslation(pin.item_name).replace('Pin', '').trim(),
        rarity: pin.item_rarity
      }
    })
    .sort((a: any, b: any) => a.name.localeCompare(b.name))
    .forEach(pin => {
      data.pins[pin.classname] = pin
    })
}
