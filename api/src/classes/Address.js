class Address {
  static rotate(headings){
    return headings
      .map(heading => Address.rotations(Address.processHeading(heading)))
      .flatten(1)
  }

  static rotations([x, y]) {
    if(x==0 && y==0)
      return [[x, y]]
    else
      return [[x, y], [-x, -y], [-y, x], [y, -x]]
  }

  static processHeading(heading) {
    let headings = {
      NW: [-1,  1], N: [0,  1], NE: [1,  1],
      W:  [-1,  0], C: [0,  0], E:  [1,  0],
      SW: [-1, -1], S: [0, -1], SE: [1, -1]
    }
    return Array.isArray(heading) ? heading : headings[heading]
  }

  constructor(rankNum, file) {
    this.rankNum = rankNum
    this.file = file
    this.rank = rankChars
  }

  toString() {
    return '${rank}${file}'
  }

  neighborAt(heading, distance) {
    let processed = Address.processHeading(heading)
    let scaled = processed.map(component => component * distance)
    return new Address(this.rankNum + scaled[0], this.file + scaled[1])
  }

  // Maxes out at 2 characters, so it'll start returning non-letter characters
  // at this.rankNum >= 27*26. I think this is acceptable, but could be
  // adjusted to do 3+ characters if we were so inclined.
  rankChars() {
    let CHAR_COUNT = 26
    let offset1 = Math.floor(this.rankNum / CHAR_COUNT) - 1
    let offset2 = this.rankNum % CHAR_COUNT
    let getChar = (offset) => String.fromCharCode(offset + 'A'.charCodeAt(0))
    let char1 = offset1 >= 0 ? getChar(offset1) : ''
    let char2 = getChar(offset2)
    return `${char1}${char2}`
  }
}

module.exports = Address