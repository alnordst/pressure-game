const Infantry = require('./infantry')

class Command extends Infantry {
  constructor(square, team) {
    super(square, team)
    this.type = "command"
  }

  afterMove() {
    super()
    this.square
      .neighbors({headings: [[0, 1]], units: true})
      .filter(unit => unit.team == this.team)
      .forEach(unit => unit.defense_modifier++)
  }
}

module.exports = Command