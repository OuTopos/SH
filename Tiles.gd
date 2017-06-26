extends Node

var tile_size  = Vector3(2.6, 1.9, 3.4)
var snap_steps = 2
var split = tile_size / Vector3(snap_steps*2, snap_steps*2, snap_steps*2)

var rays = {"top": [], "left": [], "right": []}

func _ready():
	# Generate ray trace points
	# Top
	for z in range(-snap_steps / 2, snap_steps / 2):
		for x in range(-snap_steps / 2, snap_steps / 2):
			var ray_offset = Vector3(x * split.x * 2 + split.x, tile_size.y / 2, z * split.z * 2 + split.z)
			var ray = {
				"from": ray_offset,
				"to": ray_offset + Vector3(0, 100, 0)
			} 
			rays["top"].append(ray)
	# Left and Right
	for z in range(-snap_steps / 2, snap_steps / 2):
		var ray_offset = Vector3(0, tile_size.y / 2, z * split.z * 2 + split.z)
		var left_ray = {
			"from": ray_offset,
			"to": ray_offset + Vector3(-100, 0, 0)
		}
		var right_ray = {
			"from": ray_offset,
			"to": ray_offset + Vector3(100, 0, 0)
		} 
		rays["left"].append(left_ray)
		rays["right"].append(right_ray)