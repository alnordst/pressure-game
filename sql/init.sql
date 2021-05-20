CREATE TABLE players (
  id INT PRIMARY KEY AUTO_INCREMENT,
  discord_id VARCHAR(20) NOT NULL,
  username VARCHAR(50) DEFAULT NULL,
  discord_notifications BOOL NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE maps (
  id INT PRIMARY KEY AUTO_INCREMENT,
  map_name VARCHAR(50) NOT NULL,
  ranks INT NOT NULL,
  files INT NOT NULL,
  terrain VARCHAR(1023) NOT NULL,
  units VARCHAR(1023) NOT NULL,
  creator_id INT DEFAULT NULL,
  FOREIGN KEY (creator_id)
    REFERENCES players (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE games (
  id INT PRIMARY KEY AUTO_INCREMENT,
  red_player_id INT NOT NULL,
  blue_player_id INT NOT NULL,
  map_id INT NOT NULL,
  strict BOOL NOT NULL DEFAULT 0,
  is_complete BOOL NOT NULL DEFAULT 0,
  winner VARCHAR(4) DEFAULT NULL,
  FOREIGN KEY (red_player_id)
    REFERENCES players (id)
    ON DELETE CASCADE,
  FOREIGN KEY (blue_player_id)
    REFERENCES players (id)
    ON DELETE CASCADE,
  FOREIGN KEY (map_id)
    REFERENCES maps (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE states (
  id INT PRIMARY KEY AUTO_INCREMENT,
  game_id INT NOT NULL,
  to_move VARCHAR(4) NOT NULL,
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  units VARCHAR(1023) NOT NULL,
  FOREIGN KEY (game_id)
    REFERENCES games (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE challenges (
  id INT PRIMARY KEY AUTO_INCREMENT,
  ts timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  map_id INT DEFAULT NULL,
  pw VARCHAR(31) DEFAULT NULL,
  player_id INT NOT NULL,
  strict BOOL NOT NULL DEFAULT 0,
  FOREIGN KEY (map_id)
    REFERENCES maps (id)
    ON DELETE CASCADE,
  FOREIGN KEY (player_id)
    REFERENCES players (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE draw_offers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  ts timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  game_id INT NOT NULL,
  player_id INT NOT NULL,
  FOREIGN KEY (game_id)
    REFERENCES games (id)
    ON DELETE CASCADE,
  FOREIGN KEY (player_id)
    REFERENCES players (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE webhooks (
  id INT PRIMARY KEY AUTO_INCREMENT,
  target_url VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE webhook_registrations (
  id INT PRIMARY KEY AUTO_INCREMENT,
  player_id INT NOT NULL,
  webhook_id INT NOT NULL,
  FOREIGN KEY (player_id)
    REFERENCES players (id)
    ON DELETE CASCADE,
  FOREIGN KEY (webhook_id)
    REFERENCES webhooks (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE VIEW players_vw AS
  SELECT
    id,
    discord_id,
    username
  FROM players;

CREATE OR REPLACE VIEW maps_vw AS
  SELECT
   maps.*,
   players.username AS creator
  FROM maps
  JOIN players ON maps.creator_id = players.id;

CREATE OR REPLACE VIEW games_vw AS
  SELECT
    games.*,
    red_player.username AS red_player,
    blue_player.username AS blue_player,
    COUNT(all_states.id) AS moves_taken,
    first_state.ts AS init_ts,
    last_state.ts AS last_move_ts,
    MAX(last_state.to_move) AS to_move,
    MAX(last_state.units) AS units,
    MAX(last_state.id) AS last_state_id,
    maps.terrain,
    maps.map_name,
    maps.ranks,
    maps.files
  FROM games
  JOIN players AS red_player ON red_player.id = games.red_player_id
  JOIN players AS blue_player ON blue_player.id = games.blue_player_id
  JOIN maps ON games.map_id = maps.id
  JOIN (
    SELECT 
      game_id,
      MIN(ts) AS min_ts
    FROM states
    GROUP BY game_id
  ) AS mins ON mins.game_id = games.id
  JOIN (
    SELECT 
      game_id,
      MAX(ts) AS max_ts
    FROM states
    GROUP BY game_id
  ) AS maxes ON maxes.game_id = games.id
  LEFT JOIN states AS all_states ON all_states.game_id = games.id
  LEFT JOIN states AS first_state ON first_state.game_id = games.id AND first_state.ts = mins.min_ts
  LEFT JOIN states AS last_state ON last_state.game_id = games.id AND last_state.ts = maxes.max_ts
  GROUP BY games.id;

CREATE OR REPLACE VIEW states_vw AS
  SELECT
    *
  FROM states;