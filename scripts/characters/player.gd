extends BaseCharacter

@onready var timer = $Timer
@onready var sprite = $Sprite
@onready var arrow = $Sprite/Arrow
@export var weapon: PackedScene

const TILE_SIZE: int = 32

func _ready() -> void:
	super()
	# Update initial sprite position
	sprite.top_level = true
	sprite.global_position = global_position

func _physics_process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	# Visual indicator of where the player is aiming
	arrow.rotation = lerp_angle(arrow.rotation, angle, 0.1)
	
	sprite.play("idle_"+direction)
	
	if Input.is_action_just_released("attack") && weapon.is_ranged:
		if try_shooting():
			await shoot()
			TurnManager.enemy_turn()
	elif Input.is_action_just_released("attack"):
		# Wait for the attack to finish and then call the enemy turn
		update_direction(sin(angle))
		await weapon.attack()
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
	
	if !input.y:
		input.x = Input.get_axis("move_left", "move_right")
	if !input.x:
		input.y = Input.get_axis("move_up", "move_down")
	
	return input

func update_sprite() -> void:
	update_direction(sprite.to_local(global_position).x)
	
	# Tween the sprite to the new position when the turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)

func try_shooting() -> bool:
	var mouse_position: Vector2 = get_global_mouse_position()
	var cool_name_for_a_variable: Vector2 = global_position - mouse_position
	var sum_of_boolshit: int = snappedi(abs(cool_name_for_a_variable.x) + abs(cool_name_for_a_variable.y), 32);
	if not sum_of_boolshit <= weapon.range * TILE_SIZE:
		return false
	else:
		if check_collisions(global_position, mouse_position):
			return false
		else:
			return true

func check_collisions(start: Vector2, end: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start, end)
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		return true
	return false

func shoot():
	var weapon_instance = weapon.instantiate()
	var mouse_position: Vector2 = get_global_mouse_position()
	mouse_position.x = snappedi(mouse_position.x, 32)
	mouse_position.y = snappedi(mouse_position.y, 32)
	weapon_instance.global_rotation = (global_position - mouse_position).angle()
	
	while not weapon_instance.global_position.x.is_equal_approx(mouse_position.x) and weapon_instance.global_position.y.is_equal_approx(mouse_position.y):
		weapon_instance.position = weapon_instance.position.move_toward(mouse_position, 1)
