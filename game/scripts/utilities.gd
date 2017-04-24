extends Node

var units = ["zero", "one", "two", "three", "four", "five", "six", 
	"seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", 
	"fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen",]

var tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]

var num_words = {"and":[1, 0]}

func _ready():
	for i in range(units.size()): num_words[units[i]] = [1, i]
	for i in range(tens.size()): num_words[tens[i]] = [1, i*10]
	randomize()

static func shuffle_array(unshuffled_reference):
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

func word_to_number(numberword):
	var current = 0
	var result = 0
	var scale = 0
	var increment = 0
	var a
	
	for word in numberword.split(" "):
		a = num_words[word]
		scale = a[0]
		increment = a[1]
		current = current * scale + increment
		if scale > 100:
			result += current
			current = 0
	return result + current