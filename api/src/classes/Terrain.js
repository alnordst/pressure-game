class Terrain {
  constructor({category, type}) {
    this.category = category
    this.type = type

    this.defenseModifier = 0
    this.isPassable = true
    this.isObstructed = false

    switch(category) {
      case 'standard':
        break
      case 'protected':
        this.defenseModifier = 1
        this.isObstructed = true
        break
      case 'exposed':
        this.defenseModifier = -1
        break
      case 'impassable':
        this.isPassable = false
        this.isObstructed = true
        break
    }
  }

  toObj(slim=false) {
    let essential = {
      category: this.category,
      type: this.type
    }
    let extra = {
      defenseModifier: this.defenseModifier,
      isPassable: this.isPassable,
      isObstructed: this.isObstructed
    }
    return slim ? essential : {...essential, ...extra}
  }
}

module.exports = Terrain