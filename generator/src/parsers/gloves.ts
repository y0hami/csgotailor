import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const items = repairKV(itemsGame.items)

  const gloves: Gloves[] = Object.keys(items)
    .map((defIndex) => ({
      defIndex: Number(defIndex),
      ...items[defIndex]
    }))
    .filter((item: any) => item.prefab === 'hands_paintable')
    .map(item => ({
      defIndex: item.defIndex,
      classname: item.name,
      name: getTranslation(item.item_name),
      paints: []
    }))

  const icons = Object.values(itemsGame.alternate_icons2.weapon_icons)
    .map((icon: any) => icon.icon_path)
    .map((icon: string) => {
      const [, paint] = icon
        .match(/^econ\/default_generated\/(.*?)_light$/) ?? []
      return paint
    })
    .filter(icon => icon !== undefined)

  gloves.forEach(glove => {
    const glovePaints = icons.filter(icon =>
      icon.startsWith(glove.classname))
      .map(p => p.replace(`${glove.classname}_`, ''))
      .map(paintClassname =>
        Object.values(data.paints).find((p: any) =>
          p.classname === paintClassname))

    glove.paints = (glovePaints as Paint[])
      .sort((a, b) => a.name.localeCompare(b.name))
      .map(p => p.classname)
  })

  gloves.forEach(glove => {
    data.gloves[glove.classname] = glove
  })
}
