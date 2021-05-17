create or replace view games_vw as
  select
    games.*,
    red_player.username as red_player,
    blue_player.username as blue_player,
    count(all_states.id) as moves_taken,
    last_state.ts as last_move_ts,
    last_state.to_move,
    last_state.units,
    last_state.id as last_state_id,
    maps.terrain,
    maps.name as map_name,
    maps.ranks,
    maps.files
  from games
  join players as red_player on red_player.id = games.red_player_id
  join players as blue_player on blue_player.id = games.blue_player_id
  join maps on games.map_id = maps.id
  join (
    select 
      game_id,
      max(ts) as max_ts
    from states
    group by game_id
  ) as maxes on maxes.game_id = games.id
  left join states as all_states on all_states.game_id = games.id
  left join states as last_state on last_state.game_id = games.id AND last_state.ts = maxes.max_ts
  group by games.id;