const Terrain = require('./Terrain')
const Unit = require('./Unit')

class Square {
  constructor(terrain, unit, heading) {
    this.terrain = terrain
    this.unit = unit
    this.heading = heading
    this.threat = {
      red: 0,
      blue: 0
    },
    this.availableMoves = []
    this.threatenedBy = {
      red: [],
      blue: []
    }
  }

  static fromChar(terrain, unit, heading) {
    return new Square(Terrain.fromChar(terrain), Unit.fromChar(unit), heading)
  }

  assignThreat(getterGen) {
    if(!this.isEmpty)
      this.unit.assignThreat(this, getterGen(this.heading))
  }
  getAvailableMoves(getterGen) {
    if(!this.isEmpty)
      this.availableMoves = this.unit.availableMoves(this, getterGen(this.heading))
  }

  get isEmpty() { return !this.unit }
  get isPassable() { return this.isEmpty && this.terrain.passable }
  get isObstructed() { return !this.isEmpty || this.terrain.obstructs }
  
  netThreat(team) {
    let threat = this.threat[team]
    let defense = this.unit.defense + this.terrain.defenseModifier
    return threat - defense
  }

  isCapturable(team) {
    return !this.isEmpty && this.unit.team != team && this.netThreat(team) >= 0
  }

  get toObj() {
    return {
      terrain: this.terrain.toObj,
      unit: this.isEmpty ? null : this.unit.toObj,
      heading: this.heading,
      threat: this.threat,
      defense: this.isEmpty ? null : this.unit.defense + this.terrain.defenseModifier,
      availableMoves: this.availableMoves,
      threatenedBy: this.threatenedBy
    }
  }
}

module.exports = Square