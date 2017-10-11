extends Control

var selected_index = 0
var level_list = []

onready var prev_node = get_node("prev-level")
onready var curr_node = get_node("current-level")
onready var next_node = get_node("next-level")

var colour_index = randi() % GameState.base_colours.size()

func _ready():
	set_process_input(true)
	build_level_list()
	selected_index = 0
	update_labels()
	
func build_level_list():
	# Build level list
	var dir = Directory.new()
	if dir.open("res://world") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if (not dir.current_is_dir()):
				if (file_name.get_extension() == "tscn" and file_name.find("level") >= 0):
					level_list.append(file_name.get_basename())
				elif (file_name.get_extension() == "scn" and file_name.find("level") >= 0):
					level_list.append(file_name.substr(0, file_name.find("tscn") - 1))
			file_name = dir.get_next()
	level_list.sort_custom(self, "compare_two_level_names")

func _input(event):
	if (event.is_pressed()):
		if (event.is_action("ui_accept")):
			get_tree().set_input_as_handled()
			var shuffled_levels = Utilities.shuffle_array(level_list)
			var shuffled_index = shuffled_levels.find(level_list[selected_index])
			GameState.level_list = shuffled_levels
			GameState.current_level_index = shuffled_index
			GameState.goto_scene("set-goal.tscn")
		elif (event.is_action("ui_up")):
			selected_index = (selected_index - 1) % level_list.size()
			update_labels()
		elif (event.is_action("ui_down")):
			selected_index = (selected_index + 1) % level_list.size()
			update_labels()
		elif (event.is_action("ui_cancel")):
			GameState.goto_scene("player-select.tscn")
			get_tree().set_input_as_handled()

func update_labels():
	prev_node.set_text(format_level_name(level_list[(selected_index - 1) % level_list.size()]))
	next_node.set_text(format_level_name(level_list[(selected_index + 1) % level_list.size()]))
	curr_node.set_text(format_level_name(level_list[selected_index]))
	
	curr_node.set("custom_colors/font_color", GameState.base_colours[colour_index])
	colour_index = (colour_index + 1) % GameState.base_colours.size()

func format_level_name(unformatted_name):
	var full_name = unformatted_name.right("level-".length())
	var split = full_name.split("-")
	var joined = split[0]
	for i in range(split.size() - 1):
		joined += " " + split[i+1]
	return joined	

func compare_two_level_names(level1, level2):
	var n1 = Utilities.word_to_number(format_level_name(level1))
	var n2 = Utilities.word_to_number(format_level_name(level2))
	return n1 < n2