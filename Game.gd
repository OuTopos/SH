extends Spatial


func _ready():
	set_process(true)
	
	var shuffled_tiles = get_node("/root/Tiles").get_shuffled_tiles(1337)
	print(shuffled_tiles)
	var i = 0
	for child in get_node("Tiles").get_children():
		var value = shuffled_tiles[i]
		child.set_value(value)
		i += 1