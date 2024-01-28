extends RigidBody2D

@onready var parent = get_node("../")
@export var stone_speed = 400
@onready var animation_sprite = $Sprite2D/AnimatedSprite2D
var target_pos = Vector2()
var velocity = Vector2()
var animation_finished = false
var burst = false
var hit_something
var distance_x
var distance_y

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_sprite.play("default")
	parent.target_loc.connect(_set_target_location)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	distance_x = target_pos[0] - global_position[0]
	distance_y = target_pos[1] - global_position[1]
	
	
	if (5 > distance_x and distance_x > -5 and 5 > distance_y and distance_y > -5) or hit_something == true:
		if burst == false:
			burst = true
			animation_sprite.play("burst")
	elif burst == false:
		velocity = global_position.direction_to(target_pos)
		velocity = move_and_collide(velocity * stone_speed * delta)

func _on_animated_sprite_2d_animation_finished():
	if burst == true:
		self.queue_free()

	
func _set_target_location(target_location):
	target_pos = target_location


func _on_area_2d_body_entered(body):
	if body.name != "Grublin" and body.name != "Stone":
		hit_something = true
	if  body.has_method("take_char_damage"):
		body.take_char_damage(15)
