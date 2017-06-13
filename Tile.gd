extends RigidBody

# 34 x 26 x 19

signal clicked(tile)

var value = null


# Member variables
var gray_mat = FixedMaterial.new()
var free_mat = FixedMaterial.new()
var selected_mat = FixedMaterial.new()

var delay = 1
var hidden = true
var timer = 0

var placed = false

var selected = false
var blocked = false

var should_test = true


onready var tween_node = get_node("Tween")
onready var visual_node = get_node("Visual")

onready var global_tiles_node = get_node("/root/Tiles")

var translation_offset = Vector3(0, 0, 0)
var rotation_offset = Vector3(0, 0, 0)
var scale_mod = Vector3(0.9, 0.9, 0.9)

func _ready():
	set_process(true)
	set_fixed_process(true)
	
	
	free_mat.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0.4, 0.7, 0.4, 1))
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
	if not placed and timer >= delay:
		visual_animate_place(0.4)
		placed = true
		
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
		print(get_visual_rotation())
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
	visual_animate_mouse_enter(0.1)


func _mouse_exit():
	visual_animate_mouse_exit(0.2)

func set_selected(b):
	selected = b
	if selected:
		visual_node.get_node("MeshInstance").set_material_override(selected_mat)
	else:
		if blocked:
			visual_node.get_node("MeshInstance").set_material_override(gray_mat)
		else:
			visual_node.get_node("MeshInstance").set_material_override(free_mat)
	

func set_blocked(b):
	blocked = b
	if blocked:
		visual_node.get_node("MeshInstance").set_material_override(gray_mat)
	else:
		visual_node.get_node("MeshInstance").set_material_override(free_mat)

func raycast_blocked_side(side):
	var space_state = get_world().get_direct_space_state()
	
	for ray in global_tiles_node.rays[side]:
		var result = space_state.intersect_ray( get_translation() + ray["from"], get_translation() + ray["to"], [self], 1)
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

	
func get_visual_translation():
	var x = randf()*0.1-0.05
	var y = 0
	var z = randf()*0.1-0.05
	return Vector3(x, y, z)

func get_visual_rotation():
	var x = randf()*0.5-0.25
	var y = randf()*2-1
	var z = randf()*0.5-0.25
	return Vector3(x, y, z)

func get_visual_scale():
	var x = 0.97
	var y = 0.97
	var z = 0.97
	return Vector3(x, y, z)
	
func place(pos):
	set_translation(pos)
	visual_node.set_translation(Vector3(0, 25, 0))
	
	
	#visual_node.set_translation(get_visual_translation())
	#visual_node.set_rotation_deg(get_visual_rotation())
	visual_node.set_scale(get_visual_scale())


	
func visual_animate_mouse_enter(time):
	tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), visual_node.get_translation() + Vector3(0, 1, 0), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()
	
	tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation(), Vector3(0, 0, 0), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()

func visual_animate_mouse_exit(time):
	tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), get_visual_translation(), time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween_node.start()
	
	tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation(), get_visual_rotation(), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()
	
func visual_animate_place(time):
	tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), get_visual_translation(), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()
	
	tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation(), get_visual_rotation(), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()
	
func visual_animate_remove(time):
	tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), get_visual_translation() + Vector3(0, 25, 0), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()
	
	tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation(), get_visual_rotation(), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween_node.start()

func enable():
	visual_animate_place(0.4)
	set_layer_mask(1)
	
func disable():
	visual_animate_remove(0.4)
	set_layer_mask(0)
	set_selected(false)