extends VButtonArray

const NEXT_BUTTON = 0
const AGAIN_BUTTON = 1
const QUIT_BUTTON = 2

var selected_button = 0;
var pending_input = false;

func _ready():
	pass

func _process(delta):
	if (pending_input):
		pending_input = false
		do_input()

func do_input():
	if (selected_button == NEXT_BUTTON):
		GameState.goto_next_level()
	elif (selected_button == AGAIN_BUTTON):
		GameState.call_deferred("start_game", GameState.level_list[GameState.current_level_index])
	elif (selected_button == QUIT_BUTTON):
		GameState.goto_menu()
	

func _input_event(event):
	if (event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		pending_input = true
		get_tree().set_input_as_handled()
	if (event.is_action("ui_accept") and event.is_pressed()):
		get_tree().set_input_as_handled()
		do_input()

func _on_VButtonArray_button_selected( button_idx ):
	selected_button = button_idx


func _on_Timer_timeout():
	grab_focus()
	selected_button = get_selected()
	set_process(true)
	pending_input = false