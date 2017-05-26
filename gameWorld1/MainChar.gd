extends KinematicBody2D

var velocity = Vector2()
var walkSpeed = 75
var runSpeed = 100
var direction = Vector2()

# these are specifically defined for current sprite sheet
# ie this is probably a bad way to do things/will be updated later
var DOWN = 0
var LEFT = 1
var UP = 3
var RIGHT = 2

var NORTH = Vector2(0,-1)
var SOUTH = Vector2(0,1)
var WEST = Vector2(-1,0)
var EAST = Vector2(1,0)

var directionDict = { NORTH: UP, SOUTH: DOWN, WEST:LEFT, EAST: RIGHT }

#used to keep track of which direction was most recently pressed
var lastPressed = SOUTH


var sprite

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	set_process_input(true)
	sprite = get_node("Sprite")

func _input(event):
	if(event.is_action_pressed("ui_select") and not event.is_echo()):
		print(str(get_pos().x) +" "+str(get_pos().y))
	
	if(event.is_action_pressed("ui_down") and not event.is_echo()):
		lastPressed = SOUTH
	elif(event.is_action_pressed("ui_left") and not event.is_echo()):
		lastPressed = WEST
	elif(event.is_action_pressed("ui_right") and not event.is_echo()):
		lastPressed = EAST
	elif(event.is_action_pressed("ui_up") and not event.is_echo()):
		lastPressed = NORTH
	
func _fixed_process(delta):
	velocity = Vector2()
	
	var numbPresses = numberOfDirectionsPressed()
	if(numbPresses > 1):
		set_direction(lastPressed)
	else:
		if(Input.is_action_pressed("ui_down")):
			set_direction(SOUTH)
		elif(Input.is_action_pressed("ui_up")):
			set_direction(NORTH)
		elif(Input.is_action_pressed("ui_left")):
			set_direction(WEST)
		elif(Input.is_action_pressed("ui_right")):
			set_direction(EAST)
	
	#sets velocity only if some direction is currently pressed
	if(numbPresses > 0):
		set_velocity()
	var motion = velocity * delta
	move(motion)
	
	#provides a slide feature for movement along a wall
	if(is_colliding()):
		# good for testing whats being collided with
#		print(get_collider().get_name())
#		print("collision at: "+str(get_pos().x)+ " " + str(get_pos().y))
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

func set_direction(dir):
	direction = dir
	sprite.set_frame(directionDict[direction])

func set_velocity():
	velocity = direction * walkSpeed
	
func numberOfDirectionsPressed():
	var num = 0
	for dir in ["ui_down", "ui_up", "ui_left", "ui_right"]:
		if(Input.is_action_pressed(dir)):
			num +=1
	return num
