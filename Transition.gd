extends CanvasLayer

var scene_path

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func fade_to(path):
	scene_path = path # store the scene path
	get_node("AnimationPlayer").play("fade") # play the transition animation

func change_scene():
	if scene_path != "":
		get_tree().change_scene(scene_path)

func transition_to_game():
	get_tree().change_scene("res://Game modes/Mahjong Solitaire/Game.tscn")
