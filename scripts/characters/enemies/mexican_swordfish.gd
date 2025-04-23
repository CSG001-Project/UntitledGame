extends BaseEnemy


@onready var sprite = $Sprite
@onready var static_body = $StaticBody2D
@onready var move = $Movement
@onready var death = $Death

func _ready() -> void:
	super()
	
	static_body.top_level = true
	static_body.global_position = global_position

#No animation yet
#func _physics_process(_delta: float) -> void:
#	sprite.play("idle_"+direction)

#enemy moves / attacks / etc
func make_turn() -> void:
	await get_tree().physics_frame
	
	var tile_map = get_parent().get_node("Level0/Layer0")
	var player = get_parent().get_node("Player")
	var path = tile_map.find_path(tile_map.local_to_map(tile_map.to_local(global_position)), tile_map.local_to_map(tile_map.to_local(player.global_position)))
	var distance_to_player = abs((global_position.x - player.global_position.x)) + abs((global_position.y - player.global_position.y))
	
	if(distance_to_player <= 40):
		await weapon.attack_melee()
	elif randf() > 0.8:
		# rng induced seizure idfk
		var new_position = Vector2(32,0).rotated(randi_range(0,3)*deg_to_rad(90))
		
		if !static_body.test_move(transform, new_position):
			move.play()
			static_body.position += new_position
	elif path:
		if !static_body.test_move(transform, to_local(path[0])):
			move.play()
			static_body.position = path[0]

# despawn / death explosion / etc
func die() -> void:
	super()
	death.play()
	queue_free()

func update_sprite() -> void:
	update_direction(to_local(static_body.global_position).x)
	
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", static_body.global_position, 0.2)
