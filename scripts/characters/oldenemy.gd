extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var health = $Health
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var weapon: Node2D

var near_player: bool = false


func _ready() -> void:
	# Update sprite position, add self to the list of enemies that can take turns
	sprite.global_position = global_position
	TurnManager.enemies.append(self)
	TurnManager.update_sprite.connect(update_sprite)

func turn() -> void:
	# Wait for the previous enemy/player to move
	await get_tree().physics_frame

	if health.health == 0:
		TurnManager.enemies.erase(self)
		queue_free()

	# AI sttuff that makes it move to player 
	
	# getting player position 
	var player_position: Vector2 = get_parent().get_node("Player").global_position
	
	if (global_position.x == player_position.x and abs(global_position.y - player_position.y) <= 40) or (global_position.y == player_position.y and abs(global_position.x - player_position.x) <= 40):
		near_player = true
	else:
			near_player = false
	
	if near_player:
		#atack code here
		print("attack")
	else:
		#getting next path node to pathtrace to player
		makepath()
	
		#making the vector into a angle/movement thingy
		var angle = snappedf((to_local(nav_agent.get_next_path_position())).angle(), deg_to_rad(90))
		var movement: Vector2 = Vector2(cos(angle), sin(angle))
	
		#and then finally move 
		if !test_move(transform, movement * 32):
			position += movement * 32
		#an easy fix
		elif (movement.x < -0.9 and movement.x > -1.1)  and (movement.y < 0.1 and movement.y > -0.1):
			var v_movement: Vector2 = Vector2(0, 1)
			if !test_move(transform, v_movement * 32):
				position += v_movement * 32
		elif (movement.x < 0.1 and movement.x > -0.1) and (movement.y > 0.9 and movement.y < 1.1):
			var v_movement: Vector2 = Vector2(1, 0)
			if !test_move(transform, v_movement * 32):
				position += v_movement * 32

func makepath() -> void: 
	nav_agent.target_position = get_parent().get_node("Player").global_position

func update_sprite() -> void:
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
