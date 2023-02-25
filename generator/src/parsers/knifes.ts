import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const items = repairKV(itemsGame.items)

  const knifes: Knife[] = Object.keys(items)
    .map((defIndex) => ({
      defIndex: Number(defIndex),
      ...items[defIndex]
    }))
    .filter((item: any) => item.prefab === 'melee_unusual')
    .map((item: any) => ({
      defIndex: item.defIndex,
      classname: item.name,
      name: getTranslation(item.item_name),
      paints: []
    }))
    .sort((a: any, b: any) => a.name.localeCompare(b.name))

  const icons = Object.values(itemsGame.alternate_icons2.weapon_icons)
    .map((icon: any) => icon.icon_path)
    .map((icon: string) => {
      const [, paint] = icon
        .match(/^econ\/default_generated\/(.*?)_light$/) ?? []
      return paint
    })
    .filter(icon => icon !== undefined)

  knifes.forEach(knife => {
    const knifePaints = icons.filter(icon =>
      icon.startsWith(knife.classname))
      .map(p => p.replace(`${knife.classname}_`, ''))
      .map(paintClassname =>
        Object.values(data.paints).find(p => p.classname === paintClassname))

    knife.paints = (knifePaints as Paint[])
      .sort((a, b) => a.name.localeCompare(b.name))
      .map(p => p.classname)
  })

  knifes.forEach(knife => {
    data.knifes[knife.classname] = knife
  })
}
