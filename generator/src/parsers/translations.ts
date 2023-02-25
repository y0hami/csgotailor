import fs from 'fs-extra'
import { deserializeFile } from 'valve-kv'
import { TRANSLATIONS_PATH } from '../consts'

export const parse = async (): Promise<Record<string, string>> => {
  if (!await fs.exists(TRANSLATIONS_PATH)) {
    throw new Error('"csgo_english.txt" was not found.')
  }

  const tokens = (deserializeFile(TRANSLATIONS_PATH) as any).lang.Tokens
  const translations: Record<string, string> = {}

  Object.keys(tokens).forEach(key => {
    translations[key.toLowerCase()] = tokens[key]
  })

  return translations
}
