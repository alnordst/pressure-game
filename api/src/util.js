const axios = require('axios')
const knex = require('./db')

module.exports = {
  pick: (...arr) => ({from: (obj) => {
    return arr.reduce((acc, key) => {
      if(key in obj)
        acc[key] = obj[key]
      return acc
    }, {})
  }}),
  webhooks: async ({players, reason, data}) => {
    let registrations = await knex('webhook_registrations')
      .select()
      .join('webhooks', {'webhooks.id':'webhook_registrations.webhook_id'})
      .join('players', {'players.id':'webhook_registrations.player_id'})
      .whereIn('webhook_registrations.player_id', players)

    for(let item of registrations)
      axios.post(item.target_url, {
        player: {
          id: item.player_id,
          discord_id: item.discord_id,
          username: item.username
        },
        reason,
        data
      }).catch(() => {})
  }
}