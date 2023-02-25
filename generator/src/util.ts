export const getTranslation = (key: string): string =>
  (global as any).translations[key.replace('#', '')
    .toLowerCase()]

export const repairKV = (obj: any[]): any => {
  const result: any = {}

  Object.values(obj).forEach(object => {
    Object.keys(object).forEach(key => {
      result[key] = object[key]
    })
  })

  return result
}
