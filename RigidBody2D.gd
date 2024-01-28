extends RigidBody2D

var target = null
@onready var _area_body = $Area2D
const SPEED = 220

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if target:
		var velocity = global_position.direction_to(target.global_position)
		move_and_collide(velocity * SPEED * delta)
		
func _on_Area2D_body_entered(body):
	print(body.name)
	if body.name == "Player":
		target = body
