extends StaticBody2D

@export var weapon: PackedScene

@onready var timer = $Timer
@onready var sprite = $Sprite2D

const TILE_SIZE: int = 32

func _ready() -> void:
	# Update initial sprite position, update sprite when turn is finished
	sprite.global_position = global_position
	TurnManager.update_sprite.connect(update_sprite)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("right_click"):
		attack()
		TurnManager.enemy_turn()
	else:
		var axis = get_input_axis()
	
		if axis != Vector2.ZERO and TurnManager.player_turn and timer.is_stopped():
			var motion = axis * TILE_SIZE
		
			# Check if the player can move to the tile, move the player to the tile (without the sprite)
			if !test_move(transform, motion):
				timer.start()
				position += motion
				# Now let the enemies calculate their turn
				TurnManager.enemy_turn()

func get_input_axis() -> Vector2:
	var input = Vector2.ZERO
	
	# Input axis, ensure it is NOT normalised
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	
	return input

func update_sprite() -> void:
	# Tween the sprite to the new position when the turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)

func attack() -> void:
	var mouse_position : Vector2 = get_global_mouse_position()
	var player_pos = get_parent().get_node("PlayerCharacter").global_position
	var weapon_instance = weapon.instantiate()
	
	var upmost: Vector2 = player_pos + Vector2(0, -16); var up_dist: float = mouse_position.distance_squared_to(upmost)
	var leftmost: Vector2 = player_pos + Vector2(-16, 0); var left_dist: float = mouse_position.distance_squared_to(leftmost)
	var downmost: Vector2 = player_pos + Vector2(0, 16); var down_dist: float = mouse_position.distance_squared_to(downmost)
	var rightmost: Vector2 = player_pos + Vector2(16, 0); var right_dist: float = mouse_position.distance_squared_to(rightmost)
	
	var min_distance: float = min(min(up_dist, left_dist), min(down_dist, right_dist)) 
	
	weapon_instance.global_transform = global_transform
	if min_distance == up_dist:
		weapon_instance.global_position = upmost
		weapon_instance.global_rotation_degrees -= 0
	elif min_distance == left_dist:
		weapon_instance.global_position = leftmost
		weapon_instance.global_rotation_degrees -= 90
	elif min_distance == down_dist:
		weapon_instance.global_position = downmost
		weapon_instance.global_rotation_degrees -= 180
	elif min_distance == right_dist:
		weapon_instance.global_position = rightmost
		weapon_instance.global_rotation_degrees -= 270
	get_parent().add_child(weapon_instance)
	
	await get_tree().create_timer(0.2).timeout
	weapon_instance.queue_free()
