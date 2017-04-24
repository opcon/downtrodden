extends VButtonArray

const RESUME_BUTTON = 0
const QUIT_BUTTON = 1

var selected_button = 0;
var pending_input = false;

var owner_type
var owner_device

var disconnected = false

func _ready():
	selected_button = get_selected()
	call_deferred("set_process", true)
	call_deferred("grab_focus")
	Input.connect("joy_connection_changed", self, "_on_gamepad_connection_changed")

func _process(delta):
	if (pending_input):
		pending_input = false
		do_input()

func do_input():
	if (selected_button == RESUME_BUTTON):
		get_parent().get_parent().get_parent().unpause_game()
	elif (selected_button == QUIT_BUTTON):
		get_parent().get_parent().get_parent().unpause_game()
		GameState.goto_menu()

func _input_event(event):
	if (event.is_pressed() and (event.type == owner_type && event.device == owner_device) or disconnected):
		if (event.is_action("ui_accept")):
			get_tree().set_input_as_handled()
			do_input()
		if (event.is_action("ui_cancel")):
			set_selected(RESUME_BUTTON)
			selected_button = RESUME_BUTTON
			pending_input = true
			get_tree().set_input_as_handled()

func _on_VButtonArray_button_selected( button_idx ):
	selected_button = button_idx

func _on_gamepad_connection_changed(index, connected):
	if (index == owner_device): disconnected = not connected