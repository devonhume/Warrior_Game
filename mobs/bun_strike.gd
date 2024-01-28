extends CharacterBody2D

@onready var animated_sprite = $Sprite2D/AnimatedSprite2D
@onready var bun = get_node("../")
@onready var timer = $Timer
@export var damage = 10
var strike_animation_finished = true
var facing = null
var enemy = false

func _ready():
	bun.facing.connect(_get_facing)

func _physics_process(delta):
	if facing and strike_animation_finished == true:
		if facing == "left":
			animated_sprite.play("strike_left")
		elif facing == "right":
			animated_sprite.play("strike_right")
		elif facing == "up":
			animated_sprite.play("strike_up")
		elif facing == "down":
			animated_sprite.play("strike_down")
		timer.start()
		strike_animation_finished = false
		

func _on_area_2d_body_entered(body):
	if body.has_method("take_char_damage"):
		body.take_char_damage(damage)
		enemy = true

func _get_facing(direction):
	facing = direction

func _on_animated_sprite_2d_animation_finished():
	queue_free()


func _on_timer_timeout():
	queue_free()

