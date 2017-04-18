extends Node

enum GameMode {
	None,
	OneVOne,
	TwoVTwo,
	FFA
}

var base_colours = [
	Color(0.625,1,0.991211), 
	Color(1,0,0.421875),
	Color(0.9375,0.539246,0.300293),
	Color(0.327805,0.847656,0.457767)
]

var currentScene = null
var currentGameMode = GameMode.None
var number_of_players = 0
var number_of_teams = 0
var maximum_score = 0

var player_input_methods = []
var level_list = []
var current_level_index = 0

var winning_team_index = 0

func _ready():
	var root = get_tree().get_root()
	currentScene = root.get_child(root.get_child_count() - 1)
	reset()

func reset():
	currentGameMode = GameMode.None
	number_of_players = 0
	number_of_teams = 0
	player_input_methods = []
	level_list = []
	current_level_index = 0
	winning_team_index = 0
	maximum_score = 0

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

func change_scene_to(scene):
	call_deferred("_goto_scene", scene)

func _deferred_goto_scene(path):
	var new_scene = load_scene(path)
	_goto_scene(new_scene)

func _goto_scene(scene):
	currentScene.free()
	currentScene = scene
	get_tree().get_root().add_child(currentScene)
	get_tree().set_current_scene(currentScene)

func load_scene(path):
	var s = ResourceLoader.load(path)
	return s.instance()

func update_game_mode():
	if (currentGameMode == GameMode.OneVOne):
		number_of_players = 2
		number_of_teams = 2
	elif (currentGameMode == GameMode.TwoVTwo):
		number_of_players = 4
		number_of_teams = 2
	elif (currentGameMode == GameMode.FFA):
		number_of_players = 4
		number_of_teams = 4

func start_game(level_name):
	# Load the required resources
	var level = ResourceLoader.load("res://world/" + level_name + ".tscn").instance()
	var player_resource = ResourceLoader.load("res://player/player.tscn")
	var game_scene = ResourceLoader.load("res://game.tscn").instance()
	
	var players_per_team = number_of_players / number_of_teams
	# Add the players to our scene and build their action lists
	for i in range(number_of_teams):
		for j in range(players_per_team):
			var player = player_resource.instance()
			player.index = i*players_per_team+j
			player.team = i
			player.base_colour = GameState.base_colours[i]
			player.set_name("Player" + str(i*players_per_team+j+1))
			player.add_to_group("players")
			print("Adding input for player " + str(i*players_per_team+j) + ", input method is " + str(player_input_methods[i*players_per_team+j]))
			build_action_list(player.index, player_input_methods[i*players_per_team+j])
			game_scene.add_child(player)
		#game_scene.get_node("score").get_node("player" + str(i+1)).show()
	
	game_scene.get_node("score").reset_score(maximum_score, number_of_teams)
	
	# Add the level to our scene
	game_scene.add_child(level)
	
	# Change the scene to the game scene
	GameState.change_scene_to(game_scene)
	
	# Fade in music
	BackgroundMusic.fade_volume(1, 0.5)

