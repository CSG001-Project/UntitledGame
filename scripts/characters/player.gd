extends BaseCharacter

@onready var timer = $Timer
@onready var sprite = $Sprite
@onready var arrow = $Arrow
@onready var static_body = $StaticBody2D
@export var weapon: Node2D

const TILE_SIZE: int = 32

func _ready() -> void:
	super()
	
	static_body.top_level = true
	static_body.global_position = global_position

func _physics_process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((arrow.global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	# Visual indicator of where the player is aiming
	arrow.rotation = lerp_angle(arrow.rotation, angle, 0.1)
	
	sprite.play("idle_"+direction)
	
	if Input.is_action_just_released("attack") and weapon.weapon_range == 0:
		# Wait for the attack to finish and then call the enemy turn
		update_direction(sin(angle))
		await weapon.attack_melee()
		TurnManager.enemy_turn()
	elif Input.is_action_just_released("attack") and weapon.weapon_range > 0:
		if try_shooting():
			await weapon.attack_ranged()
			TurnManager.enemy_turn()
	else:
		var axis = get_input_axis()
		
		if axis != Vector2.ZERO and TurnManager.player_turn and timer.is_stopped():
			var motion = axis * TILE_SIZE
			
			# Check if the player can move to the tile, move the player to the tile (without the sprite)
			if !static_body.test_move(transform, motion):
				timer.start()
				static_body.position += motion
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
	update_direction(to_local(static_body.global_position).x)
	# Tween the sprite to the new position when the turn is finished
	var tween = get_tree().create_tween()
	var rotation_tween = get_tree().create_tween()
	
	tween.tween_property(self, "global_position", static_body.global_position, 0.2)
	rotation_tween.set_trans(Tween.TRANS_CUBIC)
	
	if direction == "left":
		rotation_tween.tween_property(sprite, "rotation_degrees", -15, 0.15).set_ease(Tween.EASE_IN)
	else:
		rotation_tween.tween_property(sprite, "rotation_degrees", 15, 0.15).set_ease(Tween.EASE_IN)
	
	rotation_tween.tween_property(sprite, "rotation_degrees", 0, 0.15).set_ease(Tween.EASE_OUT)

func try_shooting() -> bool:
	var mouse_position: Vector2 = get_global_mouse_position()
	var cool_name_for_a_variable: Vector2 = global_position - mouse_position
	var sum_of_boolshit: int = snappedi(abs(cool_name_for_a_variable.x) + abs(cool_name_for_a_variable.y), 32);
	if not sum_of_boolshit <= weapon.weapon_range * TILE_SIZE:
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
	
	return not result.is_empty()
