extends Node

var test = "poopiedoopie"


var tiles = []
var textures = []
	
	
	
var tile_size  = Vector3(2.6, 1.9, 3.4)
var snap_steps = 2
var split = tile_size / Vector3(snap_steps*2, snap_steps*2, snap_steps*2)

var rays = {"top": [], "left": [], "right": []}

func _ready():
	# Generate ray trace points
	# Top
	for z in range(-snap_steps / 2, snap_steps / 2):
		for x in range(-snap_steps / 2, snap_steps / 2):
			var ray_offset = Vector3(x * split.x * 2 + split.x, tile_size.y / 2, z * split.z * 2 + split.z)
			var ray = {
				"from": ray_offset,
				"to": ray_offset + Vector3(0, 100, 0)
			} 
			rays["top"].append(ray)
	# Left and Right
	for z in range(-snap_steps / 2, snap_steps / 2):
		var ray_offset = Vector3(0, tile_size.y / 2, z * split.z * 2 + split.z)
		var left_ray = {
			"from": ray_offset,
			"to": ray_offset + Vector3(-100, 0, 0)
		}
		var right_ray = {
			"from": ray_offset,
			"to": ray_offset + Vector3(100, 0, 0)
		} 
		rays["left"].append(left_ray)
		rays["right"].append(right_ray)
			
			
			
	for i in range(36):
		tiles.append(i)
		tiles.append(i)
		tiles.append(i)
		tiles.append(i)
		textures.append(load("res://Tiles/" + str(i) + ".png"))


func get_shuffled_tiles(new_seed = null):
	if new_seed:
		seed(new_seed)
	else:
		randomize()
	
	var shuffled_tiles = Array()
	for i in range(tiles.size()):
		var r = randi()%tiles.size()
		shuffled_tiles.append(tiles[r])
		tiles.remove(r)
	print(shuffled_tiles)
	return shuffled_tiles