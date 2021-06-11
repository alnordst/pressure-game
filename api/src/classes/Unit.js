const Artillery = require('./units/Artillery')
const Command = require('./units/Command')
const Infantry = require('./units/Infantry')
const Sniper = require('./units/Sniper')
const Tank = require('./units/Tank')

class Unit {
  static create(square, {team, type}) {
    let unitClasses = {
      artillery: Artillery,
      command: Command,
      infantry: Infantry,
      sniper: Sniper,
      tank: Tank
    }
    let UnitClass = unitClasses[type]
    return new UnitClass(square, team)
  }

  constructor(square, team) {
    this.square = square
    this.team = team
    this.baseOffense = 1
    this.baseDefense = 1
    this.offenseModifier = 0
    this.defenseModifier = 0
    this.threatens = []
    this.validCommands = []
  }

  toObj(slim=false) {
    let essential = {
      category: this.category,
      type: this.type,
      team: this.team,
      nextCommand: this.nextCommand
    }
    let extra = {
      previousSquare: this.previousSquare,
      command: this.command,
      threatens: this.threatens,
      validCommands: this.validCommands,
      offense: this.offense,
      defense: this.defense,
      isOverwhelmed: this.isOverwhelmed,
      hasMoved: this.hasMoved
    }
    return slim ? essential : {...essential, ...extra}
  }

  // Status
  get offense() {
    return this.baseOffense + this.offenseModifier
  }
  get defense() {
    return this.baseDefense + this.defenseModifier + this.square.defenseModifier
  }
  get isOverwhelmed() {
    let opposition = this.team == 'blue' ? 'red' : 'blue'
    return this.defense < this.square.threat[opposition]
  }
  get hasMoved() {
    return this.square != this.previousSquare && this.previousSquare
  }

  // Actions
  threaten(square) {
    this.threatens.push(square.address.toString())
    square.receiveThreat(this)
  }
  moveTo(square) {
    this.previousSquare = this.square
    this.square = square
    this.previousSquare.remove(this)
    this.square.add(this)
  }
  setCommand(command) {
    if(this.validCommands.includes(command))
      this.command = command
  }
  setNextCommand(command) {
    if(this.validCommands.includes(command))
      this.nextCommand = command
  }

  // Lifecycle
  assignThreat() {}
  beforeMove() {}
  move() {
    if(this.command) {
      square = this.square.neighbors({headings: [this.command]})[0]
      if(square.isPassable)
        this.moveTo(square)
    }
  }
  afterMove() {}
  rebound() {
    this.square.remove(this)
    this.previousSquare.add(this)
    this.square = this.previousSquare
    this.previousSquare = null
  }
}

module.exports = Unit