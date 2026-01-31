extends Area2D

signal bullet_hit_enemy(enemy)

const BULLET_SPEED = 600.0
const BULLET_RADIUS = 10.0
const VIEWPORT_HEIGHT = 1920

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	# Move bullet downward
	position.y += BULLET_SPEED * delta
	
	# Remove bullet if it goes off screen
	if position.y > VIEWPORT_HEIGHT + 100:
		queue_free()

func _on_area_entered(area):
	# Check if the area is an enemy
	if area.is_in_group("enemy"):
		emit_signal("bullet_hit_enemy", area)
		queue_free()

func _draw():
	# Draw bullet as a small white circle
	draw_circle(Vector2.ZERO, BULLET_RADIUS, Color.WHITE)
