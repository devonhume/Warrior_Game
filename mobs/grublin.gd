extends RigidBody2D

var target = null
@export var target_pos = Vector2()
const SPEED = 125
@export var health = 75
var is_dead = false
@onready var timer = $Timer
@onready var animated_sprite = $Sprite2D/AnimatedSprite2D
var stone_scene = preload("res://mobs/stone.tscn")
var stone
var stone_position = Vector2()
var stone_flag = true
var throw_flag = true
var stone_timer = true
var startled = false
var throw_animation_completed = true
var startled_animation_completed = true
signal target_loc(target_location)
var facing = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health < 1 and is_dead == false:
		is_dead = true
		if facing == "left":
			animated_sprite.play("dying_left")
		else:			
			animated_sprite.play("dying_right")

func _physics_process(delta):
	
	var anim = "stand_left"
	var pos = get_global_position()
	
	if target and is_dead != true:
		if startled:
			if startled_animation_completed == true:
				anim = "long_what_left"
				facing = "left"
				if target_pos[0] > pos[0]:
					anim = "long_what_right"
					facing = "right"
				animated_sprite.play(anim)
				startled_animation_completed = false
		elif throw_animation_completed:
			if stone_flag == false:
				if stone_timer == true:
					if is_instance_valid(stone) == false:
						stone_flag = true
						throw_flag = true
			target_pos = target.get_global_position()
			var distanceToTarget = pos.distance_to(target_pos)
			if distanceToTarget > 350:
				var velocity = global_position.direction_to(target.global_position)
				move_and_collide(velocity * SPEED * delta)
				anim = "run_left"
				facing = "left"
				if target_pos[0] > pos[0]:
					anim = "run_right"
					facing = "right"
				animated_sprite.play(anim)
			elif stone_flag and throw_flag:
				anim = "throw_left"
				facing = "left"
				if target_pos[0] > pos[0]:
					anim = "throw_right"
					facing = "right"
				animated_sprite.play(anim)
				throw_flag = true
			elif stone_flag == false and is_instance_valid(stone):
				anim = "angry_left"
				facing = "left"
				if target_pos[0] > pos[0]:
					anim = "angry_right"
					facing = "right"
				animated_sprite.play(anim)
			elif stone_flag:
				stone = stone_scene.instantiate()
				stone_position[1] = 0
				if target_pos[0] > pos[0]:
					stone_position[0] = 17
				else:
					stone_position[0] = -17
				stone.set_position(stone_position)
				add_child(stone)
				while is_instance_valid(stone) == false:
					print("waiting for stone instance")
				target_loc.emit(target_pos)
				stone_flag = false
				stone_timer = false
				timer.start()

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		target = body
		startled = true


func _on_timer_timeout():
	stone_timer = true


func _on_animated_sprite_2d_animation_finished():
	if startled == true:
		startled = false
		startled_animation_completed = true
	elif throw_flag == true:
		throw_animation_completed = true
		throw_flag = false

func take_damage(damage:int):
	health -= damage
