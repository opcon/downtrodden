extends Control

var level = "level1"

func _ready():
	GameState.call_deferred("start_game", level)