extends VButtonArray

const PLAY_BUTTON = 0
const OPTIONS_BUTTON = 1
const QUIT_BUTTON = 2

var selected_button = 0;
var pending_input = false;

var colour_index = randi() % GameState.base_colours.size()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	grab_focus()
	selected_button = get_selected()
	set_selected(selected_button)
	_on_MainMenuButtons_button_selected(selected_button)
	set_process(true)

func _process(delta):
	if (pending_input):
		pending_input = false
		do_input()

func do_input():
	if (selected_button == PLAY_BUTTON):
		BackgroundMusic.fade_volume(0.4, 0.5)
		GameState.goto_scene("choose-mode.tscn")
	elif (selected_button == OPTIONS_BUTTON):
		GameState.goto_scene("options.tscn")
	elif (selected_button == QUIT_BUTTON):
		GameState.quit_game()
	

func _input_event(event):
	if (event.is_pressed()):
		if (event.is_action("ui_accept")):
			get_tree().set_input_as_handled()
			do_input()
		if (event.is_action("ui_cancel")):
			get_tree().set_input_as_handled()
			selected_button = QUIT_BUTTON
			set_selected(QUIT_BUTTON)
			do_input()

func _on_MainMenuButtons_button_selected( button_idx ):
	selected_button = button_idx
	set("custom_colors/font_color_selected", GameState.base_colours[colour_index])
	colour_index = (colour_index + 1) % GameState.base_colours.size()
