extends Node

var main_settings = {"fullscreen":false, "volume":100} # In form <setting name>:<default value>
var keyboard_mapping = {"left":KEY_A, "right":KEY_D, "jump":KEY_W, "jetpack":KEY_SPACE}

const CONFIG_FILE = "user://settings.cfg"
const MAIN_SECTION = "main"
const MAPPING_SECTION = "mapping"

func _ready():
	load_config()

func load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err == OK:
		# Load the main settings
		var fullscreen = config.get_value(MAIN_SECTION, "fullscreen", main_settings["fullscreen"])
		var volume = config.get_value(MAIN_SECTION, "volume", main_settings["volume"])
		main_settings.fullscreen = fullscreen
		main_settings.volume = volume
		
		# Load the keyboard mappings
		var left = config.get_value(MAPPING_SECTION, "left", keyboard_mapping["left"])
		var right = config.get_value(MAPPING_SECTION, "right", keyboard_mapping["right"])
		var jump = config.get_value(MAPPING_SECTION, "jump", keyboard_mapping["jump"])
		var jetpack = config.get_value(MAPPING_SECTION, "jetpack", keyboard_mapping["jetpack"])
		keyboard_mapping.left = left
		keyboard_mapping.right = right
		keyboard_mapping.jump = jump
		keyboard_mapping.jetpack = jetpack

func save_config():
	var config = ConfigFile.new()
	var err =  config.load(CONFIG_FILE) # We continue even if there's no saved config file
	# Save the main settings
	for k in main_settings:
		config.set_value(MAIN_SECTION, k, main_settings[k])
	# Save the keyboard mappings
	for k in keyboard_mapping:
		config.set_value(MAPPING_SECTION, k, keyboard_mapping[k])
	# Save the changes
	config.save(CONFIG_FILE)