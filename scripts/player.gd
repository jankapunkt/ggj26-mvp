extends CharacterBody2D

const SPEED = 1000.0
const VIEWPORT_WIDTH = 1080
const VIEWPORT_HEIGHT = 1920
const RADIUS = 125

# Current player color (updated by game controller based on ability)
var current_color = Color(0.4, 0.9, 0.4, 1.0)
var current_type = 4

# Rapid fire settings for Ability 2
@export var ability_2_fire_rate := 20.0  # shots per second
var time_since_last_shot := 0.0

@export var pellet_count := 3
@export var spread_angle := 30.0  # degrees
@export var bullet_speed := 600.0

@onready var player_sprite: Sprite2D = $bob
@onready var player_japan: Sprite2D = $japan
@onready var player_africa: Sprite2D = $african
@onready var player_mexico: Sprite2D = $mexican


@onready var idle_texture_bob: Texture2D = preload("res://assets/images/bob.png")
@onready var shoot_texture_bob: Texture2D = preload("res://assets/images/evil_bob_.png")

@onready var idle_texture_japan: Texture2D = preload("res://assets/images/oni_mask_evil.png")
@onready var shoot_texture_japan: Texture2D = preload("res://assets/images/oni_mask_evil_evil.png")

@onready var idle_texture_mexico: Texture2D = preload("res://assets/images/mexican_mask.png")
@onready var shoot_texture_mexico: Texture2D = preload("res://assets/images/mexican_mask_evil.png")

@onready var idle_texture_africa: Texture2D = preload("res://assets/images/african_mask_2.png")
@onready var shoot_texture_africa: Texture2D = preload("res://assets/images/african_mask_evil.png")


# Drag force from enemies
var drag_force = Vector2.ZERO

@onready var shoot_sounds_pistole = [
	preload("res://assets/sounds/weapons/pistole/Pew_1.wav"),
	preload("res://assets/sounds/weapons/pistole/Pew_2.wav"),
	preload("res://assets/sounds/weapons/pistole/Pew_3.wav")
]

@onready var shoot_sounds_shotgun = [
	preload("res://assets/sounds/weapons/shotgun/shotgun_pew1.wav"),
	preload("res://assets/sounds/weapons/shotgun/shotgun_pew2.wav"),
	preload("res://assets/sounds/weapons/shotgun/shotgun_pew3.wav")
]

# Bullet scene reference
var bullet_scene = preload("res://scenes/bullet.tscn")

func _ready():
	queue_redraw()

func _physics_process(delta):
	# Update time since last shot (for throttling)
	time_since_last_shot += delta
	var shoot_pressed = Input.is_action_pressed("shoot")
	var can_shoot_now = false
	
	# For Ability 1 (RED), allow rapid fire by holding space
	if current_type == 1:
		# Calculate fire interval based on fire rate
		var fire_interval = 1.0 / ability_2_fire_rate
		# Check if enough time has passed since last shot
		if shoot_pressed and time_since_last_shot >= fire_interval:
			can_shoot_now = true
	else:
		# For other abilities, use single shot (just pressed)
		if Input.is_action_just_pressed("shoot"):
			can_shoot_now = true
		
	# Handle shooting
	if can_shoot_now:
		# Check if we can shoot (gauge available)
		if get_parent().has_method("can_shoot") and get_parent().can_shoot():
			match current_type:
				1: shoot_bullet()
				2: shoot_shotgun()
				3: shoot_shotgun()
				4: shoot_bullet()
				_: shoot_shotgun()
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
	
var is_shooting := false

func change_to_shoot_sprite():
	if is_shooting:
		return

	is_shooting = true
	player_sprite.texture = shoot_texture_bob
	player_africa.texture = shoot_texture_africa
	player_japan.texture = shoot_texture_japan
	player_mexico.texture = shoot_texture_mexico

	await get_tree().create_timer(0.1).timeout

	player_sprite.texture = idle_texture_bob
	player_africa.texture = idle_texture_africa
	player_japan.texture = idle_texture_japan
	player_mexico.texture = idle_texture_mexico
	
	is_shooting = false


	
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
	change_to_shoot_sprite()
	$ShootSound.stream = shoot_sounds_shotgun.pick_random()
	$ShootSound.play()

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.connect("bullet_hit_enemy", Callable(get_parent(), "_on_bullet_hit_enemy"))
	get_parent().add_child(bullet)
	change_to_shoot_sprite()
	$ShootSound.stream = shoot_sounds_pistole.pick_random()
	$ShootSound.play()

# func _draw():
	# Draw player as a circle with current ability color
	# draw_circle(Vector2.ZERO, RADIUS, current_color.darkened(0.3))
	# draw_circle(Vector2.ZERO, RADIUS, current_color)
