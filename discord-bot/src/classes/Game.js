const fs = require('fs').promises
const path = require('path')
const Board = require('./Board')

class Game {
  constructor(playerA, playerB, mapName) {
    this.players = [
      playerA, playerB
    ]
    this.mapName = mapName
    this.turn = null
    this.history = []
  }

  async init() {
    let mapPath = path.resolve(__dirname, `../maps/${this.mapName}.json`)
    let rawMap = await fs.readFile(mapPath, 'utf8')
    let newState = Board.fromJson(JSON.parse(rawMap))
    this.history.push(newState)
    this.turn = Math.floor(Math.random() * 2)
  }

  static getAvailableMaps() {
    return fs.readdir(
      path.resolve(__dirname, `../maps`)
    ).then(files => files.map(file => file.split('.')[0]))
  }

  switchTurn() {
    if(this.turn == 0)
      this.turn = 1
    else if(this.turn == 1)
      this.turn = 0
  }

  move(from, to) {
    let newState = this.state.move(from, to)
    if(newState){
      this.history.push(newState)
      this.switchTurn()
    }
    return newState
  }

  undo() {
    let pastState = this.history.pop()
    if(pastState){
      this.switchTurn()
    }
    return pastState
  }

  get state() {
    return this.history[this.history.length - 1]
  }

  get nextPlayer() {
    return this.players[this.turn]
  }

  get winner() {
    return this.players[this.state.checkForWin()]
  }

  toString() {
    let text
    if(this.winner)
      text = `${this.winner} wins!`
    else
      text = `${this.nextPlayer} to move with ${this.turn==0 ? 'UPPERCASE' : 'lowercase'}.`
    let board = this.state.toString()
    return `${text}\n${board}`
  }

  async toGif() {
    let text
    if(this.winner)
      text = `${this.winner} wins!`
    else
      text = `${this.nextPlayer} to move with ${['red', 'blue'][this.turn]}.`
    await this.state.toGif()
    return text
  }
}

module.exports = Game