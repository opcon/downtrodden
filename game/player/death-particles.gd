extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const MAX_LIFETIME = 2.1
var lifetime = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
	lifetime += delta
	if (lifetime >= MAX_LIFETIME):
		queue_free()
		#get_parent().remove_child(self)