func build_action_list(player_id, input_method):
	var jump_event = InputEvent()
	var left_event = InputEvent()
	var right_event = InputEvent()
	var jetpack_event = InputEvent()
	if (input_method[0] == "Keyboard"):
		jump_event.type = InputEvent.KEY
		left_event.type = InputEvent.KEY
		right_event.type = InputEvent.KEY
		jetpack_event.type = InputEvent.KEY
		
		jump_event.device = input_method[1]
		left_event.device = input_method[1]
		right_event.device = input_method[1]
		jetpack_event.device = input_method[1]
		
		jump_event.scancode = KEY_W
		left_event.scancode = KEY_A
		right_event.scancode = KEY_D
		jetpack_event.scancode = KEY_SPACE
		
	elif (input_method[0] == "Gamepad"):
		jump_event.type = InputEvent.JOYSTICK_BUTTON
		left_event.type = InputEvent.JOYSTICK_MOTION
		right_event.type = InputEvent.JOYSTICK_MOTION
		jetpack_event.type = InputEvent.JOYSTICK_MOTION
		
		jump_event.device = input_method[1]
		left_event.device = input_method[1]
		right_event.device = input_method[1]
		jetpack_event.device = input_method[1]
		
		jump_event.button_index = JOY_XBOX_A
		left_event.axis = JOY_AXIS_0
		left_event.value = -0.5
		right_event.axis = JOY_AXIS_0
		right_event.value = 0.5
		jetpack_event.axis = JOY_AXIS_7
		jetpack_event.value = 0.5
	
	erase_and_add_action("jetpack" + str(player_id), jetpack_event)
	erase_and_add_action("move_left" + str(player_id), left_event)
	erase_and_add_action("move_right" + str(player_id), right_event)
	erase_and_add_action("move_up" + str(player_id), jump_event)
	
	build_gui_action_list(input_method)
	
func build_gui_action_list(input_method):
	var ui_up_event = InputEvent()
	var ui_down_event = InputEvent()
	var ui_accept_event = InputEvent()
	var ui_cancel_event = InputEvent()
	var pause_event = InputEvent()

	if (input_method[0] == "Keyboard"):
		ui_up_event.type = InputEvent.KEY
		ui_down_event.type = InputEvent.KEY
		ui_accept_event.type = InputEvent.KEY
		ui_cancel_event.type = InputEvent.KEY
		pause_event.type = InputEvent.KEY
		
		ui_up_event.device = input_method[1]
		ui_down_event.device = input_method[1]
		ui_accept_event.device = input_method[1]
		ui_cancel_event.device = input_method[1]
		pause_event.device = input_method[1]
		
		ui_up_event.scancode = KEY_W
		ui_down_event.scancode = KEY_S
		ui_accept_event.scancode = KEY_SPACE
		ui_cancel_event.scancode = KEY_ESCAPE
		pause_event.scancode = KEY_ESCAPE
		
	elif (input_method[0] == "Gamepad"):
		ui_up_event.type = InputEvent.JOYSTICK_BUTTON
		ui_down_event.type = InputEvent.JOYSTICK_BUTTON
		ui_accept_event.type = InputEvent.JOYSTICK_BUTTON
		ui_cancel_event.type = InputEvent.JOYSTICK_BUTTON
		pause_event.type = InputEvent.JOYSTICK_BUTTON
		
		ui_up_event.device = input_method[1]
		ui_down_event.device = input_method[1]
		ui_accept_event.device = input_method[1]
		ui_cancel_event.device = input_method[1]
		pause_event.device = input_method[1]
		
		ui_up_event.button_index = JOY_DPAD_UP
		ui_down_event.button_index = JOY_DPAD_DOWN
		ui_accept_event.button_index = JOY_XBOX_A
		ui_cancel_event.button_index = JOY_XBOX_B
		pause_event.button_index = JOY_START
	
	add_event_to_action("ui_up", ui_up_event)
	add_event_to_action("ui_down", ui_down_event)
	add_event_to_action("ui_accept", ui_accept_event)
	add_event_to_action("ui_cancel", ui_cancel_event)
	add_event_to_action("pause", pause_event)
	
func erase_and_add_action(action, event):
	InputMap.erase_action(action)
	InputMap.add_action(action)
	InputMap.action_add_event(action, event)

func add_event_to_action(action, event):
	if (InputMap.action_has_event(action, event)): return
	print("Adding event %s to action %s" % [event, action])
	InputMap.action_add_event(action, event)

func goto_menu():
		BackgroundMusic.fade_volume(0.25, 0.5)
		goto_scene("menu.tscn")
		get_tree().set_input_as_handled()

func goto_next_level():
	current_level_index = (current_level_index + 1) % level_list.size()
	call_deferred("start_game", level_list[current_level_index])

func ensure_ui_actions():
	for input in player_input_methods:
		build_gui_action_list(input)