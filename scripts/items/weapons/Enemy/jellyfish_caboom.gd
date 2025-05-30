extends BaseWeapon
class_name JellyCaboom

signal attack

var friends = []

@onready var timer = get_parent().get_node("Timer")
@onready var electricity = $AudioStreamPlayer

func attack_ranged():
	electricity.play()
	look_for_friends()
	#this implementation is obviously bad performance wise
	#but I could not figure out a better way to do that with same flexebility
	for i in self.get_children():
		if i == electricity:
			continue
		var relative = MishaMath.relative_grid(i.global_position, global_position)
		if abs(relative.x) + abs(relative.y) < weapon_range:
			if not check_wall(global_position, i.global_position):
				i.visible = true
				i.is_used = true
	
	attack.emit()
	
	timer.start()
	await timer.timeout
	
	for i in self.get_children():
		if i == electricity:
			continue
		i.visible = false
		i.is_used = false

func look_for_friends():
	friends.clear()
	weapon_range = 3 #range of 3 basically implies a range of 2(because of the for loop)
	for i in range(weapon_range, -1, -1):
		var j = weapon_range - i
		ray_of_friendship(global_position, Vector2(global_position.x + i * TILE_SIZE, global_position.y + j * TILE_SIZE))
		ray_of_friendship(global_position, Vector2(global_position.x + i * TILE_SIZE, global_position.y + j * TILE_SIZE * -1))
		ray_of_friendship(global_position, Vector2(global_position.x + i * TILE_SIZE * -1, global_position.y + j * TILE_SIZE))
		ray_of_friendship(global_position, Vector2(global_position.x + i * TILE_SIZE * -1, global_position.y + j * TILE_SIZE * -1))

func ray_of_friendship(start: Vector2, end: Vector2) -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start, end, 1)
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		if result.collider.is_in_group("jelly"):
			if friends.find(result.collider, 0) == -1:
				weapon_range += 1
				friends.append(result.collider)
			if not (MishaMath.approx_equals(result.collider.global_position.x, end.x, TILE_SIZE) and MishaMath.approx_equals(result.collider.global_position.y, end.y, TILE_SIZE)):
				ray_of_friendship(result.collider.global_position, end)

func check_wall(start: Vector2, end: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start, end, 1)
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		if not result.collider.is_in_group("entity"):
			return true
	return false
