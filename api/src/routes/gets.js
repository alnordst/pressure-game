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
    let player = await knex('players_vw')
      .first()
      .where({id: req.params.id})
    if(player)
      res.status(200).send(player)
    else
      res.sendStatus(404)
  })

  .get('/games', async (req, res) => {
    let games = await knex('games_vw')
    res.status(200).send(games)
  })

  .get('/game/:id', async (req, res) => {
    let game = await knex('games_vw')
      .where({'id':req.params.id})
      .first()
    if(game) {
      let board = new Board(game.stateData)
      res.status(200).send({
        ...game,
        board: board.toObj()
      })
    } else {
      res.sendStatus(404)
    }
  })

  .get('/maps', async (req, res) => {
    let maps = await knex('maps_vw')
    res.status(200).send(maps)
  })

  .get('/map/:name', async (req, res) => {
    let map = await knex('maps_vw')
      .where({'map_name':req.params.name})
      .first()
    if(map) {
      let board = new Board(maps.mapData)
      res.status(200).send({
        ...map,
        board: board.toObj()
      })
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
    let player = await knex('players')
      .where({discord_id:req.params.id})
      .first()
    if(player)
      res.status(200).send(player)
    else
      res.sendStatus(404)
  })

module.exports = router