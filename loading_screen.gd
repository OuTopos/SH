extends CanvasLayer

var queue
var current_scene
var resource_path

func _ready():
	get_node("Control/ProgressBar").set_ignore_mouse(true)
	queue = preload("res://resource_queue.gd").new()
	queue.start()
	
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func load_scene(path):
	set_process(true)
	resource_path = path
	queue.queue_resource(resource_path, true)
	
	get_node("AnimationPlayer").play("loading")
	get_node("Fade").play("fade_in")

func _process(delta):
	get_node("Control/ProgressBar").set_value(queue.get_progress(resource_path) * 100)

	if queue.is_ready(resource_path):
		set_process(false)
		set_new_scene(queue.get_resource(resource_path))
		get_node("Fade").play("fade_out")
	
	

func set_new_scene(scene_resource):
	current_scene.queue_free()
	var current_scene = scene_resource.instance()
	get_tree().get_root().add_child(current_scene)