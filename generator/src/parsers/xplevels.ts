import STATIC_XP_LEVELS from '../static/xp_levels.json'

export const parse = async (data: Data): Promise<void> => {
  STATIC_XP_LEVELS.forEach(xplevel => {
    data.xp_levels[xplevel.index] = xplevel
  })
}
