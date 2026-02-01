extends Area2D

signal bullet_hit_enemy(enemy)

@onready var bullet_sprite: Sprite2D = $BulletSprite
var velocity: Vector2 = Vector2.DOWN * 600
var bullet_textures: Array[Texture2D] = [
	preload("res://assets/images/tear.png"),
	preload("res://assets/images/leaf.png"),
	preload("res://assets/images/fist.png")
]

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	if bullet_sprite == null:
		push_error("bullet_sprite is null! Check node name and script attachment.")
	else:
		set_texture(0)

func _process(delta):
	position += velocity * delta

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		emit_signal("bullet_hit_enemy", area)
		queue_free()

func set_texture(index: int):
	print_debug("bullet text", index)
	if bullet_sprite != null and bullet_sprite.texture != bullet_textures[index]:
		bullet_sprite.texture = bullet_textures[index]
