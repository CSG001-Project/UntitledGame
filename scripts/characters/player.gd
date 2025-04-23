extends BaseCharacter

@onready var timer = $Timer
@onready var sprite = $Sprite
@onready var arrow = $Arrow
@onready var static_body = $StaticBody2D
@onready var health = $Health
@onready var healthbar = $"../HUD/Control/HealthBar"
@onready var weapon = $Beam
@onready var death = $Death

var is_in_action: bool = false

const TILE_SIZE: int = 32
const HALF_TILE: int = 16

func _ready() -> void:
	super()
	healthbar.set_health_bar(health.max_health, health.health)
	if health:
		health.connect("health_changed", _on_health_changed)
	static_body.top_level = true
	static_body.global_position = global_position

func _physics_process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((arrow.global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	# Visual indicator of where the player is aiming
	arrow.rotation = lerp_angle(arrow.rotation, angle, 0.1)
	
	sprite.play("idle_"+direction)
	
	if Input.is_action_just_released("attack") and weapon.weapon_range == 0 and !is_in_action and !TurnManager.action_in_progress:
		# Wait for the attack to finish and then call the enemy turn
		is_in_action = true
		update_direction(sin(angle))
		await weapon.attack_melee()
		is_in_action = false
		TurnManager.enemy_turn()
	elif Input.is_action_just_released("attack") and weapon.weapon_range > 0 and !is_in_action and !TurnManager.action_in_progress:
		if try_shooting():
			is_in_action = true
			await weapon.attack_ranged()
			is_in_action = false
			TurnManager.enemy_turn()
	elif !is_in_action and !TurnManager.action_in_progress:
		var axis = get_input_axis()
		
		if axis != Vector2.ZERO and TurnManager.player_turn and timer.is_stopped():
			var motion = axis * TILE_SIZE
			
			# Check if the player can move to the tile, move the player to the tile (without the sprite)
			if !static_body.test_move(transform, motion):
				is_in_action = true
				timer.start()
				static_body.position += motion
				is_in_action = false
				# Now let the enemies calculate their turn
				TurnManager.enemy_turn()
	if Input.is_key_pressed(KEY_Z):
		self.health.health -= 1
	if Input.is_key_pressed(KEY_1):
		weapon = $Harpoon
	if Input.is_key_pressed(KEY_2):
		weapon = $Beam


func _on_health_changed(_difference: int):
	healthbar.set_health_bar(self.health.health, self.health.max_health)
	if self.health.health <= 0:
		death.play()

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
	mouse_position.x = MishaMath.snapperi(mouse_position.x, TILE_SIZE) + HALF_TILE; mouse_position.y = MishaMath.snapperi(mouse_position.y, TILE_SIZE) + HALF_TILE
	var aim_offset: Vector2 = mouse_position - global_position
	var snapped_distance: int = MishaMath.snapperi(abs(aim_offset.x) + abs(aim_offset.y), TILE_SIZE);
	if not snapped_distance <= weapon.weapon_range * TILE_SIZE:
		return false
	else:
		if check_collisions(global_position, mouse_position):
			return false
		else:
			return true


func check_collisions(start: Vector2, end: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start, end, 1)
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		if result.collider.is_in_group("enemy") && MishaMath.approx_equals(result.position.x, end.x, TILE_SIZE) && MishaMath.approx_equals(result.position.y, end.y, TILE_SIZE):
			return false
		else:
			return true
	else:
		return false

func _on_health_depleted() -> void:
	death.play()
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://scenes/main/title.tscn")
