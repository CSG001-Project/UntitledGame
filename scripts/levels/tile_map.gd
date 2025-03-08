extends TileMapLayer

var astar_grid = AStarGrid2D.new()

func _ready() -> void:
	init_grid()
	update_grid()

func init_grid() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = tile_set.tile_size
	astar_grid.update()

func update_grid() -> void:
	for x in range(astar_grid.region.position.x, astar_grid.region.end.x):
		for y in range(astar_grid.region.position.y, astar_grid.region.end.y):
			var id = Vector2i(x,y)
			
			if get_cell_source_id(id) == -1 or get_cell_tile_data(id).get_custom_data("is_solid"):
				astar_grid.set_point_solid(id, true)

func find_path(start: Vector2i, end: Vector2i) -> Array:
	if start == end or !astar_grid.is_in_boundsv(start) or !astar_grid.is_in_boundsv(end):
		return []
	
	var id_path = astar_grid.get_id_path(start, end)
	var path: Array
	
	for i in range(1, id_path.size()):
		path.append(to_global(map_to_local(id_path[i])))
	return path
