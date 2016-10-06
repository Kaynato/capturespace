sha256 = require 'js-sha256'

exports.randColor = ->
	(Math.floor(Math.random()*16777215))|0

# GENERATE A KEY AND HASH
exports.keygen = ->


# VALIDATE A KEY. RETURN TRUE OR FALSE BASED ON VALIDATION OF KEY.
exports.validate = (key, hash, salt) ->
	H = sha256(saltCombine key, salt)
	return (H is hash)

# generate a salt
saltGen = ->
	result = '';
	x = (Math.random()+"").slice(2)+(Math.random()+"").slice(2)
	`for (var i = 0; (i+2) < x.length; i++)
		result += String.fromCharCode((9+i) * parseInt(x.slice(i,i+2),16))`
	return result


# combine a string and salt
saltCombine = (S = "", s) ->
	s.slice(0, 4) + S.slice(0, 3) + s.slice(4, 8) + S.slice(3, 7) +
		s.slice(8, 12) + S.slice(7, S.length) + s.slice(12, s.length)

# hash a string and salt it, returning hash and salt
potato = (s) ->
	q = saltGen()
	return [sha256(saltCombine s, q), q]

# See pdist.nb to understand what's going on here
# Please, only have 2 teams so far
# NUMPLAYERS is number of players.
# RS is the "room" object from the CFG.JSON
# team is either 1 or 0
#	Returns cycling through teams
#	A B C A B C A B C etc.
exports.playerCoords = (RS) ->
	if RS.teams isnt 2
		throw new Error "Must have exactly 2 teams."
	if RS.playersPerTeam is 1
		return [[0,0,RS.radius-RS.PSPAWN],[0,0,RS.PSPAWN-RS.radius]]
	results = []
	for i in [0..(RS.playersPerTeam-1)]
		for team in [0..(RS.teams-1)]
			# Radial dist
			mag = Math.sqrt(RS.PSPAWN * (2 * RS.radius - RS.PSPAWN))
			# Angular position
			ang = 2*Math.PI * ((i + (team/RS.teams))/RS.playersPerTeam)
			# Coordinate
			R = avec mag, ang
			console.log "R: [#{R}] || θ: #{ang} || M: #{mag} || team #{team}"
			# Axial coordinate
			R.push(((2*team-1)*(RS.radius-RS.PSPAWN))|0)
			results.push R
	results

# Takes radians
avec = (mag, ang) ->
	[(mag * Math.cos(ang))|0,(mag * Math.sin(ang))|0]