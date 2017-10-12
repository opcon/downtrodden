extends AudioStreamPlayer

var music_files = []
var recognized_extensions = Array(ResourceLoader.get_recognized_extensions_for_type("AudioStream"))
var current_index = -1
var target_volume
var current_volume
var volume_fading = false
var volume_fading_direction = 0
var volume_fading_amount = DEFAULT_VOL_FADE_SPEED

var master_volume = 1.0

var volume_state_machine

const DEFAULT_VOL_FADE_SPEED = 0.1

func _ready():
	initialize()
	
func initialize():
	set_master_volume(GameSettings.main_settings["volume"])
	randomize()
	build_song_list()
	setup_state_machine()
	
	target_volume = 0
	current_volume = 0
	change_volume(current_volume)
	
	fade_volume(0.25, 0.5)

	set_process_input(true)
	set_physics_process(true)

	current_index = randi() % music_files.size()
	play_next_song()

func build_song_list():
	# Build music files list
	var dir = Directory.new()
	if dir.open("res://music") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if (not dir.current_is_dir()):
				if(recognized_extensions.has(file_name.get_extension())):
					music_files.append("res://music" + "/" + file_name)
			file_name = dir.get_next()
	# Shuffle music files list
	var shuffled = []
	var indexList = range(music_files.size())
	for i in range(music_files.size()):
		var x = randi() % indexList.size()
		shuffled.append(music_files[x])
		indexList.remove(x)
		music_files.remove(x)
	music_files = shuffled

func setup_state_machine():
	var fsm_resource = preload("res://scripts/fsm.gd")
	volume_state_machine = fsm_resource.new()
	volume_state_machine.add_state("fading")
	volume_state_machine.add_state("default")
	volume_state_machine.add_link("fading", "default", "condition", [self, "done_fading", true])
	volume_state_machine.set_state("default")
	volume_state_machine.connect("state_changed", self, "on_volume_state_changed")
	
func done_fading():
	if (volume_fading_direction == 1):
		return (current_volume >= target_volume)
	elif (volume_fading_direction == -1):
		return (current_volume <= target_volume)
	else:
		return true

func fade_volume(desired_volume, fade_speed=0.1):
	if (desired_volume == target_volume): return
	
	if (desired_volume > current_volume): volume_fading_direction = 1
	else: volume_fading_direction = -1
	
	target_volume = desired_volume
	volume_fading_amount = fade_speed
	volume_state_machine.set_state("fading")

func play_next_song():
	current_index = (current_index + 1) % music_files.size()
	var new_song = load(music_files[current_index])
	set_stream(new_song)
	play()
	print("Started Playing ", music_files[current_index])

func on_volume_state_changed(state_from, state_to, args):
	if (state_to == "default"):
		volume_fading = false
		current_volume = target_volume
		change_volume(current_volume)
	elif (state_to == "fading"):
		volume_fading = true

func _physics_process(delta):
	volume_state_machine.process(delta)
	if (volume_fading):
		current_volume += volume_fading_direction * volume_fading_amount * delta
	change_volume(current_volume)

func _on_BackgroundMusic_finished():
	play_next_song()

func change_volume(new_volume):
	volume_db = linear2db(new_volume * master_volume)
	#set_volume(new_volume * master_volume)

func set_master_volume(new_volume):
	master_volume = new_volume * 0.01