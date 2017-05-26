extends Spatial

onready var center = get_viewport().get_visible_rect().size / 2
onready var pivot = get_node("Pivot")

func _ready():
	set_process(true)
	set_process_input(true)
	
	var shuffled_tiles = get_node("/root/Tiles").get_shuffled_tiles(1337)
	print(shuffled_tiles)
	var i = 0
	for child in get_node("Tiles").get_children():
		var value = shuffled_tiles[i]
		child.set_value(value)
		i += 1
	

func _process(delta):
	pass
	
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var offset = (event.pos - center) / center
		pivot.set_rotation_deg(Vector3(50 * offset.y, 0, 50 * - offset.x))