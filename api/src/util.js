module.exports = {
  pick: (...arr) => ({from: (obj) => {
    return arr.reduce((acc, key) => {
      if(key in obj)
        acc[key] = obj[key]
      return acc
    }, {})
  }})
}