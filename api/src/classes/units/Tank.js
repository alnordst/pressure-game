const Vehicle = require('./vehicle')

class Tank extends Vehicle {
  constructor(square, team) {
    super(square, team)
    this.type = 'tank'
    this.baseOffense = 2
    this.baseDefense = 2
  }

  assignThreat() {
    super()
    this.square
      .neighbors({headings: [[0, 1], [1, 1]]})
      .forEach(square => threaten(square))
  }
}

module.exports = Tank