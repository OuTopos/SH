extends Node

var player_name

var rounds = []
var games_completed = 0
var games_completed_no_undo = 0



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



func add_round():
	var r = {
		"started": 0,
		"completed": false,
		"duration": 0,
		"undo": 0,
		"shuffle": 0,
		"moves": 0
	}
	