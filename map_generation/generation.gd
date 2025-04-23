extends Node2D

@export var main_room_scene: PackedScene
@export var room_scenes: Array[PackedScene]
@export var tilemap: TileMapLayer
@export var hallway_tile_id: Vector2i
@export var number_of_rooms: int = 5

var room_size_in_tiles = Vector2i(40, 16)
var tile_size = 32
var tile_positions: Dictionary = {}


var room_positions: Dictionary = {};
var room_entries: Dictionary = {};
var room_exits: Dictionary = {};
var room_enemies: Dictionary = {};


@onready var enemy_definitions: Resource = load("res://scripts/map_generation/enemies.tres");


@onready var a_star = AStarGrid2D.new()

var all_entries: Array = [];
var all_exits: Array = [];

var room_bounds: Dictionary = {};
 
func _ready():
	generate_level()
 
func generate_level():
	var main_pos = Vector2i(0, 0);
	place_room(main_room_scene, main_pos);
	var open_positions = [main_pos];
	var placed = 1;
	var tries = 0;
	
	while (placed < number_of_rooms) && tries < 100:
		var base = open_positions.pick_random()
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		directions.shuffle()
		for dir in directions:
			var new_pos = base + dir
			if room_positions.has(new_pos):
				continue
 
			var scene = room_scenes.pick_random()
			if place_room(scene, new_pos):
				open_positions.append(new_pos)
				placed += 1
				break
		tries += 1
	
	init_astar_grid()
	connect_rooms()
	$EnemyHandler.set_rooms(room_entries, room_exits, room_bounds, room_enemies);
 
func place_room(scene: PackedScene, grid_pos: Vector2i) -> bool:
	var room_instance = scene.instantiate()
	var room_tilemap: TileMapLayer = room_instance.get_node_or_null("TileLayer")
	var room_entry_exit_tilemap = room_instance.get_node_or_null("EntryExitLayer")
	var room_enemy_zones = room_instance.get_node_or_null("EnemyZoneLayer");

	assert(room_tilemap, "TileLayer not found")
	assert(room_entry_exit_tilemap, "EntryExitLayer not found")
	assert(room_enemy_zones, "EnemyZoneLayer not found")
	
	var pixel_pos = grid_pos * room_size_in_tiles
	
	room_entries[grid_pos] = []
	room_exits[grid_pos] = []
	
	# Get room entry and exits
	for cell_pos in room_entry_exit_tilemap.get_used_cells():
		var data = room_entry_exit_tilemap.get_cell_tile_data(cell_pos)
		var type: String = data.get_custom_data("type")
		
		if type == "entry":
			room_entries[grid_pos].append(pixel_pos + cell_pos)
			all_entries.push_back(pixel_pos + cell_pos)
		elif type == "exit":
			room_exits[grid_pos].append(pixel_pos + cell_pos)
			all_exits.push_back(pixel_pos + cell_pos)
	
	# Validate that the room has exactly 1 entry and 2 exits
	if room_entries[grid_pos].size() != 1 || room_exits[grid_pos].size() != 2:
		push_warning("Room at " + str(grid_pos) + " doesn't have 1 entry and 2 exits. Found " + 
			str(room_entries[grid_pos].size()) + " entries and " + 
			str(room_exits[grid_pos].size()) + " exits.")
	
	# Copy RoomLayer tiles to master tilemap
	var used_cells = room_tilemap.get_used_cells()
	var pattern: TileMapPattern = room_tilemap.get_pattern(used_cells)
	tilemap.set_pattern(pixel_pos, pattern)
	
	room_bounds[grid_pos] = Rect2i(grid_pos, grid_pos + used_cells.pop_back());
	
	for tile in used_cells:
		var tile_data = room_tilemap.get_cell_tile_data(tile)
		if tile_data and tile_data.get_custom_data("is_solid"):
			var global_tile_position = pixel_pos + tile
			tile_positions[global_tile_position] = global_tile_position
	
	room_positions[grid_pos] = Rect2(pixel_pos * tile_size, room_size_in_tiles * tile_size)


	room_enemies[grid_pos] = load_and_get_room_enemies(room_enemy_zones, room_instance.zone_properties, pixel_pos);

	
	room_instance.queue_free()
	return true


