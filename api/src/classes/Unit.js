class Unit {
  constructor(team) {
    this.type = null
    this.team = team
    this.offenseModifier = 0
    this.defenseModifier = 0
    this.threatens = []
  }

  static fromChar(char) {
    let team = char === char.toUpperCase() ? 'red' : 'blue'
    if(char.toUpperCase() == 'A')
      return new ArtilleryUnit(team)
    else if(char.toUpperCase() == 'C')
      return new CommandUnit(team)
    else if(char.toUpperCase() == 'I')
      return new InfantryUnit(team)
    else if(char.toUpperCase() == 'S')
      return new SniperUnit(team)
    else if(char.toUpperCase() == 'T')
      return new TankUnit(team)
  }

  assignThreat() {}
  availableMoves() { return [] }

  get offense() { return 1 + this.offenseModifier }
  get defense() { return 1 + this.defenseModifier }

  get toObj() {
    return {
      type: this.type,
      team: this.team,
      threatens: this.threatens
    }
  }

  threaten(square) {
    return {
      from: (thisSquare) => {
        this.threatens.push(square.heading)
        square.threat[this.team] += this.offense
        square.threatenedBy[this.team].push(thisSquare.heading)
      }
    }
  }
}


class ArtilleryUnit extends Unit {
  constructor(team) {
    super(team)
    this.type = 'artillery'
  }

  toString () {
    return this.team == 'red' ? 'A' : 'a'
  }

  assignThreat(thisSquare, getter) {
    getter({headings:[[0,2],[0,3],[1,2],[2,1]]}).forEach(square => {
      this.threaten(square).from(thisSquare)
    })
  }

  availableMoves(thisSquare, getter) {
    return getter({
      headings:[[0,1]],
      repeat: 3,
      test: square => square.isPassable,
      inclusive: false
    }).map(square => square.heading)
  }
}


class CommandUnit extends Unit {
  constructor(team) {
    super(team)
    this.type = 'command'
  }

  toString () {
    return this.team == 'red' ? 'C' : 'c'
  }

  assignThreat(thisSquare, getter) {
    getter({headings:[[0,1], [1,1]]}).forEach(square => {
      this.threaten(square).from(thisSquare)
    })
    getter({headings:[[0,1]]}).forEach(square => {
      if(square.unit && square.unit.team == this.team)
        square.unit.defenseModifier += 1
    })
  }

  availableMoves(thisSquare, getter) {
    return getter({
      headings:[[0,1],[1,1]],
      test: square => square.isPassable || square.isCapturable(this.team),
      inclusive: false
    }).map(square => square.heading)
  }
}


class InfantryUnit extends Unit {
  constructor(team) {
    super(team)
    this.type = 'infantry'
  }

  toString () {
    return this.team == 'red' ? 'I' : 'i'
  }

  assignThreat(thisSquare, getter) {
    getter({headings:[[0,1], [1,1]]}).forEach(square => {
      this.threaten(square).from(thisSquare)
    })
  }

  availableMoves(thisSquare, getter) {
    let chain = []
    let moves = []
    let traverse = (heading, countCaptures) => { // Recursively calculate infantry chains
      chain.push(heading)
      getter({
        origin: heading,
        headings:[[0,1],[1,1]]
      }).forEach(square => {
        if(!moves.includes(square.heading)) {
          if(square.isPassable || (square.isCapturable(this.team) && countCaptures))
            moves.push(square.heading)
          else if(square.unit && square.unit.type == 'infantry' && square.unit.team == this.team && !chain.includes(square.heading))
            traverse(square.heading, false)
        }
      })
    }
    traverse(thisSquare.heading, true)
    return moves
  }
}


class SniperUnit extends Unit {
  constructor(team) {
    super(team)
    this.type = 'sniper'
  }

  toString () {
    return this.team == 'red' ? 'S' : 's'
  }

  assignThreat(thisSquare, getter) {
    getter({ // Threaten on queen lines until obstructed
      headings:[[0,1],[1,1]],
      repeat: Infinity,
      test: square => !square.isObstructed,
      inclusive: true
    }).forEach(square => {
      if(square.terrain.passable)
        this.threaten(square).from(thisSquare)
    })
  }

  availableMoves(thisSquare, getter) {
    return [
      ...getter({ // Can move 2
        headings:[[0,1],[1,1]],
        repeat: 2,
        test: square => square.isPassable,
        inclusive: false
      }),
      ...getter({ // Can capture 1
        headings:[[0,1],[1,1]],
        test: square => square.isCapturable(this.team),
        inclusive: false
      }),
    ].map(square => square.heading)
  }
}


class TankUnit extends Unit {
  constructor(team) {
    super(team)
    this.type = 'tank'
    this.offenseModifier = 1
  }

  toString () {
    return this.team == 'red' ? 'T' : 't'
  }

  assignThreat(thisSquare, getter) {
    getter({
      headings:[[0,1]],
      repeat: Infinity,
      test: square => square.isPassable,
      inclusive: true
    }).forEach(square => {
      if(square.terrain.passable)
        this.threaten(square).from(thisSquare)
    })
  }

  availableMoves(thisSquare, getter) {
    return getter({
      headings:[[0,1]],
      repeat: Infinity,
      test: square => square.isPassable,
      inclusive: true
    })
    .filter(square => square.isPassable || square.isCapturable(this.team))
    .map(square => square.heading)
  }
}


module.exports = Unit