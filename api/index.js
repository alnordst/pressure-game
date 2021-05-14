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

const handleMove = require('./util/handleMove.js')
const processGamestate = require('./util/processGamestate.js')
const processMap = require('./util/processMap.js')


const mustHave = (fields) => function(req, res, next) {
  let missing = fields.filter(field => !('field' in req.body))
  if(missing.length)
    res.status(400).send(`Include field(s) ${missing.join(', ')} in request.`)
  else
    next()
}

app.post('/start-game', mustHave(['player', 'opponent', 'mapName']), async (req, res) => {
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
    res.status(200).send(processGamestate(map, state))
  }
})

app.get('/status/:key', async (req, res) => {
  let game = await knex('games').first()
    .join('maps', {'games.map-id':'maps.id'})
    .where({'id':req.params.key})
  let state = await knex('states').orderBy('timestamp').first().where({'game-id':game.id})
  res.status(200).send(processGamestate(game, state)) 
})

app.post('/move', mustHave(['player', 'game', 'command']), async (req, res) => {
  let game = await knex('games').first().where({'id':req.body.game})
  let state = await knex('states').orderBy('timestamp').first().where({'game-id':game.id})
  let player = await knex('players').first().where({'discord-id':req.body.player})
  if((player.id == game['red-player-id'] && state.turn == 'red') || (player.id == game['blue-player-id'] && state.turn == 'blue')) {
    let units = handleMove(game, state, command)
    if(units) {
      await knex('states').insert({
        'game-id': game.id,
        'turn': state.turn == 'red' ? 'blue' : 'red',
        'units': units
      })
      res.status(200).send(processGamestate(game, {units}))
    } else
      res.status(400).send('Invalid move.')
  } else
    res.status(401).send("It's not your turn.")
})

app.post('/undo', mustHave(['player', 'game']), async (req, res) => {
  let game = await knex('games').first().where({'id':req.body.game})
  let player = await knex('players').first().where({'discord-id':req.body.player})
  if(['red', 'blue'].some(color => player.id == game[`${color}-player-id`]) && !game.strict && game['is-complete'] == 0) {
    await knex('states').orderBy('timestamp').first().where({'game-id':game.id}).del()
    res.sendStatus(200)
  } else
    res.sendStatus(401)
})

app.post('/forfeit', mustHave(['player', 'game']), async (req, res) => {
  let game = await knex('games').first().where({'id':req.body.game})
  let player = await knex('players').first().where({'discord-id':req.body.player})
  if(['red', 'blue'].some(color => player.id == game[`${color}-player-id`]) && game['is-complete'] == 0) {
    await knex('games').where({'game-id':game.id}).update({
      'is-complete': 1,
      'winner': player.id == game['red-player-id'] ? 'red' : 'blue'
    })
    res.sendStatus(200)
  } else
    res.sendStatus(401)
})

app.post('/post-map', mustHave(['player', 'name', 'map']), async (req, res) => {
  let player = await knex('players').first().where({'discord-id':req.body.player})
  let map = processMap(req.body.map)
  if(valid){
    await knex('maps').insert({
      'name': req.body.name,
      'ranks': map.ranks,
      'files': map.files,
      'terrain': map.terrain,
      'units': map.units,
      'creator-id': player.id
    })
    res.sendStatus(200)
  } else {
    res.sendStatus(400)
  }
})

app.listen(process.env.PORT, () => {
  console.log(`Listening on port ${process.env.PORT}.`)
})
