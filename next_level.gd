extends Area2D

signal next


func _ready():
	hide()
	position = Vector2(0, 0)

func _on_area_entered(area):
	if is_visible_in_tree():
		hide() # Player disappears after being hit.
		next.emit()

func _on_draw():
	position = Vector2(randf_range(150.0, 250.0), randf_range(150.0, 250.0))
