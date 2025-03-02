extends BaseEnemy

@onready var sprite = $Sprite
@export var weapon: Node2D

func _ready() -> void:
	super()
	
	sprite.top_level = true
	sprite.global_position = global_position

func _physics_process(_delta: float) -> void:
	sprite.play("idle_"+direction)

#enemy moves / attacks / etc
func make_turn() -> void:
	await get_tree().physics_frame
	
	var tile_map = get_parent().get_node("Level0/Layer0")
	var player = get_parent().get_node("Player")
	var path = tile_map.find_path(tile_map.local_to_map(tile_map.to_local(global_position)), tile_map.local_to_map(tile_map.to_local(player.global_position)))
	
	if randf() > 0.8:
		# rng induced seizure idfk
		var new_position = Vector2(32,0).rotated(randi_range(0,3)*deg_to_rad(90))
		
		if !test_move(transform, new_position):
			position += new_position
	elif path:
		if !test_move(transform, to_local(path[0])):
			position = path[0]

# despawn / death explosion / etc
func die() -> void:
	super()
	
	queue_free()

func update_sprite() -> void:
	update_direction(sprite.to_local(global_position).x)
	
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
