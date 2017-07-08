extends Spatial


onready var global_node  = get_node("/root/Transition")
onready var loading_screen  = get_node("/root/loading_screen")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Button_button_up():
#	print("starting game")
#	global_node.fade_to("res://Game modes/Mahjong Solitaire/Game.tscn")
	loading_screen.load_scene("res://Game modes/Mahjong Solitaire/Game.tscn")
