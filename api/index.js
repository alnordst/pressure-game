const knex = require('knex')({
  client: 'mysql2',
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

const Board = require('./util/Board.js')

const mustHave = (fields) => function(req, res, next) {
  let missing = fields.filter(field => !(field in req.body))
  if(missing.length)
    res.status(400).send(`Include field(s) ${missing.join(', ')} in request.`)
  else
    next()
}


// --- gets ---
app.get('/players', async (req, res) => {
  let players = await knex('players_vw')
  res.status(200).send(players)
})
app.get('/player/:id', async (req, res) => {
  let player = await knex('players_vw').first().where({'id':req.params.id})
  res.status(200).send(player)
})
app.get('/games', async (req, res) => {
  let games = await knex('games_vw')
  res.status(200).send(games)
})
app.get('/game/:id', async (req, res) => {
  let game = await knex('games_vw').first().where({'id':req.params.id})
  let board = Board.fromGame(game)
  res.status(200).send({
    game: game,
    board: board.toObj
  }) 
})
app.get('/maps', async (req, res) => {
  let maps = await knex('maps_vw')
  res.status(200).send(maps)
})
app.get('/map/:id', async (req, res) => {
  let map = await knex('maps_vw').where({'maps.id':req.params.id})
  res.status(200).send(map)
})

app.post('/start-game', mustHave(['player', 'opponent', 'mapName']), async (req, res) => {
  let map = await knex('maps_vw').first().where({'name':req.body.mapName})
  if(!map)
    res.status(404).send('Map not found.')
  else {
    let gameId = await knex('games').returning('id').insert({
      red_player_id: req.body.player,
      blue_player_id: req.body.opponent,
      map_id: map.id,
      strict: req.body.strict ? 1 : 0
    })
    let state = await knex('states').insert({
      game_id: gameId,
      to_move: ['red', 'blue'].includes(req.body.toMove.toLowerCase()) ? req.body.toMove.toLowerCase() : Math.floor(Math.random() * 2),
      units: map.units
    })
    let board = Board.fromMapAndState(map, state)
    res.status(200).send({
      board: board.toObj
    })
  }
})

app.post('/move', mustHave(['player', 'game', 'from', 'to']), async (req, res) => {
  let game = await knex('games_vw').first().where({'id':req.body.game})
  if((req.body.player == game.red_player_id && game.to_move == 'red') || (req.body.player == game.blue_player_id && game.to_move == 'blue')) {
    let board = Board.fromGame(game)
    let valid = board.move(req.body.from, req.body.to, game.to_move)
    if(valid) {
      await knex('states').insert({
        game_id: game.id,
        to_move: game.to_move == 'red' ? 'blue' : 'red',
        units: board.unitString
      })
      res.status(200).send({
        board: board.toObj
      })
    } else
      res.status(400).send('Invalid move.')
  } else
    res.status(401).send("It's not your turn.")
})

app.post('/undo', mustHave(['player', 'game']), async (req, res) => {
  let game = await knex('games_vw').first().where({'id':req.body.game})
  if(['red', 'blue'].some(color => req.body.player == game[`${color}_player_id`]) && !game.strict && game.is_complete == 0) {
    await knex('states').orderBy('ts').first().where({game_id:game.id}).del()
    game = await knex('games_vw').first().where({'id':req.body.game})
    let board = Board.fromGame(game)
    res.status(200).send({
      board: board.toObj
    })
  } else
    res.sendStatus(401)
})

app.post('/concede', mustHave(['player', 'game']), async (req, res) => {
  let game = await knex('games_vw').first().where({'id':req.body.game})
  if(['red', 'blue'].some(color => req.body.player == game[`${color}_player_id`]) && game.is_complete == 0) {
    await knex('games').where({'game-id':game.id}).update({
      'is_complete': 1,
      'winner': req.body.player == game['red-player-id'] ? 'blue' : 'red'
    })
    res.sendStatus(200)
  } else
    res.sendStatus(401)
})

app.post('/post-map', mustHave(['player', 'name', 'map']), async (req, res) => {
  try{
    Board.fromGame(req.body.map, false)
    await knex('maps').insert({
      'name': req.body.name,
      'ranks': map.ranks,
      'files': map.files,
      'terrain': map.terrain,
      'units': map.units,
      'creator-id': player.id
    })
    res.sendStatus(200)
  } catch(err) {
    res.status(400).send('Invalid map.')
  }
})

app.listen(process.env.PORT, () => {
  console.log(`Listening on port ${process.env.PORT}.`)
})
