extends Spatial

var tile_size  = Vector3(1.5, 1, 2)


var moves = Array()

var tile_scene = preload("res://Tile.tscn")
onready var layout_node = get_node("Layout")

func _ready():
	set_process(true)

func load_layout(layout_name):
	var file_path = "res://Layouts/" + layout_name + ".json"
	print("Loading " + file_path)
	var file = File.new()
	file.open(file_path, File.READ)
	var json = file.get_as_text()
	var layout = Dictionary()
	layout.parse_json(json)
	var tiles = layout["tiles"]
	file.close()
	
	layout["tiles"].sort()
	print(layout["tiles"][0])
	print(layout["tiles"][1])
	
	var i = 0
	for tile in layout["tiles"]:
		
		var tile_node = tile_scene.instance()
		tile_node.set_translation(Vector3(tile.x * tile_size.x, tile.y * tile_size.y, tile.z * tile_size.z))
		layout_node.add_child(tile_node)
		tile_node.hide()
		tile_node.delay = i * 0.03
		#tile_node.place(i * 0.05)
		i += 1
		
		
	var placed_tiles = layout_node.get_child_count()
	print(str(placed_tiles) + " tiles loaded.")

func _on_Start_button_up():
	load_layout("turtle")
	
	var shuffled_tiles = get_node("/root/Tiles").get_shuffled_tiles(1338)
	print(shuffled_tiles)
	var i = 0
	for child in get_node("Layout").get_children():
		var value = shuffled_tiles[i]
		child.set_value(value)
		i += 1
