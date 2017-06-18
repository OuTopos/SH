extends Spatial

onready var tile_size  = get_node("/root/Tiles").tile_size

export (Texture) var cursor


var moves = Array()
var selected_tile = null
var counter_tile = 0
var counter_time = 0
var counter_click = 0
var counter_move = 0
var counter_undo = 0

var tile_scene = preload("res://Tile.tscn")
onready var layout_node = get_node("Layout")

func _ready():
	set_process(true)
	
	Input.set_custom_mouse_cursor(cursor)
	start()

func _process(delta):
	pass
			

func update_labels():
	var seconds = int(counter_time) % 60
	var minutes = int(counter_time) % 3600 / 60
	var time_formatted = "%02d:%02d" % [minutes, seconds]
	get_node("PanelContainer/VBoxContainer/HBoxContainer/Counter Tile").set_text("Tiles left: " + str(counter_tile))
	get_node("PanelContainer/VBoxContainer/HBoxContainer/Counter Time").set_text("Time: " + time_formatted)
	get_node("PanelContainer/VBoxContainer/HBoxContainer/Counter Click").set_text("Clicks: " + str(counter_click))
	get_node("PanelContainer/VBoxContainer/HBoxContainer/Counter Move").set_text("Moves: " + str(counter_move))
	get_node("PanelContainer/VBoxContainer/HBoxContainer/Counter Undo").set_text("Undos: " + str(counter_undo))

class sorter:
	func sort_layout(tile_a, tile_b):
		if tile_a.y < tile_b.y:
			return true
		elif tile_a.y > tile_b.y:
			return false
		else:
			if Vector2(tile_a.x, tile_a.z).length() < Vector2(tile_b.x, tile_b.z).length():
				return true
			elif Vector2(tile_a.x, tile_a.z).length() > Vector2(tile_b.x, tile_b.z).length():
				return false
			else:
				return false

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
	
	
	
	print(layout["tiles"][0])
	print(layout["tiles"][1])
	layout["tiles"].sort_custom(sorter, "sort_layout")
	print(layout["tiles"][0])
	print(layout["tiles"][1])
	
	var i = 0
	for tile in layout["tiles"]:
		
		var tile_node = tile_scene.instance()
		#tile_node.set_translation(Vector3(tile.x * tile_size.x, tile.y * tile_size.y, tile.z * tile_size.z))
		tile_node.connect("clicked", self, "_on_Tile_clicked")
		layout_node.add_child(tile_node)
		
		
		var delay = i * 0.01
		i += 1
		tile_node.place(Vector3(tile.x * tile_size.x, tile.y * tile_size.y, tile.z * tile_size.z), delay)
		
		
		#tile_node.hide()
		
	counter_tile = layout_node.get_child_count()

func select_tile(tile):
	tile.set_selected(true)
	selected_tile = tile

func deselect_tile():
	if selected_tile:
		selected_tile.set_selected(false)
		selected_tile = null
	

	
func _on_Tile_clicked(clicked_tile):
	counter_click += 1
	if selected_tile:
		# Already selected a tile.
		if clicked_tile.blocked:
			# Clicked on a blocked tile, deselect selected tile and play fail sound.
			deselect_tile()
			# FAIL BLEEP BLOOP
			
		elif clicked_tile.selected:
			# Clicked on already selected tile, deselect it.
			deselect_tile()
		
		elif clicked_tile.value == selected_tile.value:
			counter_move += 1
			var move = [selected_tile, clicked_tile]
			moves.append(move)
			counter_tile -= 2
			# Found a match, remove both.
			clicked_tile.deactivate()
			selected_tile.deactivate()
			selected_tile = null
			# Update blocked status
			get_tree().call_group(0, "Tiles", "update_blocked")
			
			update_labels()
		else:
			# Clicked on a free but not matching tile, deselct selected tile.
			deselect_tile()
			select_tile(clicked_tile)
			
		
	elif not clicked_tile.blocked:
		# Clicked on a free tile, select it.
		select_tile(clicked_tile)
		
	else:
		# Clicked on blocked tile, play fail sound.
		pass
	
func start():
	load_layout("turtle")
	
	var shuffled_tiles = get_node("/root/Tiles").get_shuffled_tiles()
	print(shuffled_tiles)
	var i = 0
	for child in get_node("Layout").get_children():
		var value = shuffled_tiles[i]
		child.set_value(value)
		i += 1


func _on_Undo_button_up():
	if moves.size() > 0:
		counter_undo += 1
		moves.back()[0].activate()
		moves.back()[1].activate()
		moves.remove(moves.size()-1)
		counter_tile += 2
		deselect_tile()
		get_tree().call_group(0, "Tiles", "update_blocked")
		update_labels()


func _on_Second_timeout():
	counter_time += 1
	update_labels()


func _on_Restart_button_up():
	get_tree().change_scene("res://Game.tscn")