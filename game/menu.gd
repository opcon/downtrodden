extends Control

func _ready():
	set_process_input(true)
	GameState.reset()

func _input(event):
	if (event.is_action("ui_cancel") and event.is_pressed()):
		get_tree().quit()