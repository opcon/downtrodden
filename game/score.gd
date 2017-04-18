extends Node2D

var player_scores = [0, 0, 0, 0]
var max_score = 0

signal max_score_reached(team_index)

func _ready():
	#reset_score()
	pass

func reset_score(maxmimum_score, score_count):
	max_score = maxmimum_score
	player_scores.resize(score_count)
	for i in range(player_scores.size()):
		player_scores[i] = 0
		get_node("player"+str(i+1)).set_text("0")
		get_node("player"+str(i+1)).show()

func add_to_score(player_index):
	player_scores[player_index] += 1
	get_node("player"+str(player_index+1)).set_text(str(player_scores[player_index]))
	if (player_scores[player_index] >= max_score):
		emit_signal("max_score_reached", player_index)