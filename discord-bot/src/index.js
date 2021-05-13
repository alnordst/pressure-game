const Discord = require('discord.js')
const Game = require('./classes/Game')

const client = new Discord.Client()
let game

client.on('ready', () => {
  console.log(`Logged in as ${client.user.tag}!`)
})

client.on('message', async msg => {
  try{
    let conditions = [
      !msg.author.bot,
      msg.content.startsWith(process.env.PREFIX)
    ]
    for(let condition of conditions)
      if(!condition)
        return
    
    let commandBody = msg.content.slice(process.env.PREFIX.length)
    let args = commandBody.split(' ')
    let command = args.shift().toLowerCase()

    if(command === 'ping')
      msg.reply(`I'm awake!`)

    if(command === 'begin' || command === 'restart') {
      let taggedUser = msg.mentions.members.first() || msg.guild.members.cache.get(args[1])
      if(!taggedUser)
        msg.channel.send(`No opponent selected. Begin a game like this:\n${process.env.PREFIX}begin ${msg.author} narrow`)
      else {
        let mapList = await Game.getAvailableMaps()
        let mapName = args.find(arg => mapList.includes(arg))
        if(!mapName)
          msg.channel.send(`Map not found. Valid maps are: ${mapList.join(', ')}`)
        else {
          game = new Game(msg.author, taggedUser.user, mapName)
          await game.init()
          let text = await game.toGif()
          msg.channel.send(text, { files: [ './board.gif' ] })
        }
      }
    }

    if(['move', 'mv', 'm'].includes(command)) {
      if(game === undefined)
        msg.channel.send(`Start a game first.\n${process.env.PREFIX}begin @<opponent> <mapname>`)
      else if(msg.author == game.nextPlayer) {
        let from, to
        if(args.length == 1 && args[0].length == 4){
          from = args[0].toUpperCase().slice(0,2)
          to = args[0].toUpperCase().slice(2,4)
        } else if(args.length == 1 && args[0].length == 5 && ':-|\\/~./;'.includes(args[0][2])) {
          from = args[0].toUpperCase().slice(0,2)
          to = args[0].toUpperCase().slice(3,5)
        } else if(args.length == 2 && args[0].length == 2 && args[1].length == 2) {
          from = args[0].toUpperCase()
          to = args[1].toUpperCase()
        } else
          msg.channel.send(`Invalid address. Use format:\n${process.env.PREFIX}move A1:B2`)
        
        if(from && to){
          let valid = game.move(from, to)
          console.log('\nvalid', valid)
          console.log('\ngame', game)
          if(valid){
            let text = await game.toGif()
            msg.channel.send(text, { files: [ './board.gif' ] })
          } else
            msg.channel.send(`Invalid move, try again.`)
        }
      } else
        msg.channel.send('Its not your turn!')
    }

    if(command === 'undo') {
      if(game.history.length == 0) {
        msg.channel.send('No moves to undo!')
      } else {
        game.undo()
        let text = await game.toGif()
        msg.channel.send(text, { files: [ './board.gif' ] })
      }
    }

    if(command === 'test') {
      msg.channel.send(`whatup, its the dev bot`)
      console.log(msg.author)
    }
  } catch(err) {
    console.log(err)
  }
})
client.login(process.env.TOKEN)