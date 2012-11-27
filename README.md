# MIDWAY
# The Velti Battleship Tournament Server

## Request Authentication

In the http header of any request you need to include your Midway API key

        curl -H "Midway-API-Key: 333333" http://localhost:3000/teams/2/maps

### Errors

* **invalid_midway_api_key** Api Key does not match team id
* **missing_api_key** Api Key is missing

##GET /teams/:team_id/maps

###Request paramaters:

_none_

### Example Request

        curl -H "Midway-API-Key: 333333" -H "Content-Type: application/json" http://localhost:3000/teams/2/maps

### Example Response

The list of your maps.

* **maps** An array of all the team's uploaded maps
* **error** An error, if applicable.

```
{
  "grids": { 1 => ["oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxo"],
             2 => ["oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxo"]}
}
```

### Errors

```
{
  "error_code": "INVALID_API_KEY",
  "message": "The api key does not match the team_id"
}
```

* INVALID_API_KEY, The api key does not match the team_id

##POST /teams/:team_id/maps

Adds a map to your team's list.  You need to upload at least one map before you can play

### Request Parameters

* **grid** map in a ten element array, a ships position is marked with an 'x'. The grid must contain

| Type of ships    | Size |
|------------------|------|
| aircraft carrier | 5    |
| Battleship       | 4    |
| submarine        | 3    |
| cruiser          | 3    |
| destroyer        | 2    |


### Example Request

        curl -H "Midway-API-Key: 333333" -H "Content-Type: application/json" -X POST -d '{"grid":["oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxox","oxoxoxoxo"]}' http://localhost:3000/teams/2/maps

### Example Response

The new map. If the POST was not successful then status code 422 will be returned along with the error which prevented the service from being created.

* **id** Unique identifier for the map, used to update or delete it
* **error** An error, if applicable.

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

* INVALID_API_KEY, The api key does not match the team_id
* INVALID_MAP, The map is invalid

