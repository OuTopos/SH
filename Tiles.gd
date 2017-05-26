extends Node

var test = "poopiedoopie"


var tiles = []
var textures = []

func _ready():
	for i in range(36):
		tiles.append(i)
		tiles.append(i)
		tiles.append(i)
		tiles.append(i)
		textures.append(load("res://Tiles/" + str(i) + ".png"))
	print(tiles)


func get_shuffled_tiles(new_seed):
	seed(new_seed)
	
	var shuffled_tiles = Array()
	for i in range(tiles.size()):
		var r = randi()%tiles.size()
		shuffled_tiles.append(tiles[r])
		tiles.remove(r)
	print(shuffled_tiles)
	return shuffled_tiles