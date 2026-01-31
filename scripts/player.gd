extends CharacterBody2D

const SPEED = 1000.0
const VIEWPORT_WIDTH = 1080
const VIEWPORT_HEIGHT = 1920
const RADIUS = 125

# Current player color (updated by game controller based on ability)
var current_color = Color(0.4, 0.9, 0.4, 1.0)

@export var pellet_count := 3
@export var spread_angle := 30.0  # degrees
@export var bullet_speed := 600.0

# Drag force from enemies
var drag_force = Vector2.ZERO

@onready var shoot_sounds = [
	preload("res://assets/sounds/Pew_1.wav"),
	preload("res://assets/sounds/Pew_2.wav"),
	preload("res://assets/sounds/Pew_3.wav")
]

# Bullet scene reference
var bullet_scene = preload("res://scenes/bullet.tscn")

func _ready():
	queue_redraw()

func _physics_process(delta):
	# Handle shooting
	if Input.is_action_just_pressed("shoot"):
		# Check if we can shoot (gauge available)
		if get_parent().has_method("can_shoot") and get_parent().can_shoot():
			shoot_shotgun()
			# Consume gauge after shooting
			if get_parent().has_method("consume_gauge"):
				get_parent().consume_gauge()
	
	# Get input direction for horizontal movement
	var direction_x = Input.get_axis("move_left", "move_right")
	
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Get input direction for vertical movement
	var direction_y = Input.get_axis("move_up", "move_down")
	
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	# Apply drag force from enemies (this pulls player toward chaser)
	velocity += drag_force
	
	# Keep player within bounds
	position.x = clamp(position.x, RADIUS + 10, VIEWPORT_WIDTH - (RADIUS + 10))
	position.y = clamp(position.y, RADIUS + 10, VIEWPORT_HEIGHT - (RADIUS + 10))
	
	move_and_slide()
	
	# Reset drag force each frame (will be re-applied by colliding enemies)
	drag_force = Vector2.ZERO
	
func shoot_shotgun(): 
	for i in pellet_count:
		var bullet = bullet_scene.instantiate()
		bullet.connect("bullet_hit_enemy", Callable(get_parent(), "_on_bullet_hit_enemy"))
		bullet.position = position
		
		# Random spread
		var angle_offset = deg_to_rad(randf_range(-spread_angle/2, spread_angle/2))
		var direction = Vector2.DOWN.rotated(angle_offset)  # base is DOWN
		
		bullet.velocity = direction * bullet_speed
		get_parent().add_child(bullet)

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.connect("bullet_hit_enemy", Callable(get_parent(), "_on_bullet_hit_enemy"))
	get_parent().add_child(bullet)
	$ShootSound.stream = shoot_sounds.pick_random()
	$ShootSound.play()

func _draw():
	# Draw player as a circle with current ability color
	draw_circle(Vector2.ZERO, RADIUS, current_color.darkened(0.3))
	draw_circle(Vector2.ZERO, RADIUS, current_color)
