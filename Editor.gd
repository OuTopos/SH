extends Spatial

var editor_tile = preload("res://Editor/Editor Tile.tscn")

onready var ghost = get_node("Ghost")
onready var layout = get_node("Layout")

var snap = Vector3(0.75, 0.5, 1)
var pressed = false

var placed_tiles = 0

func _ready():
	set_fixed_process(true)
	
	#var cols = ghost.get_overlapping_bodies().size()
	#print(cols)
	#for poop in ghost.get_overlapping_bodies():
		#print(poop)

func _fixed_process(delta):
	var cols = ghost.get_overlapping_bodies().size()
	if cols > 1:
		pass
	

func move_ghost(pos):
	var old_pos = ghost.get_translation()
	pos.x = round(pos.x / snap.x) * snap.x
	pos.y = round(pos.y / snap.y) * snap.y + snap.y
	pos.z = round(pos.z / snap.z) * snap.z
	ghost.set_translation(pos)
	
	var cols = ghost.get_overlapping_bodies().size()
	print(cols)
	for poop in ghost.get_overlapping_bodies():
		print(poop)
	#if cols > 1:
		#ghost.set_translation(old_pos)

func place_tile(pos):
	var editor_tile_node = editor_tile.instance()
	editor_tile_node.set_translation(pos)
	editor_tile_node.connect("input_event", self, "_on_input_event")
	#editor_tile_node.connect("body_enter")
	layout.add_child(editor_tile_node)
	
	placed_tiles = layout.get_child_count()
	#print("TILES: ", placed_tiles)

func _on_input_event( camera, event, pos, normal, shape_idx ):
	if normal == Vector3(0, 1, 0):
		if event.type == 2 and pressed:
			move_ghost(pos)
		if event.type == 3 and event.is_pressed():
			pressed = true
			ghost.set_hidden(false)
			move_ghost(pos)
		if event.type == 3 and not event.is_pressed():
			pressed = false
			ghost.set_hidden(true)
			
			place_tile(ghost.get_translation())

	
func _on_Load_button_up():
	print("LOADING")
	for child in layout.get_children():
		child.queue_free()
		
		
	var filename = get_node("Control/Filename").get_text()
	var file = File.new()
	file.open("user://" + filename + ".json", File.READ)
	var json = file.get_as_text()
	var dict = Dictionary()
	dict.parse_json(json)
	var tiles = dict["tiles"]
	file.close()
	
	for tile in tiles:
		for tile2 in tiles:
			var i = 0
			if Vector3(tile.x, tile.y, tile.z) == Vector3(tile2.x, tile2.y, tile2.z):
				i += 1
			if i > 1:
				print("poop")
		place_tile(Vector3(tile.x, tile.y, tile.z))
	
	print(str(tiles.size()) + " tiles loaded.")

	
	


func _on_Save_button_up():
	print("SAVING")
	var tiles = Array()
	for child in layout.get_children():
		var tile = {"x": child.get_translation().x, "y": child.get_translation().y, "z": child.get_translation().z}
		tiles.append(tile)
	var json = {"tiles": tiles}.to_json()
	print(json)
	var test = Dictionary()
	test.parse_json(json)
	
	var filename = get_node("Control/Filename").get_text()
	var file = File.new()
	file.open("user://" + filename + ".json", File.WRITE)
	file.store_line(json)
	file.close()
