extends BaseWeapon
class_name JellyCaboom

var friends = []
var supports = []
var support = preload("res://scenes/items/weapons/jelly_support.tscn")

@onready var timer = $Timer

@export var shock: Node2D

# Called when the node enters the scene tree for the first time.
func attack_ranged():
	#this implementation is obviously bad performance wise
	#but I could not figure out a better way to do that with same flexebility
	for i in range(weapon_range):
		for j in range(weapon_range - i):
			if i == 0:
				if j == 0:
					continue
				else:
					if not check_wall(global_position, global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE)):
						var support_instance = support.instantiate()
						add_child(support_instance)
						support_instance.global_position = global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE)
						supports.append(support_instance)
					if not check_wall(global_position, global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE * -1)):
						var support_instance = support.instantiate()
						add_child(support_instance)
						support_instance.global_position = global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE * -1)
						supports.append(support_instance)
			
			if j != 0:
				if not check_wall(global_position, global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE)):
					var support_instance = support.instantiate()
					add_child(support_instance)
					support_instance.global_position = global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE)
					supports.append(support_instance)
				if not check_wall(global_position, global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE * -1)):
					var support_instance = support.instantiate()
					add_child(support_instance)
					support_instance.global_position = global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE * -1)
					supports.append(support_instance)
				if not check_wall(global_position, global_position + Vector2(i * TILE_SIZE * -1, j * TILE_SIZE)):
					var support_instance = support.instantiate()
					add_child(support_instance)
					support_instance.global_position = global_position + Vector2(i * TILE_SIZE * -1, j * TILE_SIZE)
					supports.append(support_instance)
				if not check_wall(global_position, global_position +Vector2(i * TILE_SIZE * -1, j * TILE_SIZE * -1)):
					var support_instance = support.instantiate()
					add_child(support_instance)
					support_instance.global_position = global_position + Vector2(i * TILE_SIZE * -1, j * TILE_SIZE * -1)
					supports.append(support_instance)
			else:
				if not check_wall(global_position, global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE)):
					var support_instance = support.instantiate()
					add_child(support_instance)
					support_instance.global_position = global_position + Vector2(i * TILE_SIZE, j * TILE_SIZE)
					supports.append(support_instance)
				if not check_wall(global_position, global_position + Vector2(i * TILE_SIZE * -1, j * TILE_SIZE)):
					var support_instance = support.instantiate()
					add_child(support_instance)
					support_instance.global_position = global_position + Vector2(i * TILE_SIZE * -1, j * TILE_SIZE)
					supports.append(support_instance)

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
				return false
	return false
