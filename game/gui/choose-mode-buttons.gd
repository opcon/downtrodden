extends VBoxContainer

const ONE_V_ONE = 0
const TWO_V_TWO = 1
const FREE_FOR_ALL = 2


var buttons = []

var selected_button = 0;

var colour_index = null

export(Color) var default_colour = null

func _ready():
	if (default_colour == null):
		default_colour = GameState.neutral_colour
	colour_index = randi() % GameState.base_colours.size()
	grab_focus()
	buttons = get_children()
	for b in buttons:
		b.set("custom_colors/font_color", default_colour)
	button_selected(ONE_V_ONE)
	set_process_input(true)

func do_input():
	if (selected_button == ONE_V_ONE):
		GameState.currentGameMode = GameState.GameMode.OneVOne
	elif (selected_button == TWO_V_TWO):
		GameState.currentGameMode = GameState.GameMode.TwoVTwo
	elif (selected_button == FREE_FOR_ALL):
		GameState.currentGameMode = GameState.GameMode.FFA
	GameState.update_game_mode()
	BackgroundMusic.fade_volume(0.5, 0.5)
	GameState.goto_scene("player-select.tscn")


func _input(event):
	if (event.is_pressed()):
		if event.is_action("ui_accept") and Input.is_action_just_pressed("ui_accept"):
			get_tree().set_input_as_handled()
			do_input()
		if event.is_action("ui_down") and Input.is_action_just_pressed("ui_down"):
			next_button()
		if event.is_action("ui_up") and Input.is_action_just_pressed("ui_up"):
			prev_button()
		if event.is_action("ui_cancel") and Input.is_action_just_pressed("ui_cancel"):
			GameState.goto_scene("menu.tscn")
			get_tree().set_input_as_handled()

func next_button():
	button_selected((selected_button + 1) % buttons.size())

func prev_button():
	button_selected((selected_button - 1) % buttons.size())

func button_selected(button_idx):
	buttons[selected_button].set("custom_colors/font_color", default_colour)
	selected_button = button_idx
	buttons[selected_button].set("custom_colors/font_color", GameState.base_colours[colour_index])
	colour_index = (colour_index + 1) % GameState.base_colours.size()