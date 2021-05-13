class Terrain {
  constructor(name, type) {
    this.name = name
    this.defenseModifier = 0
    this.isPassable = true
    this.obstructs = false
  }

  static fromChar(char) {
    if(char == '#')
      return new ImpassableTerrain('mountain')
    else if(char == '^')
      return new ProtectedTerrain('forest')
    else if(char == '.')
      return new ExposedTerrain('road')
    else
      return new DefaultTerrain('plains')
  }

  get clone() {
    return Terrain.fromChar(this.toString())
  }
}


class DefaultTerrain extends Terrain {
  toString () {
    return '-'
  }
}


class ProtectedTerrain extends Terrain {
  constructor(name) {
    super(name)
    this.defenseModifier = 1
    this.obstructs = true
  }

  toString () {
    return '^'
  }
}


class ExposedTerrain extends Terrain {
  constructor(name) {
    super(name)
    this.defenseModifier = -1
  }

  toString () {
    return '_'
  }
}


class ImpassableTerrain extends Terrain {
  constructor(name){
    super(name)
    this.isPassable = false
    this.obstructs = true
  }

  toString () {
    return '#'
  }
}


module.exports = Terrain