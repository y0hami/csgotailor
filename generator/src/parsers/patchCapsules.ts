import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const items = repairKV(itemsGame.items)
  const lootLists = repairKV(itemsGame.client_loot_lists)

  const capsules: PatchCapsule[] = Object.keys(items)
    .filter(key => key !== 'default')
    .map(key => ({
      defIndex: Number(key),
      ...items[key]
    }))
    .filter(item => item.prefab === 'patch_capsule')
    .map(capsule => {
      const patches = Object.keys(lootLists[capsule.name])
        .map(crate => Object.keys(lootLists[crate]))
        .reduce((acc, cv) => [...acc, ...cv], [])
        .map(item => (item.match(/^\[(.*?)\]patch$/) ?? [])[1])
        .map(classname => data.patches.patches[classname])

      return {
        defIndex: capsule.defIndex,
        classname: capsule.name,
        name: getTranslation(capsule.item_name),
        patches: patches.sort((a, b) => a.name.localeCompare(b.name))
          .map(p => p.classname)
      }
    })

  capsules
    .sort((a, b) => a.defIndex - b.defIndex)
    .forEach(capsule => {
      data.patches.capsules[capsule.classname] = capsule
    })
}
