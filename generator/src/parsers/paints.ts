import { getTranslation, repairKV } from '../util'
import STATIC_SEEDS from '../static/seeds.json'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const paintKits = repairKV(itemsGame.paint_kits)

  const paints: Paint[] = Object.keys(paintKits)
    .map(key => ({
      defIndex: Number(key),
      ...paintKits[key]
    }))
    .filter(paint => paint.defIndex !== 0 && paint.description_tag)
    .map(paint => {
      const classname: string = paint.name
      let name = getTranslation(paint.description_tag)

      if (classname.includes('_phase1')) {
        name += ' (Phase 1)'
      } else if (classname.includes('_phase2')) {
        name += ' (Phase 2)'
      } else if (classname.includes('_phase3')) {
        name += ' (Phase 3)'
      } else if (classname.includes('_phase4')) {
        name += ' (Phase 4)'
      } else if (classname.includes('emerald_marbleized')) {
        name += ' (Emerald)'
      } else if (classname.includes('sapphire_marbleized')) {
        name += ' (Sapphire)'
      } else if (classname.includes('blackpearl_marbleized')) {
        name += ' (Black Pearl)'
      } else if (classname.includes('ruby_marbleized')) {
        name += ' (Ruby)'
      }

      return {
        defIndex: paint.defIndex,
        classname,
        name,
        rarity: itemsGame.paint_kits_rarity[classname],
        seeds: (STATIC_SEEDS as any)[classname]
      }
    })

  // add default paint
  paints.push({
    defIndex: 0,
    classname: 'DEFAULT',
    name: 'Default',
    rarity: 'default'
  })

  paints.sort((a, b) => a.name.localeCompare(b.name))
    .forEach(paint => {
      data.paints[paint.classname] = paint
    })
}
