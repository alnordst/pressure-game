const knex = require('knex')({
  client: 'mysql',
  connection: {
    host: process.env.HOST,
    database: process.env.DATABASE,
    user: process.env.USER,
    password: process.env.PASSWORD
  }
})
const express = require('express')
const cors = require('cors')

const app = express()
app.use(express.json())
app.use(cors())
app.disable('x-powered-by')


app.post('start-game', async (req, res) => {
  if(!req.body.player || !req.body.opponent || !req.body.mapName)
    res.status(400).send('Include player, opponent, and mapName in request.')
  else {
    let player = await knex('players').first().where({'discord-id':req.body.player})
    let opponent = await knex('players').first().where({'discord-id':req.body.opponent})
    let map = await knex('maps').first().where({'name':req.body.mapName})
    if(!map)
      res.status(404).send('Map not found.')
    else {
      let gameId = await knex('games').returning('id').insert({
        'red-player-id': player.id,
        'blue-player-id': opponent.id,
        'map-id': map.id,
        'strict': req.body.strict ? 1 : 0
      })
      let state = await knex('states').insert({
        'game-id': gameId,
        'turn': ['red', 'blue'].includes(req.body.turn.toLowerCase()) ? req.body.turn.toLowerCase() : Math.floor(Math.random() * 2),
        'units': map.units
      })
      res.status(200).send({ map, state }) // would like to process this, calculate available moves and threat and whatnot
    }
  }
})

app.get('status/:key', async (req, res) => {
  let game = await knex('games').first()
    .join('maps', {'games.map-id':'maps.id'})
    .where({'id':req.params.key})
  let state = await knex('states').orderBy('timestamp').first().where({'game-id':game.id}) // do it properly with a join probably
  res.status(200).send({ game, state }) // again, should be processed
})

app.post('move', async (req, res) => {
  if(!req.body.player || !req.body.game || !req.body.command)
    res.status(400).send('Include player, game, and command in request.')
  else {
    let game = await knex('games').first().where({'id':req.body.game})
    let state = await knex('states').orderBy('timestamp').first().where({'game-id':game.id})
    let player = await knex('players').first().where({'discord-id':req.body.player})
    if((player.id == game['red-player-id'] && state.turn == 'red') || (player.id == game['blue-player-id'] && state.turn == 'blue')) {
      let valid = true// todo handle move
      if(valid)
        res.sendStatus(200)
      else
        res.status(400).send('Invalid move.')
    } else
      res.status(401).send("It's not your turn.")
  }
})

app.post('undo', async (req, res) => {
  if(!req.body.player || !req.body.game)
    res.status(400).send('Include player and game in request.')
  else {
    let game = await knex('games').first().where({'id':req.body.game})
    let player = await knex('players').first().where({'discord-id':req.body.player})
    if(['red', 'blue'].some(color => player.id == game[`${color}-player-id`]) && !game.strict) {
      await knex('states').orderBy('timestamp').first().where({'game-id':game.id}).del()
      res.sendStatus(200)
    } else
      res.sendStatus(401)
  }
})

app.post('post-map', async (req, res) => {
  if(!req.body.player || !req.body.name || !req.body.rows || !req.body.files || !req.body.terrain || !req.body.units)
    res.sendStatus(400)
  else
    let player = await knex('players').first().where({'discord-id':req.body.player})
    let valid = true //validate map and make sure no other map has that name
    if(valid){
      await knex('maps').insert({
        name: req.body.name,
        rows: req.body.rows,
        files: req.body.files,
        terrain: req.body.terrain,
        units: req.body.units,
        creator: player.id
      })
      res.sendStatus(200)
    } else {
      res.sendStatus(400)
    }
})

app.listen(3000, () => {
  console.log('Listening on port 3000.')
})