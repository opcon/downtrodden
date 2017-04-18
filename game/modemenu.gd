extends Control

func _ready():
	set_process_input(true)

func _input(event):
	if (event.is_action("ui_cancel") and event.is_pressed()):
		GameState.goto_scene("menu.tscn")
		get_tree().set_input_as_handled()