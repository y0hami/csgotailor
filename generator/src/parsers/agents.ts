import { getTranslation, repairKV } from '../util'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const items = repairKV(itemsGame.items)

  Object.keys(items)
    .map(key => ({
      defIndex: Number(key),
      ...items[key]
    }))
    .filter((item: any) => (item.name as string).startsWith('customplayer_tm') || (item.name as string).startsWith('customplayer_ctm'))
    .map((agent: any) => {
      const [name, faction] = (getTranslation(agent.item_name) ?? ' | ').split('|')

      return {
        defIndex: agent.defIndex,
        classname: agent.name,
        name: name.trim(),
        faction: faction.trim(),
        team: agent.used_by_classes?.terrorists !== undefined
          ? 'T'
          : 'CT',
        model: agent.model_player,
        rarity: agent.item_rarity
      }
    })
    .filter((agent: any) => agent.name !== '')
    .sort((a, b) =>
      a.name.replace(/'/g, '').localeCompare(b.name.replace(/'/g, '')))
    .forEach(agent => {
      data.agents[agent.classname] = agent
    })
}
