extends BaseEnemy

var turn_counter: int = 2
var has_moved: bool = false

@onready var sprite = $Sprite
@onready var static_body = $StaticBody2D
@onready var move1 = $Move1
@onready var move2 = $Move2
@onready var diee = $Death

func _ready() -> void:
	super()
	
	static_body.top_level = true
	static_body.global_position = global_position

func _physics_process(_delta: float) -> void:
	sprite.play("idle_"+direction)

#enemy moves / attacks / etc
func make_turn() -> void:
	await get_tree().physics_frame
	
	var enemies = get_tree().get_nodes_in_group("jelly")
	var tile_map = get_parent().get_node("Level0/Layer0")
	var player
	var mindist = 0x0fffffff
	for jel in enemies:
		if jel != self and global_position.distance_squared_to(jel.global_position) < mindist:
			mindist = global_position.distance_squared_to(jel.global_position)
			player = jel
	var path = tile_map.find_path(tile_map.local_to_map(tile_map.to_local(global_position)), tile_map.local_to_map(tile_map.to_local(player.global_position)))
	
	has_moved = false
	if not turn_counter:
		TurnManager.action_in_progress = true
		await weapon.attack_ranged()
		TurnManager.action_in_progress = false
		has_moved = true
		turn_counter = 2
	elif randf() > 0.8:
		# rng induced seizure idfk
		var new_position = Vector2(32,0).rotated(randi_range(0,3)*deg_to_rad(90))
		
		if !static_body.test_move(transform, new_position):
			static_body.position += new_position
			turn_counter -= 1
			if randf() > 0.5:
				move1.play()
			else:
				move2.play()
			has_moved = true
	elif path:
		if !static_body.test_move(transform, to_local(path[0])):
			static_body.position = path[0]
			turn_counter -= 1
			if randf() > 0.5:
				move1.play()
			else:
				move2.play()
			has_moved = true
	var attempts_to_move: int = 0
	while not has_moved && attempts_to_move < 101:
		var new_position = Vector2(32,0).rotated(randi_range(0,3)*deg_to_rad(90))
		
		if !static_body.test_move(transform, new_position):
			static_body.position += new_position
			turn_counter -= 1
			if randf() > 0.5:
				move1.play()
			else:
				move2.play()
			has_moved = true
		else:
			attempts_to_move += 1

# despawn / death explosion / etc
func die() -> void:
	super()
	diee.play()
	queue_free()

func update_sprite() -> void:
	update_direction(to_local(static_body.global_position).x)
	
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", static_body.global_position, 0.2)
