import { getTranslation, repairKV } from '../util'
import STATIC_TEAMS from '../static/teams.json'

export const parse = async (itemsGame: any, data: Data): Promise<void> => {
  const stickerKits = repairKV(itemsGame.sticker_kits)

  const kits = Object.keys(stickerKits)
    .map(key => ({
      defIndex: Number(key),
      ...stickerKits[key]
    }))
    .filter(sticker => sticker.defIndex !== 0 && sticker.item_name.startsWith('#StickerKit'))
    .filter(sticker => sticker.name.includes('_teampatch_') === false &&
      sticker.name.endsWith('graffiti') === false)

  const players = Object.keys(itemsGame.pro_players).map(key => ({
    id: Number(key),
    ...itemsGame.pro_players[key]
  }))

  const teams = Object.keys(itemsGame.pro_teams).map(key => ({
    id: Number(key),
    ...itemsGame.pro_teams[key]
  }))

  const stickers: Sticker[] = []
  const teamStickers: Record<string, any> = {}
  const playerStickers: Record<string, any> = {}

  // const convert = (sticker: any): Sticker => ({
  //   defIndex: sticker.defIndex,
  //   classname: sticker.name,
  //   name: getTranslation(sticker.item_name) ?? sticker.name,
  //   rarity: sticker.item_rarity
  // })

  kits.forEach(sticker => {
    stickers.push({
      defIndex: sticker.defIndex,
      classname: sticker.name,
      name: getTranslation(sticker.item_name) ?? sticker.name,
      rarity: sticker.item_rarity
    })

    if (sticker.tournament_player_id !== undefined) {
      const player = players
        .find(p => p.id === Number(sticker.tournament_player_id))

      if (playerStickers[player.code] === undefined) {
        playerStickers[player.code] = {
          id: Number(player.id),
          code: player.code,
          name: player.name,
          geo: player.geo,
          stickers: []
        }
      }

      playerStickers[player.code].stickers.push(sticker.name)
    } else if (sticker.tournament_team_id !== undefined) {
      const team = teams
        .find(p => p.id === Number(sticker.tournament_team_id))

      if (team !== undefined) {
        let name = (STATIC_TEAMS as any)[team.tag]

        if (name === undefined) {
          name = team.tag
          console.log(`Team '${team.tag as string}' doesn't have a name map in teams.json`)
        }

        const key = name.toLowerCase().replaceAll(' ', '-')

        if (teamStickers[key] === undefined) {
          teamStickers[key] = {
            id: Number(team.id),
            key,
            name,
            geo: team.geo,
            stickers: []
          }
        }

        teamStickers[key].stickers.push(sticker.name)
      }
    }
  })

  stickers
    .sort((a, b) => a.name.localeCompare(b.name))
    .forEach(sticker => {
      data.stickers.stickers[sticker.classname] = sticker
    })

  Object.keys(teamStickers)
    .sort((a, b) => a.localeCompare(b))
    .forEach(key => {
      data.stickers.teams[key] = teamStickers[key]
    })

  Object.keys(playerStickers)
    .sort((a, b) => a.localeCompare(b))
    .forEach(key => {
      data.stickers.players[key] = playerStickers[key]
    })
}
