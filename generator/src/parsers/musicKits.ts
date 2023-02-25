import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const kits = repairKV(itemsGame.music_definitions)

  Object.keys(kits)
    .map((defIndex: any) => ({
      defIndex: Number(defIndex),
      ...kits[defIndex]
    }))
    .filter((mk: any) => !(mk.name as string).startsWith('valve_csgo'))
    .map((mk: any) => {
      const [artists, ...name]: string[] = getTranslation(mk.loc_name).split(',')

      return {
        defIndex: mk.defIndex,
        classname: mk.name,
        name: name.join(' ').trim(),
        artists: artists.trim()
      }
    })
    .sort((a: any, b: any) => a.name.localeCompare(b.name))
    .forEach(musicKit => {
      data.music_kits[musicKit.classname] = musicKit
    })
}