#enemy_zones,  
func load_and_get_room_enemies(enemy_zones: TileMapLayer, enemy_zone_definitions: Dictionary, room_grid_position: Vector2i) -> Array:
	var enemies = [];

	var enemy_data: Dictionary = get_enemy_data(enemy_zone_definitions);
	var zones = get_zones_cell_positions(enemy_zones);
	
	for zone_id in zones:
		assert(enemy_data.has(zone_id), "Defined enemy-zones must define their properties")
		
		var zone_squares: Array = zones[zone_id];
		var zone_props: Dictionary = enemy_data[zone_id];
		
		var zone_enemy_id: int = zone_props["enemy_id"];
		assert(enemy_definitions.enemies.has(zone_enemy_id), str("No enemy with enemy_id {", zone_enemy_id, "} is defined in enemies.tres"));
		
		var enemy_definition: Dictionary = enemy_definitions.enemies[zone_enemy_id];
		var enemy_properties = enemy_definition["properties"];
		var enemy_node = load(enemy_definition["filepath"]);
		
		# Create enemies at random squares within its' enemy zone
		for i in range(0, zone_props["spawn_count"]):
			var random_square = room_grid_position + zone_squares[randi_range( 0, zone_squares.size()-1 )];
			var enemy = create_enemy(enemy_node, enemy_properties, random_square);
			enemies.push_back( enemy );
	return enemies;


## Loads enemy stats into enemy and instantiates it at a specified location
func create_enemy(node: Resource, properties: Dictionary, position: Vector2i) -> Node2D:
	var enemy: Node2D = node.instantiate();
	
	add_child(enemy);
	
	# position is in grid square pos, multiplying tile position by 32 gives us the pixel position
	position *= 32;
	
	# +16 to move enemy to the center of the tile instead of top left
	enemy.position = Vector2(position.x + 16, position.y + 16);
	
	# Load base properties and stats from enemy definition file.
	for property_key: String in properties:
		enemy.set(property_key, properties[property_key]);

	enemy.set("can_act", false);
	return enemy;


## Returns dictionary of arrays of defined zones by zone_id
func get_zones_cell_positions(zone_map: TileMapLayer) -> Dictionary:
	var tiles: Dictionary = {};
	
	for cell_pos in zone_map.get_used_cells():
		var data = zone_map.get_cell_tile_data(cell_pos);
		var zone_id = data.get_custom_data("zone_id");
		
		if (!tiles.has(zone_id)): 
			tiles[zone_id] = Array();
		
		tiles[zone_id].append(cell_pos);
		
	return tiles


## Returns all defined (non-null) enemy zones in the format 
## { 
##         1(zone id):    
##        {
##            "enemy_id": 4
##            "spawn_count": 1
##         }
## }
func get_enemy_data(zone_properties: Dictionary) -> Dictionary:
	var enemy_data: Dictionary = {};
	
	for zone: int in zone_properties:
		var zone_props = zone_properties[zone];
		
		var enemy_id = zone_props["enemy_id"];
		if (enemy_id != null): 
			
			var spawn_count = zone_props.spawn_count;
			assert(spawn_count != null, "Exception: zones' enemy spawn count must not be null when zones' enemy id is defined");
			
			enemy_data[zone] = Dictionary(
			{
				"enemy_id": enemy_id, 
				"spawn_count": spawn_count
			});
		
	return enemy_data;


 
func init_astar_grid():
	a_star = AStarGrid2D.new()
	a_star.region = tilemap.get_used_rect().grow(32);
	a_star.cell_size = Vector2i(1, 1)
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	a_star.update()
	
	for tile_pos in tile_positions.keys():
		if all_entries.has(tile_pos) || all_exits.has(tile_pos):
			continue;
		else:
			a_star.set_point_solid(tile_pos, true);
	a_star.update();
 
 
func find_set(room_sets: Dictionary, x):
	if room_sets[x] != x:
		room_sets[x] = find_set(room_sets, room_sets[x])
	return room_sets[x]
 
func union_sets(room_sets: Dictionary, x, y):
	room_sets[find_set(room_sets, x)] = find_set(room_sets, y)
 
 
