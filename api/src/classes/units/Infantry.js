const Unit = require('../unit')

class Infantry extends Unit {
  constructor(square, team) {
    super(square, team)
    this.category = 'infantry'
    this.type = 'infantry'
    this.validCommands = ['NW', 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'C']
  }

  assignThreat() {
    super()
    this.square
      .neighbors({headings: [[0, 1], [1, 1]]})
      .forEach(square => this.threaten(square))
  }

  afterMove() {
    super()
    let followerDirections = {
      N: ['SE', 'S', 'SW'],
      E: ['SW', 'W', 'NW'],
      S: ['NW', 'N', 'NE'],
      W: ['NE', 'E', 'SE']
    }
    if(this.command in followerDirections) {
      this.previousSquare
        .neighbors({
          headings: followerDirections[this.command],
          units: true
        })
        .filter(unit => unit.category == 'infantry' && unit.team == this.team)
        .forEach(unit => {
          if(unit.nextCommand) {
            let directions = ['NW', 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W']
            let i = directions.indexOf(this.command)
            let j = directions.indexOf(unit.nextCommand)
            let offset = positions => directions[(i + positions) % 8]
            switch((j - i + 8) % 8) {
              case 2: // ortho clockwise
                unit.nextCommand = offset(1)
                break
              case 3: // diagonal away clockwise
                unit.nextCommand = offset(2)
                break
              case 4: // opposite
                unit.nextCommand = null
                break
              case 5: // diagonal away counter-clockwise
                unit.nextCommand = offset(-2)
                break
              case 6: // ortho counter-clockwise
                unit.nextCommand = offset(-1)
                break
            }
          } else {
            unit.setNextCommand(this.command)
          }
        })
    }
  }
}

module.exports = Infantry