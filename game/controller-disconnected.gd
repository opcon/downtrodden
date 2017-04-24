extends Control

var owner_index

func _ready():
	Input.connect("joy_connection_changed", self, "_on_gamepad_connection_changed")

func _on_gamepad_connection_changed(index, connected):
	if (connected and index == owner_index):
		print("Controller reconnected")
		get_parent().get_parent().hide_controller_disconnected_overlay()