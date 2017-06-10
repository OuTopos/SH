extends RigidBody

# 34 x 26 x 19

signal clicked(tile)

var value = null


# Member variables
var gray_mat = FixedMaterial.new()
var selected_mat = FixedMaterial.new()
var selected = false
var delay = 1
var hidden = true
var timer = 0

var blocked = false

var should_test = true


onready var tween_node = get_node("Tween")
onready var visual_node = get_node("Visual")

onready var global_tiles_node = get_node("/root/Tiles")

func _ready():
	set_process(true)
	set_fixed_process(true)
	
	
	selected_mat.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0.16, 0.56, 0.91, 1))
	
	var draw = get_node("ImmediateGeometry")
	for ray in global_tiles_node.rays["top"]:
		draw.begin(Mesh.PRIMITIVE_LINE_STRIP)
		draw.add_vertex(ray["from"])
		draw.add_vertex(ray["to"])
		draw.end()
	for ray in global_tiles_node.rays["left"]:
		draw.begin(Mesh.PRIMITIVE_LINE_STRIP)
		draw.add_vertex(ray["from"])
		draw.add_vertex(ray["to"])
		draw.end()
	for ray in global_tiles_node.rays["right"]:
		draw.begin(Mesh.PRIMITIVE_LINE_STRIP)
		draw.add_vertex(ray["from"])
		draw.add_vertex(ray["to"])
		draw.end()

func _process(delta):
	timer += delta
	if hidden and timer >= delay:
		place(0.4)
		hidden = false
func _fixed_process(delta):
	if should_test:
		set_blocked(raycast_blocked())
		should_test = false

func update_blocked():
	should_test = true

func _input_event(camera, event, pos, normal, shape):
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed):
		print("clicked")
		emit_signal("clicked", self)
		#if not selected and not blocked:
		#	selected = true
		#	print("selected")
		#elif not blocked:
		#	selected = false
		#	print("unselected")
		#else:
		#	get_node("Visual/TestCube").set_material_override(null)
		#	#queue_free()
		#	set_collision_mask(0)
		#	set_layer_mask(0)
		#	hide()
		#	get_tree().call_group(0, "Tiles", "test2")


func _mouse_enter():
	get_node("Visual").set_scale(Vector3(1.1, 1.1, 1.1))


func _mouse_exit():
	get_node("Visual").set_scale(Vector3(1, 1, 1))

func set_blocked(b):
	blocked = b
	if blocked:
		visual_node.get_node("MeshInstance").set_material_override(gray_mat)
	else:
		visual_node.get_node("MeshInstance").set_material_override(selected_mat)

func raycast_blocked_side(side):
	var space_state = get_world().get_direct_space_state()
	
	for ray in global_tiles_node.rays[side]:
		var result = space_state.intersect_ray( get_translation() + ray["from"], get_translation() + ray["to"], [self])
		if not result.empty():
			return true
	return false
	
func raycast_blocked():
	if raycast_blocked_side("top"):
		return true
	elif raycast_blocked_side("left") and raycast_blocked_side("right"):
		return true
	else:
		return false

func set_value(v):
	value = v
	var texture = get_node("/root/Tiles").textures[v]
	get_node("Visual/Sprite3D").set_texture(texture)

func place(time):
	tween_node.interpolate_property(visual_node, "transform/translation", Vector3(0, 25, -25), Vector3(0, 0.5, 0), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()
	tween_node.interpolate_property(visual_node, "transform/rotation", Vector3(0, 90, -25), Vector3(0, 0, 0), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()
	show()