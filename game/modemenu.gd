extends Control

func _ready():
	set_process_input(true)

func _input(event):
	if (event.is_action("exit") and event.is_pressed()):
		get_tree().call_deferred("change_scene", "menu.tscn")
		get_tree().set_input_as_handled()