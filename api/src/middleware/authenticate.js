const axios = require('axios')
const knex = require('../db')

/* Authenticates player against discord and put their player
id and username into req. Alternatively if it's our bot,
set player id and username from data in the body. */
module.exports = async (req, res, next) => {
  let processPlayer = async ({id, username}) => {
    let players = await knex('players').where({'discord_id':id})
    let dbId
    if(players.length){
      // if player is in db, update username
      await knex('players').where({'discord_id':id}).update({
        username: username
      })
      dbId = players[0].id
    } else {
      // else, create db entry
      dbId = await knex('players').insert({
        discord_id: id,
        username: username
      })
    }
    req.player = dbId
  }

  if(req.headers.authorization == `Bearer ${process.env.BOT_TOKEN}`){
    // request from our discord bot
    if(req.body.player && req.body.player.id && req.body.player.username){
      await processPlayer(req.body.player)
      next()
    } else
      next('Authenticated request must include player id and username')
  } else {
    // request from any other app
    try {
      let user = await axios.get('https://discord.com/api/users/@me', {
        headers: { authorization: req.headers.authorization }
      })
      await processPlayer(user.body)
      next()
    } catch (err) {
      next(err)
    }
  }
}