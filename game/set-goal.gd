extends Control

var goal = GameState.maximum_score
onready var goal_node = get_node("goal")

var colour_index = randi() % GameState.base_colours.size()

func _ready():
	set_process_input(true)
	update_label()
	pass

func _input(event):
	if (event.is_pressed()):
		if (event.is_action("ui_accept")):
			get_tree().set_input_as_handled()
			GameState.maximum_score = goal
			GameState.call_deferred("start_game", GameState.level_list[GameState.current_level_index])
		elif (event.is_action("ui_up")):
			goal += 2
			update_label()
		elif (event.is_action("ui_down")):
			goal -= 2
			if (goal <= 0):
				goal = 1
			update_label()
		elif (event.is_action("ui_cancel")):
			GameState.maximum_score = goal
			GameState.goto_scene("level-select.tscn")
			get_tree().set_input_as_handled()

func update_label():
	goal_node.set_text(str(goal))
	goal_node.set("custom_colors/font_color", GameState.base_colours[colour_index])
	colour_index = (colour_index + 1) % GameState.base_colours.size()