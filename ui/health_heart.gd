extends TextureRect

@export var order_number : int
var hearts = ["res://ui/health_hearts/health_heart_00.png", 
"res://ui/health_hearts/health_heart_10.png", 
"res://ui/health_hearts/health_heart_20.png", 
"res://ui/health_hearts/health_heart_30.png",
"res://ui/health_hearts/health_heart_40.png",
"res://ui/health_hearts/health_heart_50.png",
"res://ui/health_hearts/health_heart_60.png",
"res://ui/health_hearts/health_heart_70.png",
"res://ui/health_hearts/health_heart_80.png",
"res://ui/health_hearts/health_heart_90.png",
"res://ui/health_hearts/health_heart_full.png"]

@onready var player = %Player
var current_health = 100
var local_health = 10
var local_zero = 0

func _ready():
	player.health_change.connect(_change_heart)
	local_zero = order_number * 10

func _process(_delta):
	pass
	
func _change_heart(difference):
	print("order: ", order_number)
	print("local-zero: ", local_zero)
	print("damage: ", difference)
	current_health -= difference
	print("new-health: ", current_health)
	var z_health = current_health - local_zero
	print("z_health: ", z_health)
	#in-range
	if 10 >= z_health and z_health>= 0:
		print("in-range")
		local_health = current_health - local_zero
		texture = load(hearts[local_health])
	#skipped-range; 
	elif current_health <= local_zero and local_health > 0:
		print("lower")
		local_health = 0
		texture = load(hearts[local_health])
	#healing
	elif local_health < 10 and z_health >= 10:
		print("higher")
		local_health = 10
		texture = load(hearts[local_health])
	else:
		print("not-effected")
	
