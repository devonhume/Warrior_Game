extends CharacterBody2D

var health = 100
var last_pressed = "None"
var anim = "stance_down"
var strike
var strike_offset = Vector2()
var strike_flag = false
var strike_animation_completed_flag = true
signal facing(direction)
signal health_change(amount)
var strike_scene = preload("res://characters/strike.tscn")
@onready var _animated_sprite = $AnimatedSprite2D
@onready var energy_bar = $/root/Node2D/CanvasLayer/ProgressBar
@onready var temp_label = $/root/Node2D/CanvasLayer/Label
@onready var energy_timer = $Timer
var energy_tick = true
var enemy = false

@export var speed = 200

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
func _process(_delta):
	if energy_bar.value < 100 and energy_tick == true:
		energy_bar.value += 2.5
		energy_tick = false
		energy_timer.start()
	var new_anim = anim
	if strike_animation_completed_flag == true:
		if Input.is_action_pressed("right"):
			last_pressed = "right"
			new_anim = "right"
		elif Input.is_action_pressed("left"):
			last_pressed = "left"
			new_anim = "left"
		elif Input.is_action_pressed("up"):
			last_pressed = "up"
			new_anim = "up"
		elif Input.is_action_pressed("down"):
			last_pressed = "down"
			new_anim = "down"
		elif Input.is_action_just_pressed("attack"):
			strike_flag = true
			if last_pressed == "up":
				new_anim = "strike_up"
				strike_offset[0] = 0
				strike_offset[1] = -25
			elif last_pressed == "left":
				new_anim = "strike_left"
				strike_offset[0] = -25
				strike_offset[1] = 0
			elif last_pressed == "right":
				new_anim = "strike_right"
				strike_offset[0] = 25
				strike_offset[1] = 0
			else:
				new_anim = "strike_down"
				strike_offset[0] = 0
				strike_offset[1] = 25
			strike = strike_scene.instantiate()
			strike.set_position(strike_offset)
			if enemy == true:
				add_child(strike)
				while is_instance_valid(strike) == false:
					print("waiting for strike instance")
			facing.emit(last_pressed)
		elif last_pressed == "up":
			new_anim = "stand_up"
		elif last_pressed == "down":
			new_anim = "stand_down"
		elif last_pressed == "left":
			new_anim = "stand_left"
		elif last_pressed == "right":
			new_anim = "stand_right"
		else:
			new_anim = "stance_down"
			
	if new_anim != anim and strike_animation_completed_flag == true:
		anim = new_anim
		_animated_sprite.play(anim)
		if strike_flag == true:
			strike_animation_completed_flag = false
	
func _physics_process(_delta):
	get_input()
	move_and_slide()


func _on_animated_sprite_2d_animation_finished():
	if strike_flag == true:
		strike_animation_completed_flag = true
		strike_flag = false


func _on_area_2d_body_entered(body):
	enemy = true


func _on_area_2d_body_exited(body):
	enemy = false


func _on_timer_timeout():
	energy_tick = true
	
func take_char_damage(damage):
	if health > 0:
		health -= damage
		health_change.emit(damage)
		temp_label.set_text(str(health))
