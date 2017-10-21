extends VBoxContainer

const PLAY_BUTTON = 0
const OPTIONS_BUTTON = 1
const QUIT_BUTTON = 2

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
	button_selected(PLAY_BUTTON)
	set_process_input(true)

func do_input():
	if (selected_button == PLAY_BUTTON):
		BackgroundMusic.fade_volume(0.4, 0.5)
		GameState.goto_scene("choose-mode.tscn")
	elif (selected_button == OPTIONS_BUTTON):
		GameState.goto_scene("options.tscn")
	elif (selected_button == QUIT_BUTTON):
		GameState.quit_game()


func _input(event):
	if (event.is_pressed()):
		if event.is_action("ui_accept") and Input.is_action_just_pressed("ui_accept"):
			get_tree().set_input_as_handled()
			do_input()
		if event.is_action("ui_cancel") and Input.is_action_just_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			selected_button = QUIT_BUTTON
			button_selected(QUIT_BUTTON)
			do_input()
		if event.is_action("ui_down") and Input.is_action_just_pressed("ui_down"):
			next_button()
		if event.is_action("ui_up") and Input.is_action_just_pressed("ui_up"):
			prev_button()

func next_button():
	button_selected((selected_button + 1) % buttons.size())

func prev_button():
	button_selected((selected_button - 1) % buttons.size())

func button_selected(button_idx):
	buttons[selected_button].set("custom_colors/font_color", default_colour)
	selected_button = button_idx
	buttons[selected_button].set("custom_colors/font_color", GameState.base_colours[colour_index])
	colour_index = (colour_index + 1) % GameState.base_colours.size()