module.exports = (fields) => function(req, res, next) {
  let missing = fields.filter(field => !(field in req.body))
  if(missing.length)
    res.status(400).send(`Include field(s) ${missing.join(', ')} in request.`)
  else
    next()
}