extends VButtonArray

const PLAY_BUTTON = 0
const OPTIONS_BUTTON = 1
const QUIT_BUTTON = 2

var selected_button = 0;
var pending_input = false;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	grab_focus()
	selected_button = get_selected()
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
