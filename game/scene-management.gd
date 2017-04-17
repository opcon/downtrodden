extends Node2D

func _ready():
	set_process_input(true)

func _input(event):
	if (event.is_action("exit") and event.is_pressed()):
		BackgroundMusic.fade_volume(0.25, 0.5)
		GameState.goto_scene("menu.tscn")
		get_tree().set_input_as_handled()