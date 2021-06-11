# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Bot.create(discord_id:'841137656904679445', username: 'Pressure Game')
Bot.create(discord_id:'841759845996167181', username: 'Pressure Game Dev')
Player.create(discord_id:'136327880803221504', username: 'Six')
Map.create(name:'Test', creator_id:1, data:"[[{\"unit\":{\"team\":\"blue\",\"type\":\"command\"}},{\"unit\":{\"team\":\"blue\",\"type\":\"artillery\"}},{\"unit\":{\"team\":\"blue\",\"type\":\"sniper\"}},{},{},{},{},{},{},{\"unit\":{\"team\":\"red\",\"type\":\"tank\"}},{\"unit\":{\"team\":\"red\",\"type\":\"infantry\"}},{\"unit\":{\"team\":\"red\",\"type\":\"command\"}}]]")