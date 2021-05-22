const express = require('express')
const cors = require('cors')

const app = express()



app
  .use(express.json())
  .use(cors())
  .disable('x-powered-by')
  .get('*', require('./routes/gets'))
  .post('*', require('./middleware/authenticate'))
  .post('*', require('./routes/posts'))

app.listen(process.env.PORT, () => {
  console.log(`Listening on port ${process.env.PORT}.`)
})

process.on('SIGINT', function() {
  process.exit();
});