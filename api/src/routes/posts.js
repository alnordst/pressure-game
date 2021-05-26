const express = require('express')
const router = express.Router()
const knex = require('../db')
const Board = require('../classes/Board')
const mustHave = require('../middleware/mustHave')
const { pick, webhooks } = require('../util')


router

  .post('/find-game', async (req, res) => {
    let options = pick('map', 'password', 'strict').from(req.body)
    let existingChallenges = await knex('challenges').where(options)

    if(existingChallenges.length) {
      let validChallenge = existingChallenges.find(challenge => challenge.player_id != req.player)
      if(!validChallenge)
        res.status(400).send('Duplicate challenge')
      else
        await knex.transaction(async trx => {
          await trx('challenges').where({id:validChallenge.id}).del()
          let mapWhere = validChallenge.map_id ? {id:validChallenge.map_id} : {}
          let map = await trx('maps').orderByRaw('rand()').first().where(mapWhere)
          let gameId = await trx('games').insert({
            red_player_id: validChallenge.player_id,
            blue_player_id: req.player,
            map_id: map.id,
            strict: options.strict
          })
          await trx('states').insert({
            game_id: gameId,
            to_move: ['red', 'blue'][Math.floor(Math.random() * 2)],
            units: map.units
          })
          let game = await trx('games_vw').where({id:gameId}).first()
          let board = Board.fromGame(game)
          game.board = board.toObj
          await webhooks({
            players: [validChallenge.player_id],
            reason: 'game-start',
            data: game
          })
          res.status(200).send(game)
        })
    } else {
      await knex('challenges').insert({
        ...options,
        player_id: req.player
      })
      res.sendStatus(204)
    }
  })

  .post('/move', mustHave(['game', 'from', 'to']), async (req, res) => {
    let games = await knex('games_vw').where({'id':req.body.game})
    if(games.length){
      let game = games[0]
      if(['red', 'blue'].some(c => req.player == game[`${c}_player_id`] && game.to_move == c && !game.is_complete)) {
        let board = Board.fromGame(game)
        let valid = board.move(req.body.from, req.body.to, game.to_move)
        if(valid) {
          await knex('states').insert({
            game_id: game.id,
            to_move: game.to_move == 'red' ? 'blue' : 'red',
            units: board.unitString
          })
          game = await knex('games_vw').first().where({'id':req.body.game})
          game.board = board.toObj
          await webhooks({ // need to check if game is over
            players: [game.red_player_id, game.blue_player_id].filter(id => id != req.player),
            reason: 'your-turn',
            data: game
          })
          res.status(200).send(game)
        } else
          res.status(400).send('Invalid move.')
      } else
        res.status(401).send("It's not your turn.")
    } else
      res.sendStatus(404)
  })

  .post('/undo', mustHave(['game']), async (req, res) => {
    let games = await knex('games_vw').where({'id':req.body.game})
    if(games.length){
      let game = games[0]
      if(!['red', 'blue'].some(c => req.player == game[`${c}_player_id`]))
        res.sendStatus(401)
      else if(game.strict || game.is_complete || game.moves_taken <= 1)
        res.sendStatus(403)
      else {
        await knex('states').where({id:game.last_state_id}).del()
        game = await knex('games_vw').first().where({'id':req.body.game})
        let board = Board.fromGame(game)
        game.board = board.toObj
        await webhooks({
          players: [game.red_player_id, game.blue_player_id].filter(id => id != req.player),
          reason: 'your-turn',
          data: game
        })
        res.status(200).send(game)
      }
    } else
      res.sendStatus(404)
  })

  .post('/concede', mustHave(['game']), async (req, res) => {
    let games = await knex('games_vw').where({'id':req.body.game})
    if(games.length) {
      let game = games[0]
      let board = Board.fromGame(game)
      game.board = board.toObj
      if(!['red', 'blue'].some(c => req.player == game[`${c}_player_id`]))
        res.sendStatus(401)
      else if(game.is_complete)
        res.sendStatus(403)
      else {
        await knex('games').where({'id':game.id}).update({
          'is_complete': 1,
          'winner': req.player == game.red_player_id ? 'blue' : 'red'
        })
        await webhooks({
          players: [game.red_player_id, game.blue_player_id].filter(id => id != req.player),
          reason: 'game-end',
          data: game
        })
        res.status(200).send(game)
      }
    } else
      res.sendStatus(404)
  })

  .post('/offer-draw', mustHave(['game']), async (req, res) => {
    let games = await knex('games_vw').where({'id':req.body.game})
    if(games.length) {
      let game = games[0]
      let board = Board.fromGame(game)
      game.board = board.toObj
      if(!['red', 'blue'].some(c => req.player == game[`${c}_player_id`]))
        res.sendStatus(401)
      else if(game.is_complete)
        res.sendStatus(403)
      else {
        let offers = await knex('draw_offers').where({'game_id':req.body.game})
        if(!offers.length) {
          await knex('draw_offers').insert({
            game_id: req.body.game,
            player_id: req.player
          })
          await webhooks({
            players: [game.red_player_id, game.blue_player_id].filter(id => id != req.player),
            reason: 'draw-offer',
            data: game
          })
          res.sendStatus(204)
        } else if(offers.find(offer => offer.player_id != req.player)) {
          await knex('games').update({
            is_complete: 1
          })
          await webhooks({
            players: [game.red_player_id, game.blue_player_id].filter(id => id != req.player),
            reason: 'game-end',
            data: game
          })
          res.status(200).send(game)
        } else {
          res.sendStatus(400)
        }
      }
    } else
      res.sendStatus(404)
  })

  .post('/submit-map', mustHave(['map']), async (req, res) => {
    try{
      let duplicates = await knex('maps').where({name:req.body.map.name})
      if(duplicates.length)
        res.status(400).send('There is already a map with that name.')
      else {
        Board.fromGame(req.body.map, false)
        await knex('maps').insert({
          'name': req.body.map.name,
          'ranks': req.body.map.ranks,
          'files': req.body.map.files,
          'terrain': req.body.map.terrain,
          'units': req.body.map.units,
          'creator-id': req.player
        })
        res.sendStatus(200)
      }
    } catch(err) {
      res.status(400).send('Invalid map.')
    }
  })

  .post('/register-webhook', mustHave(['url']), async (req, res) => {
    let webhookId
    let existingWebhooks = await knex('webhooks').where({url:req.body.url})
    if(existingWebhooks.length) {
      webhookId = existingWebhooks[0].id
    } else {
      webhookId = await knex('webhooks').insert({url:req.body.url})
    }
    await knex('webhook_registrations').insert({
      player_id: req.player,
      webhook_id: webhookId
    })
    res.sendStatus(200)
  })

module.exports = router