# Pressure Game API
{:.no_toc}

This is the API for running a client for the game **Pressure**.

* Table of contents
{:toc}

## Endpoints

### GETs
All GET requests respond with status code `200: Ok` on success, and status code `404: Not found` if the resource cannot be found.

#### GET /
API docs. You are here.

#### GET /map
Lists all [maps](#map).

#### GET /map/:id
Get a [map](#map) by `id`.

#### GET /match
Lists all [matches](#match).

#### GET /match/:id
Get an [expanded match](#match) by `id`.

#### GET /player/:id
Get a [player](#player) by `id`.

#### GET /player/from-discord-id/:discord-id
Get a [player](#player) by `discord-id`.

#### GET /player/:id/matches
List all [matches](#match) in which selected player (by `id`) is a participant.

#### GET /player/:id/maps
List all [maps](#map) submitted by selected player (by `id`).

#### GET /state/:id
Get a [state](#state) by `id`.

### POSTs
All `POST` requests are authenticated with bearer token against [Discord's OAuth2](https://discordjs.guide/oauth2/). All posts respond with status code `403: Forbidden` on authentication failure. Include in header:
```
Authorization: Bearer <client token>
```

#### POST /map/submit-map
Submit a new map.

##### Request Body
{:.no_toc}

Field | Datatype | Description
-|-|-
name | string | name of map
data | [board](#board) | initial board for map

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
201 | 'Created' | map successfully submitted
406 | 'Invalid map' | map is invalid

#### POST /match/find-match
Engage in matchmaking system to find a match. Starts a match if a satisfactory challenge exists, otherwise posts a challenge.

##### Request Body
{:.no_toc}

Field | Datatype | Description
----- | -------- | -----------
match_configuration | [match configuration](#match-configuration) (optional) | specify match configuration
password | string (optional) | use a password to match with a specific player

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
201 | [expanded match](#match) | challenge found, match was created
202 | 'Accepted' | no challenge was found, new challenge was issued
409 | 'Duplicate challenge' | player has already submitted a challenge that looks like this one

#### POST /match/:id/submit-move
Submit a move in a match selected by `id`. Overwrites any previous command submitted by the player.

##### Request Body
{:.no_toc}

Field | Datatype | Description
--- | --- | ---
commands | [[command](#command)] | array of commands to submit

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
202 | 'Accepted' | commands were successfully submitted
401 | 'Not a participant of match' | player is not a participant of match
406 | 'Invalid move' | commands are invalid
406 | 'Match is over' | match is over

#### POST /match/:id/forecast
Forecast the result of a set of commands on match selected by `id`. A player can submit moves for their opponent's units here as well. The state of the match is not affected at all.

##### Request Body
{:.no_toc}

Field | Datatype | Description
--- | --- | ---
commands | [[command](#command)] | array of commands to forecast

##### Responses
{:.no_toc}

Code | Payload | Expectation
--- | --- | ---
200 | [state](#state) | forecasted state of the board

#### POST /match/:id/concede
Concede a match selected by `id`.

##### Request Body
{:.no_toc}

None

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
202 | 'Accepted' | match successfully conceded
401 | 'Not a participant of match' | player is not a participant of match
406 | 'Match is over' | match is over

#### POST /match/:id/offer-draw
Offer draw in match selected by `id`.

##### Request Body
{:.no_toc}

None

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
202 | 'Accepted' | match successfully conceded
401 | 'Not a participant of match' | player is not a participant of match
406 | 'Not acceptable' | match is over
409 | 'Conflict' | player has already offered a draw in this match

#### POST /player/list-webhooks
List webhooks registered to authenticated player. See: [webhooks](#webhooks).

##### Request Body
{:.no_toc}

None

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
200 | [[webhook](#webhook)] |

#### POST /player/register-webhook
Register a webhook url for events associated to authenticated player. See: [webhooks](#webhooks).

##### Request Body
{:.no_toc}

Field | Datatype | Description
--- | --- | ---
url | string | webhook url

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
202 | "Accepted" | webhook successfully registered

#### POST /player/disconnect-webhook
Disconnect a webhook from authenticated player. See: [webhooks](#webhooks).

##### Request Body
{:.no_toc}

Field | Datatype | Description
--- | --- | ---
id | integer | webhook id

##### Responses
{:.no_toc}

Code | Payload | Expectation
---- | ------- | -----------
202 | 'Accepted' | webhook successfully removed
404 | 'Not found' | webhook not found

## Datatypes

#### Address

Represents a square of the board, a string structured as `<character><number>` ex: `b5`. Character case is ignored, `c5` and `C5` are equivalent. The character represents the file (column) starting from the left at `a` and the number represents the rank (row) starting from the bottom at 1. The file after `z` is `aa`.

~~~
3 | a3 b3 c3
2 | a2 b2 c2
1 | a1 b1 c1
------------
  | a  b  c
~~~

#### Board

Represents the game board. The board is an array of arrays of [squares](#square), where the first square of the first row is the upper left corner and the last square of the first row is the upper right corner.

#### Command

A command.

Field | Datatype | Description
--- | --- | ---
address | [address](#address) | address of square of unit to command
direction | [direction](#direction) | direction unit should move

#### Direction

A string representing a direction, among:

~~~ json
[ "NW", "N", "NE"
  "W",  "C", "E"
  "SW", "S", "SE" ]
~~~

#### Map

A map is an initial board state that a match can be played on.

Field | Datatype | Description
--- | --- | ---
id | integer | internal database key
creator_id | integer | id of [player](#player) who submitted map
ranks | integer | number of ranks (rows) in map
files | integer | number of files (columns) in map
data | [board](#board) | initial board state for map

#### Match

A match played between two players.

Field | Datatype | Description
--- | --- | ---
id | integer | internal database key
red_player_id | integer | id of [player](#player) controlling red
blue_player_id | integer | id of [player](#player) controlling blue
match_configuration_id | integer | id of [match configuration](#match-configuration) for the match

##### Expanded
{:.no_toc}

Field | Datatype | Description
--- | --- | ---
id | integer | internal database key
red_player | [player](#player) | player controlling red
blue_player | [player](#player) | player controlling blue
match_configuration | [match configuration](#match-configuration) | match configuration for the match
over | boolean | true if match is over -- whether by defeat, draw, or concession
winner | <'red' \| 'blue' \| null> | color of match winner, or null if draw or match still in progress
states | [integer] | array of ids of [states](#state) associated with this match
last_state | [state](#state) | latest state of this match

#### Match Configuration

Settings defining rules for a match.

Field | Datatype | Description
--- | --- | ---
id | integer | internal database id
map_id | integer | id of map to play on, random map selected if not defined
actions_per_turn | integer | number of commands each player is allowed to submit per turn
turn_progression | string ([cron expression](http://www.cronmaker.com)) | if defined, turns will automatically proceed based on the cron expression (UTC) regardless of command submissions -- otherwise, turns will progress immediately when both players have submitted commands


#### Player

A player.

Field | Datatype | Description
--- | --- | ---
id | integer | internal database id
discord_id | string | Discord id
username | string | Discord username

#### Square

Represents a square of the board. When submitting a map, all fields may be omitted -- the heading will be generated automatically (in fact any provided heading is always discarded) and it will default to a *plains* square with no unit.

Field | Datatype | Description
--- | --- | ---
address | [address](#address) | address of square
terrain | [terrain](#terrain) | terrain of square
unit | [unit](#unit) | unit at square
threat | [threat](#threat) | threat on square
threatened_by | [threatened by](#threatened-by) | addresses of squares threatening this one

##### Terrain

Represents terrain for a square.

Field | Datatype | Description
----- | --------- | -----------
category | string | type of the terrain square, should inform behavior
type | string | name of terrain square, should inform the look of the square
offense_modifier | integer | offense modifier provided for any unit occupying this square
defense_modifier | integer | defense modifier provided for any unit occupying this square
passable | boolean | true if the terrain can be occupied by a unit
obstructs | boolean | true if the terrain obstructs sniper threat lines

##### Unit

Represents unit occupying a square.

Field | Datatype | Description
----- | --------- | -----------
team | <'red' \| 'blue'> | the team this unit belongs to
category | string | unit category
type | string | unit type
command | [direction](#direction) | direction unit will move next turn unless a new command is given
valid_commands | [[direction](#direction)] | array of directions this unit is able to receive in commands
threatens | [[address](#address)] | array of addresses of squares that this unit threatens
base_offense | integer | base offense of this unit, as defined by its type and category
base_defense | integer | base defense of this unit, as defined by its type and category
offense | integer | computed offense after modifiers
defense | integer | computed defense after modifiers
overwhelmed | boolean | true if unit's defense is lower than [threat](#threat) imposed on this square by opposing team


##### Threat

Tallies threat on a square.

Field | Datatype | Description
----- | --------- | -----------
red | number | amount of threat imposed by red units on this square
blue | number | amount of threat imposed by blue units on this square

##### Threatened By

Identifies units threatening a square.

Field | Datatype | Description
----- | --------- | -----------
red | [[address](#address)] | array of headings of red units that threaten this square
blue | [[address](#address)] | array of headings of blue units that threaten this square

#### State

Represents a board state of a match.

Field | Datatype | Description
id | integer | internal database id
match_id | integer | id of [match](#match) this state is associated with
data | [board](#board) | board data representing this state
loser | <'red' \| 'blue' \| 'both' \| null> | team that has lost the game based on current state

#### Webhook

A webhook that can be registered to a user to be triggered on events. See [webhooks](#webhooks).

Field | Datatype | Description
id | integer | internal database id
url | string | target url for webhook

## Webhooks

Webhooks can be [registered to a player](#post-playerregister-webhook), and they will be triggered on any [event](#event) involving that player. A `POST` request will be sent to the webhook url with body:

Field | Datatype | Description
reason | <'match over' \| 'next turn' \| 'draw offer'> | indicates reason webhook was triggered
match_id | integer | id of match for which the event was triggered

## TODO

- Set up automated turn progression
- Set up query string filters on [GET /map](#get-map) and [GET /match](#get-match).