extends Node2D

onready var players = get_tree().get_nodes_in_group("player")
onready var pause_overlay = get_node("pause-overlay")

var game_finished = false

func _ready():
	set_process_input(true)
	Input.connect("joy_connection_changed", self, "_on_gamepad_connection_changed")

func _input(event):
	if (event.is_pressed() and (event.device in GameState.current_device_indicies or event.type == InputEvent.KEY)):
		if (event.is_action("pause") and not game_finished):
			print(event.device)
			get_tree().set_input_as_handled()
			pause_game(event.type, event.device)

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

func pause_game(owner_type, owner_device):
	get_tree().set_pause(true)
	disable_player_input()
	pause_overlay.show()
	var sc = load("pause.tscn").instance()
	pause_overlay.add_child(sc)
	sc.get_node("pause-buttons").owner_type = owner_type
	sc.get_node("pause-buttons").owner_device = owner_device

func unpause_game():
	get_tree().set_pause(false)
	enable_player_input()
	pause_overlay.hide()
	pause_overlay.remove_child(pause_overlay.get_children()[-1])

func _on_gamepad_connection_changed(index, connected):
	if (not connected and index in GameState.current_device_indicies): show_controller_disconnected_overlay(index)

func show_controller_disconnected_overlay(controller_index):
	get_tree().set_pause(true)
	disable_player_input()
	pause_overlay.show()
	var sc = load("controller-disconnected.tscn").instance()
	pause_overlay.add_child(sc)
	sc.owner_index = controller_index
	sc.get_node("controller-message").set_text("Controller %s disconnected" % (controller_index + 1))

func hide_controller_disconnected_overlay():
	pause_overlay.hide()
	pause_overlay.remove_child(pause_overlay.get_children()[-1])
	get_tree().set_pause(false)
	enable_player_input()