extends Node2D

onready var players = get_tree().get_nodes_in_group("player")
onready var pause_overlay = get_node("pause-overlay")

var game_finished = false

func _ready():
	print(players)
	set_process_input(true)

func _input(event):
	if (event.is_pressed()):
		if (event.is_action("pause") and not game_finished):
			get_tree().set_input_as_handled()
			pause_game()

func _on_score_max_score_reached(team_index):
	game_finished = true
	GameState.winning_team_index = team_index
	disable_player_input()
	pause_overlay.show()
	show_endgame_scene()
	
func disable_player_input():
	for p in players:
		p.input_enabled = false

func enable_player_input():
	for p in players:
		p.input_enabled = true

func show_endgame_scene():
	var sc = load("end-game.tscn").instance()
	pause_overlay.add_child(sc)

func pause_game():
	get_tree().set_pause(true)
	disable_player_input()
	pause_overlay.show()
	var sc = load("pause.tscn").instance()
	pause_overlay.add_child(sc)

func unpause_game():
	get_tree().set_pause(false)
	enable_player_input()
	pause_overlay.hide()
	pause_overlay.remove_child(pause_overlay.get_children()[-1])