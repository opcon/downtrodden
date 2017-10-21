extends Control

#var keyboard_mappings = {"left":KEY_A, "right":KEY_D, "jump":KEY_W, "jetpack":KEY_SPACE}
var keyboard_mappings = GameSettings.keyboard_mapping
var current_mapping = -1
var mapping_indicies = keyboard_mappings.keys()

func _ready():
	set_process_input(true)
	advance_to_next()

func _input(event):
	if (event.is_pressed()):
		if (event is InputEventKey):
			var code = event.scancode
			keyboard_mappings[mapping_indicies[current_mapping]] = code
			advance_to_next()
		if event.is_action("ui_cancel") and Input.is_action_just_pressed("ui_cancel"):
			go_back_to_options()
		if event.is_action("ui_accept"):
			get_tree().set_input_as_handled()

func advance_to_next():
	current_mapping += 1
	if (current_mapping >= mapping_indicies.size()):
		go_back_to_options()
		return
	get_node("key-prompt").set_text("Press %s" % mapping_indicies[current_mapping])
	
func go_back_to_options():
	get_tree().set_input_as_handled()
	get_tree().call_deferred("set_pause", false)
	queue_free()