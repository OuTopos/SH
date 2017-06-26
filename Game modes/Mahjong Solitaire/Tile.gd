extends RigidBody

# 34 x 26 x 19

signal clicked(tile)


var symbol = null
var active = false
var selected = false setget set_selected
var blocked = false

var should_raycast = true

# Member variables
var gray_mat = FixedMaterial.new()
var free_mat = FixedMaterial.new()
var selected_mat = FixedMaterial.new()

onready var tween_node = get_node("Tween")
onready var visual_node = get_node("Visual")

onready var global_tiles_node = get_node("/root/Tiles")

func _ready():
	set_fixed_process(true)
	
	free_mat.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0.4, 0.7, 0.4, 1))
	selected_mat.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0.16, 0.56, 0.91, 1))
	
#	var draw = get_node("ImmediateGeometry")
#	for ray in global_tiles_node.rays["top"]:
#		draw.begin(Mesh.PRIMITIVE_LINE_STRIP)
#		draw.add_vertex(ray["from"])
#		draw.add_vertex(ray["to"])
#		draw.end()
#	for ray in global_tiles_node.rays["left"]:
#		draw.begin(Mesh.PRIMITIVE_LINE_STRIP)
#		draw.add_vertex(ray["from"])
#		draw.add_vertex(ray["to"])
#		draw.end()
#	for ray in global_tiles_node.rays["right"]:
#		draw.begin(Mesh.PRIMITIVE_LINE_STRIP)
#		draw.add_vertex(ray["from"])
#		draw.add_vertex(ray["to"])
#		draw.end()

func _fixed_process(delta):
	if should_raycast:
		set_blocked(raycast_blocked())
		should_raycast = false


func _input_event(camera, event, pos, normal, shape):
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed):
		emit_signal("clicked", self)

func raycast():
	should_raycast = true

func set_selected(b):
	selected = b
	if selected:
		visual_node.get_node("MeshInstance").set_material_override(selected_mat)
	else:
		if blocked:
			visual_node.get_node("MeshInstance").set_material_override(gray_mat)
		else:
			visual_node.get_node("MeshInstance").set_material_override(free_mat)
	
func set_active(active):
	self.active = active

func set_blocked(blocked):
	self.blocked = blocked
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
	
func get_visual_translation(on_board = true):
	if on_board:
		var x = randf()*0.1-0.05
		var y = 0
		var z = randf()*0.1-0.05
		return Vector3(x, y, z)
	else:
		var xz = Vector2(get_translation().x, get_translation().z).normalized() * Vector2(30, 30)
		var x = xz.x
		var y = 20
		var z = xz.y
		return Vector3(x, y, z)

func get_visual_rotation(on_board = true):
	if on_board:
		var x = randf()*1-0.5
		var y = randf()*2-1
		var z = randf()*1-0.5
		return Vector3(x, y, z)
	else:
		var x = randf()*360*2-360
		var y = randf()*360*2-360
		var z = randf()*360*2-360
		return Vector3(x, y, z)

func get_visual_scale():
	var x = 0.96
	var y = 0.96
	var z = 0.96
	return Vector3(x, y, z)
	
func action_place(symbol, translation, delay):
	var time = 0.5
	# Setting the symbol
	self.symbol = symbol
	get_node("Visual/Symbol").set_frame(symbol)
	# Setting the rigid body position.
	set_translation(translation)
	# Preparing the visual node for animation.
	visual_node.set_translation(get_visual_translation(false))
	visual_node.set_rotation_deg(get_visual_rotation(false))
	visual_node.set_scale(get_visual_scale())
	
	show()
	# Animate
	tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), get_visual_translation(), time, Tween.TRANS_QUART, Tween.EASE_OUT, delay)
	tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation_deg(), get_visual_rotation(), time, Tween.TRANS_QUART, Tween.EASE_OUT, delay)
	
	tween_node.interpolate_callback(self, time + delay, "set_active", true)
	
	tween_node.start()

func action_undo():
	var time = 0.4
	# Instantly show and set mask
	show()
	set_layer_mask(1)
	# Animate
	tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), get_visual_translation(), time, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation(), get_visual_rotation(), time, Tween.TRANS_SINE, Tween.EASE_OUT)
	# Callback to activate
	tween_node.interpolate_callback(self, time, "set_active", true)
	# Start tween
	tween_node.start()

func action_match():
	var time = 0.4
	# Instantly deactivate and set mask
	active = false
	set_layer_mask(0)
	# Animate
	tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), get_visual_translation(false), time, Tween.TRANS_QUINT, Tween.EASE_IN)
	tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation_deg(), get_visual_rotation(false), time, Tween.TRANS_QUINT, Tween.EASE_IN)
	# Callback to hide
	tween_node.interpolate_callback(self, time, "hide")
	# Start tween
	tween_node.start()
	set_selected(false)

func _mouse_enter():
	if active:
		var time = 0.1
		tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), visual_node.get_translation() + Vector3(0, 1, 0), time, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation_deg(), get_visual_rotation(), time, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween_node.start()

func _mouse_exit():
	if active:
		var time = 0.2
		tween_node.interpolate_property(visual_node, "transform/translation", visual_node.get_translation(), get_visual_translation(), time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween_node.interpolate_property(visual_node, "transform/rotation", visual_node.get_rotation_deg(), get_visual_rotation(), time, Tween.TRANS_SINE, Tween.EASE_OUT)
		tween_node.start()