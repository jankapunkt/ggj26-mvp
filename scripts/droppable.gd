extends Area2D

enum DroppableType {
	YELLOW,  # Shrinks all current enemies by 5000
	ORANGE   # Refills all gauges to maximum
}

@export var droppable_type: DroppableType = DroppableType.YELLOW
const SIZE = 50.0

func _ready():
	add_to_group("droppable")
	# Set up collision detection
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("body_entered", Callable(self, "_on_body_entered"))
	queue_redraw()  # Make sure the droppable is visible

func _draw():
	var color: Color
	match droppable_type:
		DroppableType.YELLOW:
			color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow
		DroppableType.ORANGE:
			color = Color(1.0, 0.5, 0.0, 1.0)  # Orange
	
	# Draw as 50x50 square
	var half_size = SIZE / 2
	draw_rect(Rect2(-half_size, -half_size, SIZE, SIZE), color)
	# Add border
	draw_rect(Rect2(-half_size, -half_size, SIZE, SIZE), color.lightened(0.3), false, 2.0)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_on_player_pickup()

func _on_area_entered(area):
	# In case player is an Area2D
	if area.is_in_group("player"):
		_on_player_pickup()

func _on_player_pickup():
	# Notify parent (game controller) about pickup
	if get_parent().has_method("_on_droppable_picked_up"):
		get_parent()._on_droppable_picked_up(self)
	queue_free()

func get_type() -> DroppableType:
	return droppable_type
