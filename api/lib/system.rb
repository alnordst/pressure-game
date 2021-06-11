require 'httparty'
require_relative 'database'

class System
  class << self
    def authorize(token)
      url = 'https://discord.com/api/users/@me'
      headers = { authorization: "Bearer #{token}" }
      response = HTTParty.get url, headers: headers
      if response.code == 200
        if Database.conn['players'].where(discord_id: response.body.id).empty?
          Database.conn['players'].insert(
            discord_id: response.body.id,
            username: response.body.username
          )
        else
          Database.conn['players'].where(discord_id: response.body.id).update(
            username: response.body.username
          )
        end
        Database.conn['players'].first(discord_id: response.body.id)
      end
    end

    def register_webhook(player, url)
    end

    def submit_map(player, map)
    end
  end
end
