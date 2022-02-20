extends Node

class_name Player

export(int) var id
export(Array, PoolVector2Array) var pieces


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(player_id, vertices):
	print("Pieces:", pieces)
	id = player_id
	pieces.append_array(vertices)

#func get_pieces():
#	print("get_pieces():", pieces)
#	return pieces
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
