extends RigidBody2D

@onready var animated_sprite = $Sprite2D/AnimatedSprite2D
@onready var timer = $Timer
@export var health = 100
var bun_strike_scene = preload("res://mobs/bun_strike.tscn")
var bun_strike
var is_dead = false
var target = null
const SPEED = 210
var anim = null
var emerged = false
var distanceToTarget = null
var target_pos = null
var in_range = false
signal attack(target, pos)
signal facing(direction)
var strike_animation_done = true
var surprise_animation_done = true
var dying_animation_done = true
var striking = false
var surprised = false
var dying = false

# Called when the node enters the scene tree for the first time.
func _ready():
	anim = "emerge_right"
	if global_position[0] > 0:
		anim = "emerge_left"
	animated_sprite.play(anim)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health < 1 and is_dead == false:
		is_dead = true
		animated_sprite.play("dying")

func _physics_process(delta):
	var pos = get_global_position()
	if target:
		target_pos = target.get_global_position() 
		distanceToTarget = pos.distance_to(target_pos)
	if is_dead == true:
		pass
	elif emerged:
		if surprised:
			if surprise_animation_done == true:
				anim = "surprise_left"
				if target_pos[0] > pos[0]:
					anim = "surprise_right"
				animated_sprite.play(anim)
				surprise_animation_done == false				
		elif target and in_range == false:
			var velocity = global_position.direction_to(target.global_position)
			move_and_collide(velocity * SPEED * delta)
			anim = "run_left"
			if target_pos[0] > pos[0]:
				anim = "run_right"
			animated_sprite.play(anim)
			if distanceToTarget < 30:
				in_range = true
		elif target and in_range == true:
			if distanceToTarget > 30:
				in_range = false
			if striking == false:
				var strike_offset = Vector2()
				attack.emit(target, pos)
				if  target_pos[0] < pos[0]:
					anim = "strike_left"					
				if target_pos[0] > pos[0]:
					anim = "strike_right"
				strike_offset[0] = target_pos[0] - pos[0]
				strike_offset[1] = target_pos[1] - pos[1]
				bun_strike = bun_strike_scene.instantiate()
				bun_strike.set_position(strike_offset)
				add_child(bun_strike)
				while is_instance_valid(bun_strike) == false:
					print("waiting for strike instance")
				facing.emit(find_facing(strike_offset))
				animated_sprite.play(anim)
				strike_animation_done = false
				striking = true
				timer.start()
			elif striking == true and strike_animation_done == true:
				anim = "stand_left"
				if target_pos[0] > pos[0]:
					anim = "stand_right"
				animated_sprite.play(anim)
				
func find_facing(offset):
	var x = offset[0]
	var y = offset[1]
	var facing
	if x < 0:
		if y < 0:
			if x <= y:
				facing = "left"
			else:
				facing = "up"
		if y > 0:
			if x <= y - (2 * y):
				facing = "left"
			else:
				facing = "down"
		else:
			facing = "left"		
	elif x > 0:
		if y > 0:
			if x >= y:
				facing = "right"
			else:
				facing = "down"
		elif y < 0:
			if x >= y - (2 * y):
				facing = "right"
			else:
				facing = "up"
		else:
			facing = "right"
	else:
		if y > 0:
			facing = "down"
		else:
			facing = "up"
			
	return facing
			


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		target = body
		surprised = true

func _on_animated_sprite_2d_animation_finished():
	if emerged == false:
		emerged = true
	elif surprised == true:
		surprised = false
		surprise_animation_done = true
	elif striking == true:
		strike_animation_done = true

func _on_timer_timeout():
	striking = false

func take_damage(damage:int):
	health -= damage
