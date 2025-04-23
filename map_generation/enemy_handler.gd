extends Node2D

var entries: Dictionary = {};
var exits: Dictionary = {};

var currently_in_room = null;

var room_bounds: Dictionary = {};


# FORMAT:
# {
#	room1_pos: 
#	{
#		"state": "uncleared" | "locked" | "cleared";
#		"entryways": []; # entry and exit positions.
#		"enemies": [];
#	}
# }
var rooms: Dictionary = {};

func set_rooms(room_entries: Dictionary, room_exits: Dictionary, bounds: Dictionary, enemy_references: Dictionary):
	entries = room_entries;
	exits = room_exits;
	room_bounds = bounds;
	
	for room_pos in bounds:
		rooms[room_pos] = {
			"state": "uncleared",
			"entryways": [entries[room_pos], exits[room_pos][0], exits[room_pos][1]],
			"enemies": enemy_references[room_pos],
		}
	
func validate_move(player_grid_pos: Vector2i):
	print( str("validating move: ", player_grid_pos) );
	
	for room_pos: Vector2i in room_bounds:
		if ( !room_bounds[room_pos].has_point(player_grid_pos) ): continue;

		if ( !rooms[room_pos]["entryways"].has(player_grid_pos) ): return true;
		if ( rooms[room_pos]["state"] == "locked" ): return false;


	return true;
	#return TurnManager.enemies != 0;


func move(player_grid_pos: Vector2i):
	for room_pos: Vector2i in room_bounds:
		if ( !room_bounds[room_pos].has_point(player_grid_pos) ): continue;

		var room = rooms[room_pos];

		if ( room["entryways"].has(player_grid_pos) and room["state"] != "locked" ):
			if (currently_in_room == null):
				currently_in_room = room_pos;
				TurnManager.enemies = room["enemies"];
			else:
				currently_in_room = null;
				TurnManager.enemies = [];

	
