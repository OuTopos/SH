extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process_input(true)
	
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var offset = (event.pos - center) / center
		set_rotation_deg(Vector3(50 * offset.y, 0, 50 * - offset.x))
		
