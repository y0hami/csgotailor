import STATIC_RANKS from '../static/ranks.json'

export const parse = async (data: Data): Promise<void> => {
  STATIC_RANKS.forEach(rank => {
    data.ranks[rank.index] = rank
  })
}
