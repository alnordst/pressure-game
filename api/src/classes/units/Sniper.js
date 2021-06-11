const Infantry = require('./infantry')

class Sniper extends Infantry {
  constructor(square, team) {
    super(square, team)
    this.type = 'sniper'
  }

  assignThreat() {
    super()
    this.square
      .neighbors({
        headings: [[0, 1], [1, 1]],
        repeat: Infinity,
        test: square => !square.isObstructed,
        inclusive: true
      })
      .filter(square => square.isPassable)
      .forEach(square => this.threaten(square))
  }
}

module.exports = Sniper