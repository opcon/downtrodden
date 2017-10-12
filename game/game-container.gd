extends Control

onready var game = get_node("game-camera/game")
onready var game_camera = get_node("game-camera")
onready var pause_overlay = get_node("pause-overlay")

var current_scale = 1

const GAME_WIDTH = 1920
const GAME_HEIGHT = 1080

func _ready():
	connect("resized", self, "_on_Control_resized")
	_on_Control_resized()

func _on_Control_resized():
	current_scale = max(GAME_WIDTH / rect_size.x, GAME_HEIGHT / rect_size.y)
	game_camera.zoom = Vector2(current_scale, current_scale)
	#game_camera.position = rect_size*0.5 + Vector2(100, 50)
	game_camera.align()

func _on_pauseoverlay_visibility_changed():
	pause_overlay.rect_size = Vector2(GAME_WIDTH, GAME_HEIGHT)