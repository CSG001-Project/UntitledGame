extends Node2D

# SET IN INSPECTOR. If need to use in code, do not grab directly from here- use get_enemy_data() instead.
	## enemy_id: Specify the enemies to spawn in each zone by their ids in the format, enemies' definitions and respective ids can be found in enemies.tres.
	## spawn_count: Specify the number of enemies to spawn in each zone at random single tiles in their area.
@export var zone_properties = {
	1: {
		"enemy_id": null,
		"spawn_count": null,
	},
	2: {
		"enemy_id": null,
		"spawn_count": null,
	},
	3: {
		"enemy_id": null,
		"spawn_count": null,
	},
	4: {
		"enemy_id": null,
		"spawn_count": null,
	},
	5: {
		"enemy_id": null,
		"spawn_count": null,
	},
	6: {
		"enemy_id": null,
		"spawn_count": null,
	}
}


@onready var zone_map: TileMapLayer = $EnemyZoneLayer;
@onready var enemy_definitions: Resource = load("res://scripts/map_generation/enemies.tres");


## Runs right after room is instatiated- Handles loading room-data from the designer-friendly tilemap format to its' usable form.
func _ready() -> void:
	load_room();



## Returns all defined (non-null) enemy zones in the format 
## { 
##         1(zone id):    
##        {
##            "enemy_id": 4
##            "spawn_count": 1
##         }
## }
func get_enemy_data() -> Dictionary:
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



func load_room():
	var enemy_data: Dictionary = get_enemy_data();
	var zones = get_zones_cell_positions();
	
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
			var random_square = zone_squares[randi_range( 0, zone_squares.size()-1 )];
			create_enemy(enemy_node, enemy_properties, random_square);


## Loads enemy stats into enemy and instantiates it at a specified location
func create_enemy(node: Resource, properties: Dictionary, position: Vector2i):
	var enemy: Node2D = node.instantiate();
	
	add_child(enemy);
	
	# local_position is in pixels, multiplying tile position by 32 gives us the pixel position
	position *= 32;
	
	# +16 to move enemy to the center of the tile instead of top left
	enemy.position = Vector2(position.x + 16, position.y + 16);
	
	# Load base properties and stats from enemy definition file.
	for property_key: String in properties:
		enemy.set(property_key, properties[property_key]);

## Returns dictionary of arrays of defined zones by zone_id
func get_zones_cell_positions() -> Dictionary:
	var tiles: Dictionary = {};
	
	for cell_pos in zone_map.get_used_cells():
		var data = zone_map.get_cell_tile_data(cell_pos);
		var zone_id = data.get_custom_data("zone_id");
		
		if (!tiles.has(zone_id)): 
			tiles[zone_id] = Array();
		
		tiles[zone_id].append(cell_pos);
		
	return tiles
