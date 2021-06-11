const Address = require('./Address')
const Square = require('./Square')

class Board {
  constructor(data, initialize=true) {
    this.ranks = data.length
    this.files = data[0].length
    this.dataObj = {}
    this.dataMatrix = data.map((row, rowIndex) => {
      row.map((square, colIndex) => {
        let address = new Address(this.ranks - rowIndex, colIndex + 1)
        let squareObj = new Square(this, address, square)
        dataObj[address.toString()] = squareObj
        return squareObj
      })
    })
    if(initialize)
      this.assignThreat()
  }

  toObj(slim=false) {
    return {
      ranks: this.ranks,
      files: this.files,
      data: this.dataMatrix.map(row => {
        return row.map(square => {
          return square.toObj(slim)
        })
      })
    }
  }

  get squares() { return Object.values(dataObj) }
  get isResolved() { return squares.every(square => square.isResolved) }

  squareAt(address) {
    return this.dataObj[address.toString()]
  }

  neighborsOf(square, {headings, iterations=1, test=()=>true, units=false,
  rotate=false, inclusive=false}) {
    let fullHeadings = rotate ? Address.rotate(headings) : headings
    let squares = fullHeadings.reduce((squares, heading) => {
      for(let i=1; i<=iterations; i++) {
        let address = square.address.neighborAt(heading, i)
        let destination = this.squareAt(address)
        if(!destination)
          break
        let passed = test(destination)
        if(passed || inclusive)
          squares.push(destination)
        if(!passed)
          break
      }
      return squares
    }, [])
    if(units)
      return squares
        .map(square => square.unit)
        .filter(unit => unit)
    else
      return squares
  }

  assignThreat() {
    squares.forEach(square => square.assignThreat())
  }

  move() {
    squares.forEach(square => square.beforeMove())
    squares.forEach(square => square.move())
    squares.forEach(square => square.afterMove())
  }

  resolveOnce() {
    squares.forEach(square => square.resolve())
  }

  resolve() {
    while(!this.isResolved)
      this.resolveOnce()
  }
}

module.exports = Board