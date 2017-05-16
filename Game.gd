extends Spatial

onready var center = get_viewport().get_visible_rect().size / 2
onready var pivot = get_node("Pivot")

func _ready():
	set_process(true)
	set_process_input(true)
	
	var tiles = []
	for i in range(36):
		tiles.append(i)
		tiles.append(i)
		tiles.append(i)
		tiles.append(i)
	print(tiles)
	

func _process(delta):
	pass
	
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var offset = (event.pos - center) / center
		pivot.set_rotation_deg(Vector3(20 * offset.y, 0, 20 * - offset.x))
		

