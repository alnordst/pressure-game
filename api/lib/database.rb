require 'sequel'

module Database
  @db = Sequel.connect(
    adapter: 'mysql'
    host: ENV['DB_HOST'],
    database: 'pressure'
    user: 'root',
    password: ENV['DB_PASSWORD'],
  )

  def self.conn
    @db
  end
end