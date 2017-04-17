extends VButtonArray

const ONE_V_ONE = 0
const TWO_V_TWO = 1
const FREE_FOR_ALL = 2

var selected_button = 0;
var pending_input = false;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	grab_focus()
	selected_button = get_selected()
	set_process(true)

func _process(delta):
	if (pending_input):
		pending_input = false
		do_input()

func do_input():
	if (selected_button == ONE_V_ONE):
		GameState.currentGameMode = GameState.GameMode.OneVOne
	elif (selected_button == TWO_V_TWO):
		GameState.currentGameMode = GameState.GameMode.TwoVTwo
	elif (selected_button == FREE_FOR_ALL):
		GameState.currentGameMode = GameState.GameMode.FFA
	GameState.update_game_mode()
	BackgroundMusic.fade_volume(0.75, 0.5)
	GameState.goto_scene("player-select.tscn")
	

func _input_event(event):
	if (event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		pending_input = true
		get_tree().set_input_as_handled()
	if (event.is_action("ui_accept") and event.is_pressed()):
		get_tree().set_input_as_handled()
		do_input()

func _on_MainMenuButtons_button_selected( button_idx ):
	selected_button = button_idx
