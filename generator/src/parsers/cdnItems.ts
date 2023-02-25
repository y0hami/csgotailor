import fs from 'fs-extra'
import { ITEMS_GAME_CDN_PATH } from '../consts'

export interface CDNItems {
  [parentClass: string]: {
    [itemClass: string]: string
  }
}

export const parse = async (): Promise<CDNItems> => {
  const itemsGameCDNFileExists = await fs.exists(ITEMS_GAME_CDN_PATH)
  if (!itemsGameCDNFileExists) throw new Error('"items_game_cdn.txt" was not found.')

  const itemsGameCDNContents = await fs.readFile(ITEMS_GAME_CDN_PATH, 'utf-8')
  const cdnItems = itemsGameCDNContents.split('\n')
    .map(i => i.split('='))

  console.log(cdnItems)

  const items: CDNItems = {}

  return items
}
