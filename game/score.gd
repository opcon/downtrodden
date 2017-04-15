extends Node2D

var player_scores = [0, 0]

func _ready():
	reset_score()

func reset_score():
	for i in range(player_scores.size()):
		player_scores[i] = 0

func add_to_score(player_index):
	player_scores[player_index] += 1
	get_node("player"+str(player_index+1)).set_text(str(player_scores[player_index]))