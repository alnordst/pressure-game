const Unit = require('../unit')

class Vehicle extends Unit {
  constructor(square, team) {
    super(square, team)
    this.category = 'artillery'
    this.validCommands = ['N', 'E', 'S', 'W', 'C']
  }

  move() {
    super()
    if(this.hasMoved && !this.square.terrain.isObstructed)
      this.setNextCommand(this.command)
  }
}

module.exports = Vehicle