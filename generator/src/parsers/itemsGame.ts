import fs from 'fs-extra'
import { deserializeFile } from 'valve-kv'
import { ITEMS_GAME_PATH } from '../consts'

export const parse = async (): Promise<any> => {
  if (!await fs.exists(ITEMS_GAME_PATH)) {
    throw new Error('"items_game.txt" was not found.')
  }

  return deserializeFile(ITEMS_GAME_PATH, 'utf-8').items_game
}
