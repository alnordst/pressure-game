create or replace view games_vw as
  select
    games.*,
    count(all_states.id) as moves_taken,
    last_state.ts as last_move_ts,
    last_state.to_move,
    last_state.units,
    maps.terrain,
    maps.name as map_name,
    maps.ranks,
    maps.files
  from games
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