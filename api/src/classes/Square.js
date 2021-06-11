const Terrain = require('./Terrain')
const Unit = require('./Unit')

class Square {
  constructor(board, address, {terrain, unit=null}) {
    this.board = board
    this.address = address
    this.terrain = new Terrain(terrain)
    this.units = unit ? [new Unit(this, unit)] : []
    this.threat = { red: 0, blue: 0 }
    this.threatenedBy = { red: [], blue: [] }
  }

  toObj(slim=false) {
    let essential = {
      terrain: this.terrain.toObj(slim),
      unit: this.unit.toObj(slim)
    }
    let extra = {
      address: this.address.toString(),
      threat: this.threat,
      threatenedBy: this.threatenedBy
    }
    return slim ? essential : {...essential, ...extra}
  }

  get unit() { return this.isAlone ? this.units[0] : null}
  neighbors(args) { this.board.neighborsOf(this, args) }

  // Status
  get defenseModifier() { return this.terrain.defenseModifier }
  get isPassable() { return this.terrain.isPassable }
  get isObstructed() { return this.terrain.isObstructed || !this.isEmpty }
  get isEmpty() { return this.units.length == 0 }
  get isAlone() { return this.units.length == 1 }
  get isResolved() { return this.isEmpty || this.isAlone }
  get isContested() {
    let teams = this.units.map(unit => unit.team)
    return (new Set(teams)).size == 2
  }

  // Actions
  receiveThreat(unit) {
    this.threat[unit.team] += unit.attack
    this.threatenedBy[unit.team].push(unit.square.address.toString())
  }
  add(unit) { this.units.push(unit) }
  remove(unit) { this.units = this.units.filter(it => it != unit) }
  setCommand(command) { this.unit.command = command }

  // Lifecycle
  assignThreat() { this.unit.assignThreat }
  beforeMove() { this.unit.beforeMove }
  move() { this.unit.move }
  afterMove() { this.units.forEach(unit => unit.afterMove()) }
  resolve() {
    if(this.isContested)
      this.units = this.units.filter(unit => !unit.isOverwhelmed)
    if(!this.isResolved)
      [...this.units].forEach(unit => unit.rebound())
  }
}

module.exports = Square