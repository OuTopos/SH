extends CanvasLayer

var loader
var wait_frames
var time_max = 100
var current_scene

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func _process(delta):
	if loader == null:
		set_process(false)
		return
	
	if wait_frames > 0:
		wait_frames -= 1
		return
	
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		
		var err = loader.poll()
		
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			get_node("ProgressBar").set_value(100)
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else:
			show_error()
			loader = null
			break
func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	get_node("ProgressBar").set_value(progress * 100)
	print("Loading: " + str(progress) + "%")

func set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	
func goto_scene(path):
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		show_error()
		return
	set_process(true)
	
	current_scene.queue_free()
	get_node("AnimationPlayer").play("loading")
	
	wait_frames = 1