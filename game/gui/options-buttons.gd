extends VBoxContainer

const PADDING = 50

const FULLSCREEN_OPTION = 0
const VOLUME_OPTION = 1
const MAP_KEYS_OPTION = 2

var button_list = []
var selected_button = 0
var buttons = {"fullscreen":"no", "volume":"20%", "map keys":""}
var button_order = ["fullscreen", "volume", "map keys"]

var main_settings = GameSettings.main_settings

var colour_index = null
export(Color) var default_colour = null

var main_font = preload("res://fonts/Rubik.tres")

func _ready():
	if (default_colour == null):
		default_colour = GameState.neutral_colour
	colour_index = randi() % GameState.base_colours.size()
	grab_focus()
	
	populate_option_list()
	redraw_options()
	
	#button_list = get_children()
	#for b in button_list:
	#	b.set("custom_colors/font_color", default_colour)
	
	button_selected(FULLSCREEN_OPTION)
	set_process_input(true)

func do_input():
	if (selected_button == FULLSCREEN_OPTION):
		if (buttons["fullscreen"] == "yes"):
			buttons["fullscreen"] = "no"
			OS.set_window_fullscreen(false)
			main_settings["fullscreen"] = false
		else:
			buttons["fullscreen"] = "yes"
			OS.set_window_fullscreen(true)
			main_settings["fullscreen"] = true
	if (selected_button == VOLUME_OPTION):
		var vol_string = buttons["volume"]
		var current_volume = int(vol_string.substr(0, vol_string.length() - 1))
		current_volume += 10
		if (current_volume > 100):
			current_volume = 0
			buttons["volume"] = "mute"
		else:
			buttons["volume"] = "%s" % current_volume + "%"
		main_settings["volume"] = current_volume
		BackgroundMusic.set_master_volume(current_volume)
	if (selected_button == MAP_KEYS_OPTION):
		get_tree().set_pause(true)
		var map_keys_scene = load("map-keyboard.tscn").instance()
		get_parent().add_child(map_keys_scene)
		
	redraw_options()


func _input(event):
	if event.is_pressed():
		if event.is_action("ui_accept") and Input.is_action_just_pressed("ui_accept"):
			get_tree().set_input_as_handled()
			do_input()
		if event.is_action("ui_down") and Input.is_action_just_pressed("ui_down"):
			next_button()
		if event.is_action("ui_up") and Input.is_action_just_pressed("ui_up"):
			prev_button()

func populate_option_list():
	if (main_settings["fullscreen"] == true):
		buttons["fullscreen"] = "yes"
	else:
		buttons["fullscreen"] = "no"
	if (main_settings["volume"] == 0):
		buttons["volume"] = "mute"
	else:
		buttons["volume"] = str(main_settings["volume"]) + "%"

func redraw_options():
	# clear all option buttons
	for child in get_children():
		child.free()
	for i in button_order:
		add_option(i, buttons[i])
	button_list = get_children()
	button_selected(selected_button)

func add_option(name, value):
	var b = Button.new()
	var s = StyleBoxEmpty.new()
	b.flat = true
	b.add_style_override("custom_styles/hover", s)
	b.add_style_override("custom_styles/pressed", s)
	b.add_style_override("custom_styles/focus", s)
	b.add_style_override("custom_styles/normal", s)
	b.add_color_override("font_color", default_colour)
	b.add_font_override("font", main_font)
	b.mouse_filter = MOUSE_FILTER_IGNORE
	b.text = "%-15s%5s" % [name, value]
	add_child(b)
	#add_button("%-15s%5s" % [name, value])

func update_position():
	var current_size = get_size()
	current_size.x += 50
	set_size(current_size)
	var current_pos = get_pos()
	set_pos(Vector2(-current_size.x * 0.5, current_pos.y))

func next_button():
	button_selected((selected_button + 1) % button_list.size())

func prev_button():
	button_selected((selected_button - 1) % button_list.size())

func button_selected(button_idx):
	button_list[selected_button].set("custom_colors/font_color", default_colour)
	selected_button = button_idx
	button_list[selected_button].set("custom_colors/font_color", GameState.base_colours[colour_index])
	colour_index = (colour_index + 1) % GameState.base_colours.size()
	if (selected_button == VOLUME_OPTION):
		BackgroundMusic.fade_volume(1.0, 1)
	else:
		BackgroundMusic.fade_volume(0.25, 1)

func save_settings():
	GameSettings.save_config()