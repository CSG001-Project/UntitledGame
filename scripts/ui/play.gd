extends Button

func _pressed():
	var new_scene = preload("res://scenes/main/main.tscn").instantiate()
	var tree = get_tree()
	var current_scene = tree.current_scene
	if current_scene:
		current_scene.queue_free()
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
