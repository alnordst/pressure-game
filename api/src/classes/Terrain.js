class Terrain {
  constructor(name, char, type) {
    this.name = name
    this.char = char
    this.type = type
    this.defenseModifier = 0
    this.passable = true
    this.obstructs = false
  }

  static fromChar(char) {
    if(char == 'f')
      return new ProtectedTerrain('forest', char)
    else if(char == 'm')
      return new ImpassableTerrain('mountain', char)
    else if(char == 'r')
      return new ExposedTerrain('road', char)
    else
      return new StandardTerrain('plains', char)
  }

  toString() {
    return this.char
  }

  get toObj() {
    return {
      name: this.name,
      type: this.type,
      passable: this.passable,
      obstructs: this.obstructs
    }
  }
}


class StandardTerrain extends Terrain {
  constructor(name, char) {
    super(name, char)
    this.type = 'standard'
  }
}

class ProtectedTerrain extends Terrain {
  constructor(name, char) {
    super(name, char) 
    this.type = 'protected'
    this.defenseModifier = 1
    this.obstructs = true
  }
}

class ExposedTerrain extends Terrain {
  constructor(name, char) {
    super(name, char)
    this.type = 'exposed'
    this.defenseModifier = -1
  }
}

class ImpassableTerrain extends Terrain {
  constructor(name, char) {
    super(name, char)
    this.type = 'impassable'
    this.passable = false
    this.obstructs = true
  }
}

module.exports = Terrain