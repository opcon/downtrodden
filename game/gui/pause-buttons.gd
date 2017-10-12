extends VBoxContainer

const RESUME_BUTTON = 0
const QUIT_BUTTON = 1

var buttons = []

var selected_button = 0;
var pending_input = false;

var colour_index = null

export(Color) var default_colour = null

var owner_type
var owner_device

var disconnected = false

var parent_game = null

func _ready():
	if (default_colour == null):
		default_colour = GameState.neutral_colour
	colour_index = randi() % GameState.base_colours.size()
	buttons = get_children()
	for b in buttons:
		b.set("custom_colors/font_color", default_colour)
	button_selected(RESUME_BUTTON)
	
	Input.connect("joy_connection_changed", self, "_on_gamepad_connection_changed")	
	call_deferred("set_process_input", true)
	call_deferred("set_process", true)
	call_deferred("grab_focus")

func _process(delta):
	if (pending_input):
		pending_input = false
		do_input()

func do_input():
	if (selected_button == RESUME_BUTTON):
		parent_game.unpause_game()
	elif (selected_button == QUIT_BUTTON):
		parent_game.unpause_game()
		GameState.goto_menu()

func _input(event):
	if (event.is_pressed() and (event.get_class() == owner_type and event.device == owner_device) or disconnected):
		if (event.is_action("ui_accept")):
			get_tree().set_input_as_handled()
			do_input()
		if (event.is_action("ui_cancel")):
			button_selected(RESUME_BUTTON)
			selected_button = RESUME_BUTTON
			pending_input = true
			get_tree().set_input_as_handled()
		if (event.is_action("ui_down")):
			next_button()
		if (event.is_action("ui_up")):
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

func _on_gamepad_connection_changed(index, connected):
	if (index == owner_device): disconnected = not connected