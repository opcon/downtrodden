extends Node2D

onready var players = get_tree().get_nodes_in_group("player")
onready var pause_overlay = get_parent().get_parent().get_node("pause-overlay")

onready var overlay_top = get_node("overlay-top")
onready var overlay_bottom = get_node("overlay-bottom")
onready var overlay_left = get_node("overlay-left")
onready var overlay_right = get_node("overlay-right")

var style_overlay = StyleBoxFlat.new()

var game_finished = false
var paused = false

func _ready():
	set_process_input(true)
	Input.connect("joy_connection_changed", self, "_on_gamepad_connection_changed")
	
	var cnt = get_child_count()
	
	move_child(overlay_top, cnt)
	move_child(overlay_bottom, cnt)
	move_child(overlay_left, cnt)
	move_child(overlay_right, cnt)
	
	style_overlay.bg_color = Color(1, 1, 1)
	overlay_top.add_style_override("panel", style_overlay)
	overlay_bottom.add_style_override("panel", style_overlay)
	overlay_left.add_style_override("panel", style_overlay)
	overlay_right.add_style_override("panel", style_overlay)

func _input(event):
	if (event.is_pressed() and (event.device in GameState.current_device_indicies or event is InputEventKey)):
		if (event.is_action("pause") and not game_finished):
			get_tree().set_input_as_handled()
			var cls = event.get_class()
			if cls == "InputEventJoypadButton":
				pause_game("InputEventJoypad", event.device)
			else:
				pause_game(event.get_class(), event.device)

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
	darken_outer()

func pause_game(owner_type, owner_device):
	paused = true
	darken_outer()
	get_tree().set_pause(true)
	disable_player_input()
	pause_overlay.show()
	var sc = load("pause.tscn").instance()
	pause_overlay.add_child(sc)
	sc.get_node("pause-buttons").owner_type = owner_type
	sc.get_node("pause-buttons").owner_device = owner_device
	sc.get_node("pause-buttons").parent_game = self

func unpause_game():
	paused = false
	lighten_outer()
	get_tree().set_pause(false)
	enable_player_input()
	pause_overlay.hide()
	pause_overlay.remove_child(pause_overlay.get_children()[-1])

func _on_gamepad_connection_changed(index, connected):
	if (not paused and not connected and index in GameState.current_device_indicies): show_controller_disconnected_overlay(index)

func show_controller_disconnected_overlay(controller_index):
	paused = true
	darken_outer()
	get_tree().set_pause(true)
	disable_player_input()
	pause_overlay.show()
	var sc = load("controller-disconnected.tscn").instance()
	pause_overlay.add_child(sc)
	sc.owner_index = controller_index
	sc.parent_game = self
	sc.get_node("controller-message").set_text("Controller %s disconnected" % (controller_index + 1))

func hide_controller_disconnected_overlay():
	paused = false
	lighten_outer()
	pause_overlay.hide()
	pause_overlay.remove_child(pause_overlay.get_children()[-1])
	get_tree().set_pause(false)
	enable_player_input()

func darken_outer():
	style_overlay.bg_color = Color(0, 0, 0)
	overlay_top.add_style_override("panel", style_overlay)
	overlay_bottom.add_style_override("panel", style_overlay)
	overlay_left.add_style_override("panel", style_overlay)
	overlay_right.add_style_override("panel", style_overlay)
	
func lighten_outer():
	style_overlay.bg_color = Color(1, 1, 1)
	overlay_top.add_style_override("panel", style_overlay)
	overlay_bottom.add_style_override("panel", style_overlay)
	overlay_left.add_style_override("panel", style_overlay)
	overlay_right.add_style_override("panel", style_overlay)