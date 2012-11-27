# MIDWAY
# The Velti Battleship Tournament Server

## Request Authentication

In the http header of any request you need to include your Midway API key

```
curl -H "Midway-API-Key: 333333" http://localhost:3000/teams/2/maps
```

### Errors

```
{
  "error_code": "INVALID_API_KEY",
  "message": "The api key does not match the team_id"
}
```

* INVALID_API_KEY, Api Key does not match team id
* INVALID_TEAM_ID, Team Id does not exist
* MISSING_API_KEY, Api Key is missing

##GET /teams/:team_id/maps

###Request paramaters:

_none_

### Example Request

```
curl -H "Midway-API-Key: 333333" -H "Content-Type: application/json" http://localhost:3000/teams/2/maps
```

### Example Response

The list of your maps.

* **grids** An array of all the team's uploaded maps
* **error_code** An error code, if applicable.
* **message** An error message, if applicable.

```
{
  "grids": { 1 => [[0, 0, 5, "across"], [6, 2, 4, "across"], [3, 6, 3, "down"], [7, 8, 3, "across"], [4, 6, 2, "across"]],
             2 => [[2, 1, 5, "across"], [0, 3, 4, "down"], [2, 6, 3, "across"], [6, 4, 3, "across"], [3, 4, 2, "down"]]}
}
```

##POST /teams/:team_id/maps

Adds a map to your team's list.  You need to upload at least one map before you can play

### Request Parameters

* **grid** map in a ten element array, a ships position is marked with an 'x'. The grid is of the form x pos, y pos, direction of ship.  The grid must contain

| Type of ships    | Size |
|------------------|------|
| aircraft carrier | 5    |
| Battleship       | 4    |
| submarine        | 3    |
| cruiser          | 3    |
| destroyer        | 2    |

* [[2, 1, 5, "across"], [0, 3, 4, "down"], [2, 6, 3, "across"], [6, 4, 3, "across"], [3, 4, 2, "down"]] would be


| |0|1|2|3|4|5|6|7|8|9|
|-|-|-|-|-|-|-|-|-|-|-|
|0| | | | | | | | | | |
|1| | |x|x|x|x|x| | | |
|2| | | | | | | | | | |
|3|x| | | | | | | | | |
|4|x| | |x| | |x|x|x| |
|5|x| | |x| | | | | | |
|6|x| |x|x|x| | | | | |
|7| | | | | | | | | | |
|8| | | | | | | | | | |
|8| | | | | | | | | | |
|9| | | | | | | | | | |


### Example Request

```
curl -H "Midway-API-Key: 333333" -H "Content-Type: application/json" -X POST -d '{"grid":[[2, 1, 5, "across"], [0, 3, 4, "down"], [2, 6, 3, "across"], [6, 4, 3, "across"], [3, 4, 2, "down"]]}' http://localhost:3000/teams/2/maps
```

### Example Response

The new map. If the POST was not successful then status code 422 will be returned along with the error which prevented the map from being created.

* **id** Unique identifier for the map, used to update or delete it
* **error_code** An error code, if applicable.
* **message** An error message, if applicable.

```
{
  "id": "2"
}
```


### Errors

```
{
  "error_code": "INVALID_MAP",
  "message": "The map is invalid"
}
```

* NOT_ENOUGH_SHIPS, Not enough ships
* TOO_MANY_SHIPS, Too many ships
* SHIPS_OVERLAP, Ships in collision
* OUT_OF_RANGE, Ships are positioned outside of map


##GET /teams/:team_id/game

This returns the state of the current game

### Request Parameters

_none_

### Example Request

```
curl -H "Midway-API-Key: 333333" -H "Content-Type: application/json" http://localhost:3000/teams/2/game
```

### Example Response

{
  "game_id": "2",
  "grid": ["oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxo"]
}

##POST /teams/:team_id/game

This plays your next move in the current game.  Games are started and ended automatically.

### Request Parameters

* **move** A two element array with the x and y position of your move

### Return Parameters

* **game_id** The id of the current game
* **grid**  The current grid with 'x' marking any hit position
* **opponent_id** Your opponents team id
* **status** Status of the move can be "miss", "hit", "hit and destroyed"
* **move** A two element array with the x and y position of your move
* **game_status** Game status can be 'playing', 'ended'
* **moves** Current move count

### Example Request

```
curl -H "Midway-API-Key: 333333" -H "Content-Type: application/json" -X POST -d '{"move":[2,1]}' http://localhost:3000/teams/2/game
```

### Example Response

{
  "game_id": 2,
  "grid": ["oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxo"]
  "opponent_id": 3,
  "status": "hit",
  "move": [2,1],
  "game_status": "ended",
  "moves": 34
}
