const Square = require('./Square')

let rotations = ([x, y]) => [ [x, y], [-x, -y], [-y, x], [y, -x] ]

class Board {
  constructor(ranks, files, terrain, units, calculate=true) {
    let data = []
    for(let i=0; i<ranks; i++){
      let row = []
      for(let j=0; j<files; j++) {
        let terrainChar = terrain[i*files+j]
        let unitChar = units[i*files+j]
        let heading = `${String.fromCharCode('a'.charCodeAt(0)+j)}${ranks-i}`
        row.push(Square.fromChar(terrainChar, unitChar, heading))
      }
      data.push(row)
    }

    //todo validate, check for win, etc

    if(calculate){
      let getterGen = defaultOrigin => ({origin=defaultOrigin, headings, repeat=1, test=()=>true, inclusive=false}) => {
        let i = ranks - parseInt(origin.slice(1))
        let j = origin.slice(0,1).charCodeAt(0)-'a'.charCodeAt(0)
        return headings.reduce((squares, heading) => {
          rotations(heading).forEach((heading) => {
            for(let k=1; k<=repeat; k++) {
              let x = i + k*heading[0]
              let y = j + k*heading[1]
              let square
              try {
                square = data[x][y]
              } catch(err){
                break // we've gone off the board
              }
              if(!square)
                break // also gone off the board
              let passed = test(square)
              if(passed || inclusive)
                squares.push(square)
              if(!passed)
                break
            }
          })
          return squares
        }, [])
      }

      data.forEach(row => row.forEach(square => square.assignThreat(getterGen)))
      data.forEach(row => row.forEach(square => square.getAvailableMoves(getterGen)))
    }
    this.data = data
  }

  static fromMapAndState({ranks, files, terrain}, {units}, calculate) {
    return new Board(ranks, files, terrain, units, calculate)
  }

  static fromGame({ranks, files, terrain, units}, calculate) {
    return new Board(ranks, files, terrain, units, calculate)
  }

  move(from, to, toMove) {
    let fromSquare = this.data.find(row => row.find(square => square.heading == from)).find(square => square.heading == from)
    let toSquare = this.data.find(row => row.find(square => square.heading == to)).find(square => square.heading == to)
    if(to != from && fromSquare.availableMoves.includes(to) && fromSquare.unit.team == toMove) {
      toSquare.unit = fromSquare.unit
      fromSquare.unit = null
      return true
    } else {
      return false
    }
  }

  get unitString() {
    return this.data.map(row => {
      return row.map(square => {
        return square.isEmpty ? ' ' : square.unit.toString()
      }).join('')
    }).join('')
  }

  get toObj() {
    return this.data.map(row => row.map(square => square.toObj))
  }
}

module.exports = Board