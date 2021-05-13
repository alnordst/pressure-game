const Square = require('./Square')
const GifEncoder = require('gifencoder')
const { createCanvas, loadImage } = require('canvas')
const fs = require('fs')

class Board {
  constructor(data) {
    this.data = data
  }

  static fromJson(json) {
    if(Array.isArray(json))
      return new Board(json.map(line => line.split('').map(item => {
        return Square.fromChar(item)
      })))
    else{
      return new Board(json.terrain.map((line, i) => {
        return line.split('').map((terrainItem, j) => {
          let unitItem = json.units[i][j]
          return Square.fromTwoChars(terrainItem, unitItem)
        })
      }))
    }
  }

  get rowCount() {
    return this.data.length
  }

  get fileCount() {
    return this.data[0].length
  }

  get clone() {
    return new Board(this.data.map(row => row.map(square => square.clone)))
  }

  move(from, to) {
    let newBoard = this.clone
    let fromSquare = newBoard.squareAt(from)
    let toSquare = newBoard.squareAt(to)
    if(!fromSquare || !toSquare)
      return null
    let success = Square.moveUnit(newBoard.squareAt(from), newBoard.squareAt(to))
    if(success)
      return newBoard
    else
      return null
  }

  squareAt(address) {
    try {
      let [rawFile, rawRow] = address.toUpperCase().split('')
      let file = rawFile.charCodeAt(0) - 'A'.charCodeAt(0)
      let row = this.rowCount - parseInt(rawRow)
      return this.data[row][file]
    } catch (err) {
      return null
    }
  }

  checkForWin() {
    if(!this.data.some(row => row.some(square => !square.isEmpty && square.unit.toString() == 'C')))
      return 1
    else if(!this.data.some(row => row.some(square => !square.isEmpty && square.unit.toString() == 'c')))
      return 0
    else
      return null
  }

  toString() {
    let display = this.data.map((row, i) => {
      let dispRow = row.map(square => square.toString()).join(' ')
      return `${this.rowCount - i} | ${dispRow}`
    }).join('\n')
    let bottom = new Array(3+this.fileCount*2).fill('-').join('')
    bottom += '\n  | '
    bottom += this.data[0].map((item, i) => {
      return String.fromCharCode('A'.charCodeAt(0) + i)
    }).join(' ')
    return `\`\`\`\n${display}\n${bottom}\`\`\``
  }

  async toGif() {
    const encoder = new GifEncoder(16*(1+this.fileCount), 16*(1+this.rowCount))
    const canvas = createCanvas(16*(1+this.fileCount), 16*(1+this.rowCount))

    encoder.createReadStream().pipe(fs.createWriteStream('board.gif'))
    encoder.start()
    encoder.setRepeat(0)
    encoder.setDelay(500)
    encoder.setQuality(10)

    const ctx = canvas.getContext('2d')

    const draw = async function(filename, x, y) {
      let image = await loadImage(`./sprites/${filename}.png`)
      ctx.drawImage(image, x ,y)
    }

    // draw row numbers
    for(let i=this.rowCount; i>=1; i--)
      await draw(i, 0, (this.rowCount-i)*16)

    // draw file letters
    for(let i=0; i<this.fileCount; i++)
      await draw(String.fromCharCode('a'.charCodeAt(0)+i),(i+1)*16,this.rowCount*16)

    // draw board contents
    for(let i in this.data) {
      let y = i * 16
      for(let j in this.data[i]) {
        let square = this.data[i][j]
        let x = (parseInt(j)+1) * 16
        await draw(square.terrain.name, x, y)
        if(!square.isEmpty)
          await draw(`${['red','blue'][square.unit.team]}_${square.unit.name}`, x, y)
      }
    }

    encoder.addFrame(ctx)
    encoder.finish()
  }

  compute() {
    this.data.forEach((row, i) => row.forEach((square, j) => {
      if(square.isEmpty) return

    }))
  }
}

module.exports = Board