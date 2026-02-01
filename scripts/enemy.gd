extends Area2D

signal enemy_destroyed

var enemy_type = 1
var move_speed = 120.0

# Enemy size configuration
const MAX_ENEMY_SIZE = 700
const MIN_ENEMY_SIZE = 100.0
const KILL_SIZE = 30

var current_size = MIN_ENEMY_SIZE

# --- Hit sound control ---
var hit_sound_queue: Array[AudioStream] = []
var hit_sound_playing := false
var hit_sound_timeout := 0.0
const HIT_SOUND_GRACE_TIME := 0.15

@onready var hit_sounds = [
	preload("res://assets/sounds/enemy/enemy_death_1.wav"),
	preload("res://assets/sounds/enemy/enemy_death_2.wav"),
	preload("res://assets/sounds/enemy/death_enemy_3.wav")
]

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var sprite: Sprite2D = $Sprite2D

# Preload enemy textures
const ENEMY_TEXTURES = {
	1: preload("res://assets/images/demon.png"),
	2: preload("res://assets/images/wrestler-red.png"),
	3: preload("res://assets/images/wrestler-yellow.png")
}

# -------------------------------------------------------

func _ready():
	position.x = randi_range(0, 1080)
	add_to_group("enemy")

	# ✅ ensure signal is connected
	if not hit_sound.finished.is_connected(_on_HitSound_finished):
		hit_sound.finished.connect(_on_HitSound_finished)
	
	# Set texture based on enemy_type
	if enemy_type in ENEMY_TEXTURES:
		sprite.texture = ENEMY_TEXTURES[enemy_type]

func init(max_size):
	if max_size > MAX_ENEMY_SIZE:
		max_size = MAX_ENEMY_SIZE
	current_size = randi_range(MIN_ENEMY_SIZE, max_size)
	move_speed = remap(current_size, MIN_ENEMY_SIZE, MAX_ENEMY_SIZE, 220, 80)
	update_sprite_scale()

func _process(delta):
	hit_sound_timeout -= delta
	if hit_sound_timeout <= 0.0:
		stop_hit_sounds()

	position.y -= move_speed * delta

	var player = get_parent().get_node_or_null("Player")
	if player:
		var dir = sign(player.position.x - position.x)
		position.x += dir * move_speed * 0.5 * delta

# -------------------------------------------------------
# Sprite scaling
# -------------------------------------------------------

func update_sprite_scale():
	if sprite and sprite.texture:
		# Scale sprite to match current_size
		# Assuming texture has a base size, scale uniformly
		var texture_size = sprite.texture.get_size()
		var scale_factor = current_size / max(texture_size.x, texture_size.y)
		sprite.scale = Vector2(scale_factor, scale_factor)

# -------------------------------------------------------
# Damage / shrink
# -------------------------------------------------------

func shrink(rate):
	current_size -= rate
	hit_sound_timeout = HIT_SOUND_GRACE_TIME

	# ✅ THIS WAS MISSING
	play_hit_sound()

	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = current_size / 2
	
	# Update sprite scale when size changes
	update_sprite_scale()

	if current_size <= KILL_SIZE:
		stop_hit_sounds()

		# ✅ play death sound safely via parent
		if get_parent().has_method("play_death_sound"):
			get_parent().play_death_sound(death_sound.stream, global_position)

		emit_signal("enemy_destroyed", self)
		queue_free()

# -------------------------------------------------------
# Hit sound queue system
# -------------------------------------------------------

func play_hit_sound():
	if hit_sound_queue.size() < 3:
		hit_sound_queue.append(hit_sounds.pick_random())

	if not hit_sound_playing:
		_play_next_hit_sound()

func _play_next_hit_sound():
	if hit_sound_queue.is_empty():
		hit_sound_playing = false
		return

	hit_sound_playing = true
	hit_sound.volume_db = -15
	hit_sound.pitch_scale = randf_range(0.9, 1.1)
	hit_sound.stream = hit_sound_queue.pop_front()
	hit_sound.play()

func stop_hit_sounds():
	hit_sound_queue.clear()
	hit_sound_playing = false
	if hit_sound.playing:
		hit_sound.stop()

func _on_HitSound_finished():
	_play_next_hit_sound()
