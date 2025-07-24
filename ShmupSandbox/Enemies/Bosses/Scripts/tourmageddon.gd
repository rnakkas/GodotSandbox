class_name BossTourmageddon extends Node2D

##TODO:
# Boss behaviour:
	# Has very high health (similar to other bosses)
	# Slowly fly in from the right
	# Stay on the right side of the screen
	# Behaviour 1:
		# Move vertically down
		# Slow to a stop near bottom of screen
		# Shoot from the roof cannons for a set amount of time
		# Rapidly move to the left of the screen to try and crush the player, then fly back to right of screen
		# Move vertically up
		# Slow to a stop near the top of the screen
		# Shoot from the roof cannons for a set amount of time
		# Rapidly move to the right of the screen to try and crush the player, then fly back to right of screen
		# Repeat
	# Behaviour 2:
		# Similar movements as behaviour 1 but no stopping at the top and bottom, constant moving up and down
		# Shoot from the roof cannons at a steady pace
		# Also spawn skulljacks, screamers and boomers from the door
		# No rapid move to the left to try and crush the player
	# Spawn, play behaviour 1
	# After health drops below a certain percentage, start behaviour 2
	# Behaviour 2 can also start after a certain amount of time has passed
	# Fly off to the left of the screen to go off screen and despawn after screen time (~10 mins) has elapsed
		# This is to keep the game going even if the player fails to kill the boss
	# Once boss is killed or flies off screen, send a global signal that boss sequence has ended.