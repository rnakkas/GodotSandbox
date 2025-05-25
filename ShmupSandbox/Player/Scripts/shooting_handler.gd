class_name ShootingHandler extends Node2D

#TODO: Will handle all the shooting logic for the player
## - Needs the following:
	# - death state, player script will update it here
	# - muzzles - for base, od and ch shooting
	# - sprites for the body and rocket to play and sync shooting and idle animations 
	#		- maybe better to send signal to parent player node and let the parent handle the animations
	# - muzzle flash sprites - for base, od and ch
	#		- see previous point, maybe just send signal to player node
	# - fire rate
	# - bullet scenes - for base, od and ch
	# - power up level
	# - od bullet angles
	# - od bullets per shot
	# - global signal connection - powerup type that was picked up
	# - emit global signal/event - to add bullets to the game when shooting
