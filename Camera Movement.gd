extends Spatial

export var vertical_lock = false
export var pan_on_mouse_move = true

onready var center = get_viewport().get_visible_rect().size / 2
onready var pivot = get_node("Pivot")

var rotation_deg = Vector3(0, 0, 0)
var rotation_deg_offset = Vector3(0, 0, 0)

var pressed = false


func _ready():
	rotation_deg = get_rotation_deg()
	set_process_input(true)
	
	get_tree().get_root().connect("size_changed", self, "on_resize")

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		if pressed and false:
			rotation_deg += Vector3(0.1 * event.relative_y, 0 , 0.1 * -event.relative_x)
			print(event.relative_pos)
		if pan_on_mouse_move:
			var offset = (event.pos - center) / center
			rotation_deg_offset = Vector3(25 * offset.y, 0, 25 * - offset.x)
		pivot.set_rotation_deg(rotation_deg + rotation_deg_offset)
	
	if event.type == InputEvent.MOUSE_BUTTON:
		pressed = event.pressed
		#print("poop")
		#print(event.button_index, )

func on_resize():
	print("RESIZE")
	center = get_viewport().get_visible_rect().size / 2