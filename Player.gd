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
	pieces = vertices.duplicate()

func remove_piece(index):
	pieces.remove(index)

func initialize_inventory():
	
	var current_inventory_shapes = get_tree().get_nodes_in_group(String(id) + "_inventory")
	# remove old shape bodies
	for item in current_inventory_shapes:
		get_node('..').remove_child(item)
		item.queue_free()
	
	var vertical_shift = 80
	if (id == 2):
		vertical_shift = 300
	
	var horizontal_shift = 0
	for piece in pieces:
		var shape = Polygon2D.new()
		shape.polygon = piece
		shape.scale = Vector2(.2, .2)
		print(get_parent())
		get_node('..').add_child(shape)
		shape.add_to_group(String(id) + "_inventory")
		shape.position = Vector2(60 + horizontal_shift, 100 + vertical_shift)
		horizontal_shift += 35

