extends Spatial


onready var global_node  = get_node("/root/Transition")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Button_button_up():
	print("starting game")
	global_node.transition_to_game()
