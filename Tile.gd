extends RigidBody


# Member variables
var gray_mat = FixedMaterial.new()
var selected = false
var is_blocked = true

var should_test = true
func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if should_test:
		test()

func _input_event(camera, event, pos, normal, shape):
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed):
		if (not selected):
			get_node("TestCube").set_material_override(gray_mat)
			test()
		else:
			get_node("TestCube").set_material_override(null)
			queue_free()
			get_tree().call_group(0, "Tiles", "test2")
		
		selected = not selected


func _mouse_enter():
	get_node("TestCube").set_scale(Vector3(1.1, 1.1, 1.1))


func _mouse_exit():
	get_node("TestCube").set_scale(Vector3(1, 1, 1))

func set_blocked(blocked):
	is_blocked = blocked
	if is_blocked:
		get_node("TestCube").set_material_override(gray_mat)
	else:
		get_node("TestCube").set_material_override(null)
		

func test2():
	should_test = true
	
func test():
	var space_state = get_world().get_direct_space_state()

	var result_left = space_state.intersect_ray( get_translation(), get_translation() + Vector3(-100, 0, 0) , [self])
	var result_right = space_state.intersect_ray( get_translation(), get_translation() + Vector3(100, 0, 0) , [self])
	
	if result_left.empty() or result_right.empty():
		# Free!
		set_blocked(false)
	else:
		set_blocked(true)