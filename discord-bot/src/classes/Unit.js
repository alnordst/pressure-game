class Unit {
  constructor(team) {
    this.team = team
    this.name = ''
    this.offense = 1
    this.defense = 2
  }

  static fromChar(char) {
    let team = char === char.toUpperCase() ? 0 : 1
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

  get clone() {
    return Unit.fromChar(this.toString())
  }
}


class ArtilleryUnit extends Unit {
  constructor(team) {
    super(team)
    this.name = 'artillery'
  }

  toString () {
    return this.team == 0 ? 'A' : 'a'
  }

  compute(fetcher) {
    //todo
  }
}


class CommandUnit extends Unit {
  constructor(team) {
    super(team)
    this.name = 'command'
  }

  toString () {
    return this.team == 0 ? 'C' : 'c'
  }
}


class InfantryUnit extends Unit {
  constructor(team) {
    super(team)
    this.name = 'infantry'
  }

  toString () {
    return this.team == 0 ? 'I' : 'i'
  }
}


class SniperUnit extends Unit {
  constructor(team) {
    super(team)
    this.name = 'sniper'
  }

  toString () {
    return this.team == 0 ? 'S' : 's'
  }
}


class TankUnit extends Unit {
  constructor(team) {
    super(team)
    this.name = 'tank'
    this.offense = 2
  }

  toString () {
    return this.team == 0 ? 'T' : 't'
  }
}


module.exports = Unit