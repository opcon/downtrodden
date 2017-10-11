extends Control

const TEXT_WIDTH = 54
const CONTROLLER_LABEL_WIDTH = 476
const Y_VALUE = -200

var player_numbers

var select_state_machine
var current_team_number = 0
var players_per_team = 1
var current_player_number = 0

var player_input_methods = []

var default_label_colour = Color(0.690196,0.690196,0.690196)

func _ready():
	set_process_input(true)
	GameState.update_game_mode()
	var children = get_node("players").get_children()
	for i in range(children.size()):
		children[i].hide()
	
	var interval = 1920 / GameState.number_of_teams
	
	for i in range(GameState.number_of_teams):
		var controllerlabel = children[i].get_node("controllerlabel" + str(i+1))
		children[i].rect_position = Vector2(-960 + (interval * i) + (interval) * 0.5, Y_VALUE)
		children[i].show()
		controllerlabel.hide()
		controllerlabel.rect_position = Vector2(-CONTROLLER_LABEL_WIDTH * 0.5, -Y_VALUE * 2)
	player_numbers = children
	
	players_per_team = GameState.number_of_players / GameState.number_of_teams

func _input(event):
	if (event.is_pressed()):
		if (event is InputEventKey):
			if (event.scancode == KEY_SPACE):
				set_player_input("Keyboard", event.device)
			elif (event.scancode == KEY_ESCAPE):
				remove_player_input("Keyboard", event.device)
		elif (event is InputEventJoypadButton):
			if (event.button_index == JOY_BUTTON_0):
				set_player_input("Gamepad", event.device)
			elif (event.button_index == JOY_BUTTON_1):
				remove_player_input("Gamepad", event.device)
		
func remove_player_input(type, device):
	var args = [type, device]
	
	# Check that we have an entry to compare against. If not, quit to previous scene
	if (player_input_methods.size() <= 0):
		GameState.goto_scene("choose-mode.tscn")
		get_tree().set_input_as_handled()
		return
	
	# Check that this matches the previously selected player
	if (player_input_methods[-1] == args):
		player_input_methods.remove(player_input_methods.size() - 1)
		current_player_number -= 1
		if (current_player_number < 0):
			current_player_number = players_per_team - 1
			current_team_number -= 1
		if (current_player_number == 0):	
			player_numbers[current_team_number].set("custom_colors/font_color", default_label_colour)
			player_numbers[current_team_number].get_node("controllerlabel" + str(current_team_number+1)).hide()
		else:
			var controllerlabel = player_numbers[current_team_number].get_node("controllerlabel" + str(current_team_number+1))
			var current_text = controllerlabel.get_text()
			var last_linebreak = current_text.rfind("\n")
			controllerlabel.set_text(current_text.substr(0, last_linebreak))
	
	get_tree().set_input_as_handled()

func set_player_input(type, device):
	var args = [type, device]
	
	# Check that we are still looking for players, otherwise go to level select
	if (current_team_number >= GameState.number_of_teams):
		goto_level_select()

	# Start game anyway if we are free for all and a player already joined has pressed continue
	if (GameState.currentGameMode == GameState.GameMode.FFA and args in player_input_methods):
		goto_level_select()
	
	# Calculate current player index
	var player_index = current_team_number + current_player_number
	
	# Don't let the same input method have multiple players
	if (args in player_input_methods): return
	
	# Add the input method to the array
	player_input_methods.append(args)
	
	# Update player number colour
	player_numbers[current_team_number].set("custom_colors/font_color", GameState.base_colours[current_team_number])
	
	# Update the player controller label
	var controllerlabel = player_numbers[current_team_number].get_node("controllerlabel" + str(current_team_number + 1))
	controllerlabel.set("custom_colors/font_color", GameState.base_colours[current_team_number])
	var current_text = ""
	if (current_player_number >= 1):
		current_text = controllerlabel.get_text() + "\n"
	if (args[0] == "Keyboard"):
		controllerlabel.set_text(current_text + "Keyboard")
	elif (args[0] == "Gamepad"):
		controllerlabel.set_text(current_text + "Controller " + str(args[1] + 1))
	controllerlabel.show()
	
	# Update current player number
	current_player_number += 1
	if (current_player_number >= players_per_team):
		current_player_number = 0
		current_team_number += 1
	
	get_tree().set_input_as_handled()

func goto_level_select():
	GameState.player_input_methods = player_input_methods
	
	GameState.ensure_ui_actions()
	
	# Update number of players if in FFA
	if (GameState.currentGameMode == GameState.GameMode.FFA):
		GameState.number_of_players = player_input_methods.size()
		GameState.number_of_teams = GameState.number_of_players
	GameState.goto_scene("level-select.tscn")