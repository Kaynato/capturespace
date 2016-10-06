### Four-Sphere Library ###
FSPH = exports ? -> this.FSPH = {}

# Handles world, step, collision, physics, projection

# World
class FSPH.World
	# Takes theta-determining function
	constructor: (@detf) ->
		# Moving objects - require FSphere
		@actors = []
		# container
		@space = null

	add: (o) ->
		@actors.push o

	remove: (o) ->
		if @actors.indexOf(o) >= 0 then @actors.splice @actors.indexOf(o), 1
		else console.error "Element not in array!"

	step: ->
		# for each object, see if it collides with the other objects
		`for (var i = 0; i < this.actors.length; i++) {
			var actor = this.actors[i];

			if (actor.FSPHShape != null) actor = FSPHShape;
			else throw new Error("Actor does not have a shape!");

			// Extrapolate
			actor.move()
			// Collide
			for (var j = 0; j < this.actors.length; j++) {
				var other = this.actors[j];

				if (other.FSPHShape != null) other = FSPHShape;
				else throw new Error("Actor does not have a shape!");

				if actor.collides(other, @detf)
					// When collision takes place

			}
		}`
		# Recalculate


# Create a Four-Sphere - USE NEW
class FSPH.FSphere
	constructor: (@mass, @radius) ->
		@prevpos = [0, 0, 0] # Previous Position
		@position = [0, 0, 0]
		@velocity = [0, 0, 0]
		@θ = 0
		@dθ = 0

	move: ->
		for i in [0..2]
			@prevpos[i] = @position[i]
			@position[i] += @velocity[i]
		@θ += @dθ
		return

	# "Effective radius", taking into consideration θ
	# The range from 1 to bound operates on the result of
	# 	Math.cos(diff) where diff is the difference of θ.
	effectiveradius: (diff, bound) ->
		factor = Math.cos(diff);
		return 1 if bound >= 1
		if factor > 1 or factor is 1 then factor = 1
		else if factor < bound then factor = 0
		else factor = (factor - bound) * (1 - bound)
		return @radius * factor

	# Collide with other FSphere.
	collides: (other, detf) ->
		return false if other not instanceof FSPH.FSphere
		# Delta in position
		δ = 0
		for i in [0..2]
			δ += (@position[i] - other.position[i])*(@position[i] - other.position[i])
		ρ = @effectiveradius(@θ - other.θ, detf this) + other.effectiveradius(@θ - other.θ, detf other)
		ρ *= ρ
		if δ <= ρ
			return true
		else return false

# SPACE TYPE SHELL
class FSPH.SShell
	constructor: (@radius) ->

FSPH.Test = ->
	s1 = new FSPH.FSphere(1, 1)
	s2 = new FSPH.FSphere(1, 1)
	# In-place collision
	s1.collides(s2)
	# Off-center collision
	s1.position = [0.5, 0.5, 0.5]
	s1.collides(s2)


