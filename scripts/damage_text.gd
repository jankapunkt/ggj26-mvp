extends Label

# Configuration
const DISPLAY_DURATION = 0.3  # 300ms as specified
const FLOAT_SPEED = 100.0  # Pixels per second to float upward

var elapsed_time = 0.0

func _ready():
	# Set text properties
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_font_size_override("font_size", 48)
	# Center the label horizontally
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Set size
	size = Vector2(200, 60)
	# Offset to center the label on the position
	position -= size / 2

func _process(delta):
	elapsed_time += delta
	
	# Float upward
	position.y -= FLOAT_SPEED * delta
	
	# Remove after duration
	if elapsed_time >= DISPLAY_DURATION:
		queue_free()

func set_damage(damage_amount: float):
	# Set the damage amount to display
	text = str(int(damage_amount))
