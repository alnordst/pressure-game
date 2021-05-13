const Terrain = require('./Terrain')
const Unit = require('./Unit')

class Square {
  constructor(terrain, unit) {
    this.terrain = terrain
    this.unit = unit
    this.threat = [0,0]
  }

  static fromChar(char) {
    return new Square(Terrain.fromChar(char), Unit.fromChar(char))
  }

  static fromTwoChars(terrain, unit) {
    return new Square(Terrain.fromChar(terrain), Unit.fromChar(unit))
  }

  static moveUnit(from, to) {
    console.log('\nmove', from, to)
    if(from.unit && to.terrain.isPassable){
      to.unit = from.unit.clone
      from.unit = null
      return true
    } else
      return false
  }

  get clone() {
    return new Square(this.terrain.clone, this.isEmpty ? null : this.unit.clone)
  }

  get isEmpty() {
    return !this.unit
  }

  get isPassable() {
    return this.isEmpty && this.terrain.isPassable
  }

  get obstructs() {
    return !this.isEmpty || this.terrain.obstructs
  }

  toString() {
    if(this.isEmpty)
      return this.terrain.toString()
    else
      return this.unit.toString()
  }
}

module.exports = Square