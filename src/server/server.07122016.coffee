# app / index.Coffee

U = require './lib/util'
jsonfile = require 'jsonfile'
# sha256 = require 'js-sha256'
CANNON = require 'cannon'
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





_PLAYERS = [] # oauthless player info, by ID.

_SESID = [] # session ids. Integers only.
_ROOMS = [] # rooms. contains room objects
_NAMES = [] # names. active names.

###
	What contains what:

###

V = SAT.Vector
C = SAT.Circle

# login: generate player stuff
gen_playerinfo = (socket, iname) ->
	console.log "Generated new playerinfo"
	playerinfo = 
		id: socket.id
		name: iname
		color: U.randColor()
		skin: false
	console.dir playerinfo
	return playerinfo

gen_player = (playerinfo) ->
	console.log "Generated new player from playerinfo"
	player =
		info: playerinfo
		body: new CANNON.Body(_CFG.mass, new CANNON.Sphere(radius))
		QE: 0
		item: 0
		jailed: false
		team: +1
	console.dir player
	return player

# generate a room
gen_room = (iid, num_obstacles) ->
	iworld = new CANNON.World()
	iworld.gravity.set 0, 0, 0
	room =
		id: iid
		world: iworld
		# actors: []
		# obstacles: [] #GENERATE OBSTACLES
		# items: [] #GENERATE ITEMS
		chat: []

gen_obstacle = (num_verts) ->
	obstacle =
		vertices: [] #GENERATE VERTICES
		vec: [0, 0, 0] #RANDOMIZE CENTER VECTOR
		QE: 0
		vel: [0, 0, 0] #VELOCITY?
		angvel: [0,] #euler angles of rotation

gen_item = (gen_func) ->
	item =
		vec: [0, 0, 0] #RANDOMIZE CENTER VECTOR
		QE: 0
		vel: [0, 0, 0] #VELOCITY

# ON CONNECTION
io.on('connection', (socket) ->

	console.log("CONNECTION RECEIVED FROM " + socket.id + " @" + 
		socket.request.connection.remoteAddress + " : " +
		socket.request.connection.remotePort);
		# get them to spectate a game

	# a person has JOINED explicitly
	socket.on 'entry_guest', (name) ->
		gen_player gen_playerinfo socket, name

	# ASSETS ARE VECTOR GRAPHICS
	# client begin spectate room

	## ON LOGIN

		# guest: send guest info

		# login? (OAUTH)
			# make info and send info

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
