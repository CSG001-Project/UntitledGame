extends BaseWeapon
class_name JellyCaboom

var friends = []

@export var shock: Node2D

# Called when the node enters the scene tree for the first time.
func attack_ranged():
	look_for_friends()
	#this implementation is obviously bad performance wise
	#but I could not figure out a better way to do that with same flexebility
	for i in self.find_children(""):
		if (((abs(i.global_position.x) - 16) / TILE_SIZE) + ((abs(i.global_position.y) - 16) / TILE_SIZE)) < weapon_range:
			print(((abs(i.global_position.x) - 16) / TILE_SIZE) + ((abs(i.global_position.y) - 16) / TILE_SIZE))
			if not check_wall(global_position, i.global_position):
				i.attack_mlee

func look_for_friends():
	friends.clear()
	weapon_range = 3 #range of 3 basically implies a range of 2(because of the for loop)
	for i in range(weapon_range, 0):
		var j = weapon_range - i
		ray_of_friendship(global_position, Vector2(i * TILE_SIZE, j * TILE_SIZE))
		ray_of_friendship(global_position, Vector2(i * TILE_SIZE, j * TILE_SIZE * -1))
		ray_of_friendship(global_position, Vector2(i * TILE_SIZE * -1, j * TILE_SIZE))
		ray_of_friendship(global_position, Vector2(i * TILE_SIZE * -1, j * TILE_SIZE * -1))

func ray_of_friendship(start: Vector2, end: Vector2) -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start, end, 1)
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		if result.collider.is_in_group("jelly"):
			if friends.find(result.collider, 0) > -1:
				weapon_range += 1
				friends.append(result.collider)
			if not MishaMath.approx_equals(result.collider.global_position, end, TILE_SIZE):
				ray_of_friendship(result.collider.global_position, end)

func check_wall(start: Vector2, end: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start, end, 1)
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		if not result.collider.is_in_group("enemy"):
			if not result.collider == get_parent().get_parent().get_node("Player"):
				return true
	return false
