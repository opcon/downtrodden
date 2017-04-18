extends Node

func _ready():
	randomize()

func shuffle_array(unshuffled_reference):
	# Shuffles a list
	var unshuffled = [] + unshuffled_reference
	var shuffled = []
	var indexList = range(unshuffled.size())
	for i in range(unshuffled.size()):
		var x = randi() % indexList.size()
		shuffled.append(unshuffled[x])
		indexList.remove(x)
		unshuffled.remove(x)
	return shuffled