func connect_rooms():
	var connections = []
	var connected_entries = {}
	var connected_exits = {}
	
	print("Number of rooms: ", room_positions.size())
	print("Number of entries: ", _count_total_entries())
	print("Number of exits: ", _count_total_exits())
	
	# Generate all possible connections between exits and entries of different rooms
	for source_pos in room_exits.keys():
		for exit_pos in room_exits[source_pos]:
			for target_pos in room_entries.keys():
				# Skip connections within the same room
				if source_pos == target_pos:
					continue 
					
				for entry_pos in room_entries[target_pos]:
					var distance = (exit_pos - entry_pos).length()
					connections.append({
						"source_room": source_pos,
						"exit_pos": exit_pos,
						"target_room": target_pos,
						"entry_pos": entry_pos,
						"distance": distance
					})
	
	print("Total possible connections: ", connections.size())
	
	# Sort by shortest distance first
	connections.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
	var room_sets = {}
	for pos in room_positions.keys():
		room_sets[pos] = pos
	
	var paths_created = 0
	
	# Connect rooms while ensuring each entry/exit is used at most once
	for connection in connections:
		var source_room = connection["source_room"]
		var target_room = connection["target_room"]
		var exit_pos = connection["exit_pos"]
		var entry_pos = connection["entry_pos"]
		
		# Skip if creates a cycle (already connected)
		if find_set(room_sets, source_room) == find_set(room_sets, target_room):
			continue
		
		# Skip if the entry or exit is already used
		if connected_exits.has(exit_pos) or connected_entries.has(entry_pos):
			continue
		
		#print("Attempting path from exit ", exit_pos, " to entry ", entry_pos)
		var path = a_star.get_id_path(
			Vector2i(exit_pos.x, exit_pos.y), 
			Vector2i(entry_pos.x, entry_pos.y)
		)
		
		if path.size() > 0:
			print("Found valid path with ", path.size(), " points")
			union_sets(room_sets, source_room, target_room)
		
			# Mark the path as solid for normal paths
			# for i in range(1, path.size() - 1):
			#	var point = Vector2i(path[i].x, path[i].y)
			#	a_star.set_point_solid(point, true)
			
			# Set tiles for the hallway
			for point_id in path:
				var point = Vector2i(point_id.x, point_id.y)
				if point != exit_pos and point != entry_pos:
					tilemap.set_cell(point, 0, hallway_tile_id)
					
			connected_exits[exit_pos] = true
			connected_entries[entry_pos] = true
			paths_created += 1
	
	print("Created ", paths_created, " paths")
	
	# Check if all rooms are connected
	var connected_component = find_set(room_sets, room_positions.keys()[0])
	var disconnected_rooms = 0
	for room_pos in room_positions.keys():
		if find_set(room_sets, room_pos) != connected_component:
			push_warning("Warning: Room at " + str(room_pos) + " is not connected to the main level!")
			disconnected_rooms += 1
	
	if disconnected_rooms > 0:
		print("WARNING: ", disconnected_rooms, " rooms are disconnected!")
	
	# If some exits remain unused, add them to be connected to each other
	var unused_exits = []
	for room_pos in room_exits.keys():
		for exit_pos in room_exits[room_pos]:
			if not connected_exits.has(exit_pos):
				unused_exits.append({"room": room_pos, "pos": exit_pos})
	
	print("Unused exits: ", unused_exits.size())
	
	# Connect unused exits to each other when possible
	var bonus_paths = 0
	for i in range(unused_exits.size()):
		for j in range(i+1, unused_exits.size()):
			var exit1 = unused_exits[i]
			var exit2 = unused_exits[j]
		
			# Skip if they're from the same room
			if exit1["room"] == exit2["room"]:
				continue
				
			if connected_exits.has(exit1["pos"]) or connected_exits.has(exit2["pos"]):
				continue
			
			print("Trying bonus path from ", exit1["pos"], " to ", exit2["pos"])    
			var path = a_star.get_id_path(
				Vector2i(exit1["pos"].x, exit1["pos"].y), 
				Vector2i(exit2["pos"].x, exit2["pos"].y)
			)
			
			if path.size() > 0:
				print("Created bonus path with ", path.size(), "points")
				
				# Mark the path as solid for bonus paths
				for k in range(1, path.size() - 1):
					var point = Vector2i(path[k].x, path[k].y)
					a_star.set_point_solid(point, true)
				
				# Set tiles for the hallway
				for point_id in path:
					var point = Vector2i(point_id.x, point_id.y)
					if point != exit1["pos"] and point != exit2["pos"]:
						tilemap.set_cell(point, 0, hallway_tile_id)
				
				connected_exits[exit1["pos"]] = true
				connected_exits[exit2["pos"]] = true
				bonus_paths += 1
				break
	
	print("Created ", bonus_paths, " bonus paths")
 
 
func _count_total_entries() -> int:
	var count = 0
	for room_pos in room_entries.keys():
		count += room_entries[room_pos].size()
	return count
 
func _count_total_exits() -> int:
	var count = 0
	for room_pos in room_exits.keys():
		count += room_exits[room_pos].size()
	return count
