extends Node2D

func _ready():
	set_process_input(false)

func _input(event):
	GameState.goto_menu()