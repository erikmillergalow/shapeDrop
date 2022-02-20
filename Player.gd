extends Node

class_name Player

export(int) var id
export(Array, PoolVector2Array) var pieces


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize_player(id, pieces):
	id = id
	pieces = pieces

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
