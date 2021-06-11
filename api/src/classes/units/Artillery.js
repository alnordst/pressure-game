const Vehicle = require('./vehicle')

class Artillery extends Vehicle {
  constructor(square, team) {
    super(square, team)
    this.type = 'artillery'
  }

  assignThreat() {
    super()
    this.square
      .neighbors({headings: [[0, 2], [0, 3], [1, 2], [2, 1]]})
      .forEach(square => threaten(square))
  }
}

module.exports = Artillery