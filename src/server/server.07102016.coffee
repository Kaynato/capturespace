# app / index.Coffee

jsonfile = require 'jsonfile'
# sha256 = require 'js-sha256'
express = require 'express'
app = express()
http = require('http').Server app
io = require('socket.io') http
SAT = require 'sat'

quadtree = require 'simple-quadtree'

# config
_pCFG = 'data/cfg.json'
_CFG = jsonfile.readFileSync(_pCFG)

# user info and preferences - includes guest info - preset players, oauthless
_pUINFO = 'data/uinfo.json'
_UINFO = jsonfile.readFileSync(_pUINFO)

app.use(express.static(__dirname + '/../client'));





_PLAYERS = [] # oauthless player info

_SESID = [] # session ids. Integers only.
_ROOMS = [] # rooms. contains room objects
_NAMES = [] # names. active names.

###
	What contains what:

	Rooms contain {
		Array of Actors [
			Actor {
				type = player
				Player (cloned) {
					Session ID
					Name
					Color / Skin
					Score Data
				}
				3-Vector
				QE 
				Velocity
				Item
				Status (Jailed or not)
			}
		]
		Array of Obstacles [
			Obstacle {
				Vertices [
					3vecs (relative to center)
				]
				3-Vector
				QE
				Velocity
			}
		]
		Array of Items [
			3-Vector
			QE
		]
		Chat [
			Message {
				Text
				Timestamp
				Originating Playername
			}
		]
		Determining function for jail areas, player areas, etc.
		Room ID
	}

###

V = SAT.Vector
C = SAT.Circle

mag = require('vectors/mag') 2
add = require('vectors/add') 2
sub = require('vectors/sub') 2

# generate a salt
pw_mk_salt = ->
	H = '';
	x = (Math.random()+"").slice(2)+(Math.random()+"").slice(2)
	`for (var i = 0; (i+2) < x.length; i++)
		H += String.fromCharCode((9+i) * parseInt(x.slice(i,i+2),16))`
	return H

# combine a password and salt
pwsalt = (pw, s) ->
	s.slice(0, 4) + pw.slice(0, 3) + s.slice(4, 8) + pw.slice(3, 7) + s.slice(8, 12) + pw.slice(7, pw.length) + s.slice(12, s.length)

# generate random color
rand_color = -> '#'+Math.floor(Math.random()*16777215).toString(16);

# not really using this
name_exists = (name) -> _NAMES.indexOf(name) > 0

# make a new account. name: username, pass: password. then hash the password 'n suchly'
# login: compares name and password to userbase things
login = (name, pass) -> 
	# if such a username exists
	# if name_exists name
		## LEAVE FOR OAUTH
		# if password is correct
		# if sha256(pwsalt(pass, _UINFO[name].salt)) is _UINFO[name].hash
			# return [true, "Successful login."]
		# else
			# return [false, "Incorrect password."]
	# no such user exists
	# else
		# if pass.length < 8
			# return [false, "Password must be greater than seven characters."]
		# isalt = pw_mk_salt();
		# _UINFO[name] =
			# salt: isalt
			# hash: sha256(pwsalt(pass, isalt))
			# color: rand_color()
			# skin: false
			# achievements: []
			# wins: 0
			# losses: 0
		# jsonfile.writeFile(_pUINFO, _UINFO, (e)-> console.error(e) if e)
		# return [true, "Account successfully created."]
	

# ON CONNECTION
io.on('connection', (socket) ->
	console.log("CONNECTION RECEIVED FROM ", socket.id);

	# ASSETS ARE VECTOR GRAPHICS
	# client begin spectate room



	## ON LOGIN

		# guest: send guest info

		# login? (OAUTH)
			# user exists? (OAUTH)
				# login:
					# correct? then send info

			# no such user exists?
				# allowed? then make info and send info
				# else "account already exists" & return


	# info was gotten
	# assign to room and push to actives

	# begin game




	## IN GAME

		# get PICKUP.DROP get ACCEL.VEC get QE



	)






# IP CONFIG

ipaddress = process.env.OPENSHIFT_NODEJS_IP or process.env.IP or '127.0.0.1'
serverport = process.env.OPENSHIFT_NODEJS_PORT or process.env.PORT or _CFG.port

if process.env.OPENSHIFT_NODEJS_IP?
    http.listen( serverport, ipaddress, -> console.log('[DEBUG] Listening on *:' + serverport))
else
    http.listen( serverport, -> console.log('[DEBUG] Listening on *:' + _CFG.port))
