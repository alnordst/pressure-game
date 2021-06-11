const knex = require('../db')

class Challenge {

  static create(playerId, options) {
    return knex('challenges').insert({
      player_id: playerId,
      ...options
    })
  }

  static delete(where) {

  }

  static async post(playerId, options) {
    let existingChallenges = await knex('challenges').where(options)
    if(existingChallenges.length) {
      let validChallenge = existingChallenges
        .find(challenge => challenge.player_id != playerId)
      if(!validChallenge)
        throw 'duplicate challenge'
      await knex('challenges').where({id:validChallenge.id}).del()
      /*let map = await knex('maps')
        .orderByRaw('rand()')
        .first()
        .where(validChallenge.map_id ? {id:validChallenge.map_id} : {})*/
      let map = await Map.get(validChallenge.map_id)
      return Game.create({
        redPlayerId: validChallenge.player_id,
        bluePlayerId: playerId,
        mapId: map.id,
        automaticTurnProgression: options.automaticTurnProgression
      })
    } else {
      await Challenge.create(playerId, options)
    }
  }
}

module.exports = Challenge