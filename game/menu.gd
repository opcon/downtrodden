extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	#var bm = get_node("BackgroundMusic")
	#remove_child(bm)
	#get_tree().get_root().call_deferred("add_child", bm)
	pass

func _input(event):
	if (event.is_action("exit") and event.is_pressed()):
		get_tree().quit()