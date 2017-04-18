extends Control

var selected_index = 0
var level_list = []

onready var prev_node = get_node("prev-level")
onready var curr_node = get_node("current-level")
onready var next_node = get_node("next-level")

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
			if (not dir.current_is_dir() and file_name.extension() == "tscn" and file_name.find("level") >= 0):
				level_list.append(file_name.basename())
			file_name = dir.get_next()

func _input(event):
	if (event.is_pressed()):
		if (event.is_action("ui_accept")):
			get_tree().set_input_as_handled()
			var shuffled_levels = Utilities.shuffle_array(level_list)
			print(shuffled_levels)
			var shuffled_index = shuffled_levels.find(level_list[selected_index])
			GameState.level_list = shuffled_levels
			GameState.current_level_index = shuffled_index
			GameState.maximum_score = 2
			GameState.call_deferred("start_game", level_list[selected_index])
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
	
	print(curr_node.get_rect())

func format_level_name(unformatted_name):
	var full_name = unformatted_name.right("level-".length())
	var split = full_name.split("-")
	var joined = split[0]
	for i in range(split.size() - 1):
		joined += " " + split[i+1]
	return joined