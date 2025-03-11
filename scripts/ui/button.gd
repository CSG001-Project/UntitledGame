extends Button

@export var menu: Control;
@export var button: Button;

func _ready() -> void:
	button.pressed.connect(on_button_pressed);


func on_button_pressed() -> void:
	if (menu.visible == false):
		menu.show();
	else:
		menu.hide();
	
