extends BaseEnemy

@onready var sprite = $Sprite
@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D
@export var weapon: Node2D

func _ready() -> void:
	super()
	
	sprite.global_position = global_position

func _physics_process(_delta: float) -> void:
	sprite.play("idle_"+direction)

#enemy moves / attacks / etc
func make_turn() -> void:
	await get_tree().physics_frame
	
	# Should probably change player position to a generic target position and set the target to player when in range
	var player_position: Vector2 = get_parent().get_node("Player").global_position
	var near_player = (global_position.x == player_position.x and abs(global_position.y - player_position.y) <= 40) or (global_position.y == player_position.y and abs(global_position.x - player_position.x) <= 40)
	
	if near_player:
		#atack code here
		var angle = sin(snappedf((to_local(player_position)).angle(), deg_to_rad(90)))
		
		update_direction(angle)
		print("attack")
	else:
		#getting next path node to pathtrace to player
		makepath()
	
		#making the vector into a angle/movement thingy
		var angle = snappedf((to_local(navigation_agent.get_next_path_position())).angle(), deg_to_rad(90))
		var movement: Vector2 = Vector2(cos(angle), sin(angle))
	
		#and then finally move 
		if !test_move(transform, movement * 32):
			position += movement * 32
		#an easy fix

func makepath() -> void: 
	navigation_agent.target_position = get_parent().get_node("Player").global_position

# despawn / death explosion / etc
func die() -> void:
	super()
	
	queue_free()

func update_sprite() -> void:
	update_direction(sprite.to_local(global_position).x)
	
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
