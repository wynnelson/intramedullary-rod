extends KinematicBody2D

var walkSpeed = 30

var nav = null
var velocity = Vector2()
var direction = Vector2()
var timeOfLastDirectionChange = 0
var minDirectionChangeTime = 3
var isDead = false
var failedMoveAttempts = 0
# set true if a navigation2d exists and you want to move around in it
export (bool) var mobile = true

var NORTH = Vector2(0,-1)
var SOUTH = Vector2(0,1)
var WEST = Vector2(-1,0)
var EAST = Vector2(1,0)
var DIRECTIONS = [ NORTH, SOUTH, WEST, EAST ]

onready var animator = get_node("AnimationPlayer")
onready var collider = get_node("CollisionPolygon2D")

signal dead


func _ready():
	set_fixed_process(true)
	direction = DIRECTIONS[randi()%4]
	directionChanged()
	animator.play("Moving")

	
func _fixed_process(delta):
	# this should all get cleanup some
	if(!isDead):
		if(is_colliding()):
			#print("enemy hit: "+get_collider().get_name())
			var collWith = get_collider()
			if(collWith.is_in_group("weapon")):
				died()
			
			elif(collWith.is_in_group("player")):
				collWith.gotHitByEnemy()
	
		#follows a path
		if(get_parent().get_type() == "PathFollow2D"):
			get_parent().set_offset(get_parent().get_offset() + (walkSpeed*delta))
	
		#wanders around in the nav
		elif(mobile):
			if(nav == null):
				#get the navigation2d which will be a child off of the root
				# better hope the guy is a child of a child of whatever has the nav
				#nav = get_parent().get_parent().get_node("Navigation2D")
			
				# if using the individual tile method, NEED TO UNCOMMENT THE ABOVE AND COMMENT OUT THE BELOW
				# right now this always returns the first Nav tagged with enemyNav
				nav = get_tree().get_nodes_in_group("enemyNav")[0]
			
			if(nav != null): # fails when no such navigation2d node is found
				# turns around if it hits something
				if(is_colliding()):
					direction = getNewDirection()
				elif(OS.get_unix_time()- timeOfLastDirectionChange > minDirectionChangeTime):
					direction = getNewDirection()
				velocity = direction*walkSpeed*delta
						
				if(canMove()):
					move(velocity)
					#set_pos(get_pos()+velocity)
					failedMoveAttempts = 0
				else:
					failedMoveAttempts += 1
					# a bad assumption, but if it cant move in any direction, then it was forced
					# there, presumably by something that would have killed it (issue with hammer 
					# doesnt report collision)
					if(failedMoveAttempts >8 ):
						died()
					direction = getNewDirection()
	
	
# returns true if the moving in the current direction stays in the mesh
func canMove():
	var attemptedMove = get_pos()+velocity
	var closestToAttempt  = nav.get_closest_point(attemptedMove)
	#return attemptedMove == nav.get_closest_point(attemptedMove)
	#print(str(attemptedMove.x) + " " + str(attemptedMove.y))
	#print(str( closestToAttempt.x) + " " + str( closestToAttempt.y))
	return attemptedMove ==  closestToAttempt
	

func getNewDirection():
	var newD = DIRECTIONS[randi()%4]
	while( newD == direction):
		newD = DIRECTIONS[randi()%4]
	directionChanged()
	return newD

#updates the things that need to change when direction changes
func directionChanged():
	timeOfLastDirectionChange = OS.get_unix_time()
	minDirectionChangeTime = randi()%4+1

# determines a random point in the mapTile
func randomGamePoint():
	var xCoord = randi()%320
	var yCoord = randi()%192
	return Vector2(xCoord, yCoord)

# does the things that happen at death
func died():
	animator.play("Death")
	isDead = true
	collider.set_trigger(true)

	
func done_dying():
	emit_signal("dead")


func _on_AnimationPlayer_finished():
	pass # replace with function body
