const express = require('express')
const router = express.Router()
const knex = require('../db')
const Board = require('../classes/Board')

router
  
  .get('/', (req, res) => {
    res.sendStatus(200)
  })
  
  .get('/players', async (req, res) => {
    let players = await knex('players_vw')
    res.status(200).send(players)
  })
  
  .get('/player/:id', async (req, res) => {
    let players = await knex('players_vw').where({'id':req.params.id})
    if(players.length)
      res.status(200).send(players[0])
    else
      res.sendStatus(404)
  })
  
  .get('/games', async (req, res) => {
    let games = await knex('games_vw')
    res.status(200).send(games)
  })
  
  .get('/game/:id', async (req, res) => {
    let games = await knex('games_vw').where({'id':req.params.id})
    if(games.length) {
      let board = Board.fromGame(games[0])
      games[0].board = board.toObj
      res.status(200).send(games[0])
    } else {
      res.sendStatus(404)
    }
  })
  
  .get('/maps', async (req, res) => {
    let maps = await knex('maps_vw')
    res.status(200).send(maps)
  })
  
  .get('/map/:name', async (req, res) => {
    let maps = await knex('maps_vw').where({'map_name':req.params.name})
    if(maps.length) {
      let board = Board.fromGame(maps[0])
      maps[0].board = board.toObj
      res.status(200).send(maps[0])
    } else
      res.sendStatus(404)
  })
  
  .get('/games-with-player/:id', async (req, res) => {
    let games = await knex('games_vw')
      .where({red_player_id: req.params.id})
      .orWhere({blue_player_id: req.params.id})
    res.status(200).send(games)
  })
  
  .get('/player-from-discord-id/:id', async (req, res) => {
    let players = await knex('players').where({discord_id:req.params.id})
    if(players.length)
      res.status(200).send(players[0])
    else
      res.sendStatus(404)
  })

module.exports = router