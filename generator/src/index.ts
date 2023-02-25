import fs from 'fs-extra'
import { parse as parseItemsGame } from './parsers/itemsGame'
import { parse as parseTranslations } from './parsers/translations'
import { parse as parseRarities } from './parsers/rarities'
import { parse as parseWeapons } from './parsers/weapons'
import { parse as parsePaints } from './parsers/paints'
import { parse as parseItemSets } from './parsers/itemsets'
import { parse as parseKnifes } from './parsers/knifes'
import { parse as parseGloves } from './parsers/gloves'
import { parse as parseStickers } from './parsers/stickers'
import { parse as parseStickerCapsules } from './parsers/stickerCapsules'
import { parse as parseMusicKits } from './parsers/musicKits'
import { parse as parseAgents } from './parsers/agents'
import { parse as parsePatches } from './parsers/patches'
import { parse as parsePatchCapsules } from './parsers/patchCapsules'
import { parse as parsePins } from './parsers/pins'
import { parse as parseSprays } from './parsers/sprays'
import { parse as parseRanks } from './parsers/ranks'
import { parse as parseXPLevels } from './parsers/xplevels'

async function generate (): Promise<void> {
  (global as any).translations = await parseTranslations()

  const data: Data = {
    weapons: {},
    knifes: {},
    gloves: {},
    paints: {},
    stickers: {
      capsules: {},
      stickers: {},
      teams: {},
      players: {}
    },
    agents: {},
    patches: {
      capsules: {},
      patches: {}
    },
    music_kits: {},
    pins: {},
    ranks: {},
    xp_levels: {},
    sprays: {},
    item_sets: [],
    rarities: {} as any
  }

  const itemsGame = await parseItemsGame()

  await parseRarities(itemsGame, data)
  await parseWeapons(itemsGame, data)
  await parsePaints(itemsGame, data)
  await parseItemSets(itemsGame, data)
  await parseKnifes(itemsGame, data)
  await parseGloves(itemsGame, data)
  await parseStickers(itemsGame, data)
  await parseStickerCapsules(itemsGame, data)
  await parseMusicKits(itemsGame, data)
  await parseAgents(itemsGame, data)
  await parsePatches(itemsGame, data)
  await parsePatchCapsules(itemsGame, data)
  await parsePins(itemsGame, data)
  await parseSprays(itemsGame, data)
  await parseRanks(data)
  await parseXPLevels(data)

  await fs.mkdirp('out')
  await fs.writeFile('out/data.json', JSON.stringify(data))
  await fs.writeFile('out/data.pretty.json', JSON.stringify(data, null, 2))
  await fs.writeFile('out/items_game.json', JSON.stringify(itemsGame, null, 2))
  await fs.writeFile('out/translations.json', JSON.stringify((global as any).translations, null, 2))
}

void generate()
