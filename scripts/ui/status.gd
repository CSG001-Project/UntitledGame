extends Control

var current_status = []

var mouse_over = false
var scroll_sound_enabled = false
var cursor = current_status.size()

func _ready() -> void:
	update_range()

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

func _on_value_changed(value: float) -> void:
	
	scroll_sound_enabled = true
	
	if -value > cursor-1:
		cursor += 1
	elif -value < cursor-5:
		cursor -= 1
	
	for i in range(5):
		var range_position = i+cursor-5

func add_status(text) -> void:
	
	if text is Array:
		var new_text = text.duplicate()
		new_text[0] = ">"+new_text[0]
		current_status.append_array(new_text)
	else:
		current_status.append(">"+text)
	
	cursor = current_status.size()
	update_range()

func update_range() -> void:
	scroll_sound_enabled = false
