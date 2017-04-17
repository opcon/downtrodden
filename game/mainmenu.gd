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
		BackgroundMusic.fade_volume(1, 0.5)
		get_tree().change_scene("choose-mode.tscn")
	elif (selected_button == QUIT_BUTTON):
		get_tree().quit()
	

func _input_event(event):
	if (event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		pending_input = true
		get_tree().set_input_as_handled()
	if (event.is_action("ui_accept") and event.is_pressed()):
		get_tree().set_input_as_handled()
		do_input()

func _on_MainMenuButtons_button_selected( button_idx ):
	selected_button = button_idx
