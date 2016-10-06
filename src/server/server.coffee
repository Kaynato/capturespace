# NODE COFFEE
# app / index.Coffee

# Just your usual 3d

U = require './lib/util'
CANNON = require 'cannon'
jsonfile = require 'jsonfile'

express = require 'express'
app = express()

http = require('http').Server app
io = require('socket.io') http

TIMESTEP = 1.0 / 60.0 # 60FPS

# config
_pCFG = 'data/cfg.json'
_CFG = jsonfile.readFileSync(_pCFG)

# user info and preferences - includes guest info - preset players, oauthless
_pUINFO = 'data/uinfo.json'
_UINFO = jsonfile.readFileSync(_pUINFO)



configCheck = ->
	# config check for validity
	_INVLD_CFG = (cause) -> throw new Error "CONFIG INVALID: #{cause}"

	# To be fair, I should probably line these in an array and perform a
	# triangular comparison. But honestly this is already here, so whatever
	if _CFG.room.PSIDES > _CFG.room.radius
		_INVLD_CFG "Sides intersect center!"

	if _CFG.room.PSPAWN > _CFG.room.radius
		_INVLD_CFG "Spawn planes intersect center!"
	if _CFG.room.PSPAWN > _CFG.room.PSIDES
		_INVLD_CFG "Players will spawn in neutral ground!"

	if _CFG.room.PJAILS > _CFG.room.radius
		_INVLD_CFG "Jail planes intersect center!"
	if _CFG.room.PJAILS > _CFG.room.PSIDES
		_INVLD_CFG "Jail planes enter neutral ground!"
	if _CFG.room.PJAILS > _CFG.room.PSPAWN
		_INVLD_CFG "Players will spawn behind jail planes!"





# Setup express
app.use(express.static(__dirname + '/../client'));

# Easy does it, the removing
Array::remove = (o) ->
	if this.indexOf(o) >= 0 then this.splice this.indexOf(o), 1
	else console.error "Element not in array!"



# Active player data
_PLAYERS = [] # oauthless player info, by ID.

_ROOMS = [] # ACTIVE rooms. contains room objects




Item =
	NONE: 0

	BOOST: 5

	RUBBER: 10
	BLOCK: 11

	STEALTH: 15

	WEIGHT: 21
	FEATHER: 22

	FLAG: 20

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
	ishape = new CANNON.Sphere _CFG.player.radius
	ibody = new CANNON.Body _CFG.player.mass, ishape
	ibody.position.set 0, 0, 0
	player =
		info: playerinfo
		body: ibody
		item: Item.NONE
		jailed: false # whether we are jailed
		team: -1 # unassigned
		room: null
	return player

# generate a room
gen_room = (iid) ->
	iworld = new CANNON.World()
	iworld.gravity.set 0, 0, 0
	iworld.broadphase = new CANNON.NaiveBroadphase()
	room =
		id: iid
		players: []
		world: iworld
		# items: [] #GENERATE ITEMS
		chat: []
		# remove player
		excise: (player) ->
			@players.remove player
			@world.removeBody player.body
			console.log "#{player.info.name} was removed from room #{@id}"
			return
		# get set timer
		getset: (T, time) ->
			if time is 0
				T.start()
			else
				console.log "room #{T.id}: T-#{time}"
				# don't worry about IE compat because this is nodeJS, haha
				setTimeout T.getset, 1000, T, (time-1)|0
		# push to actives
		start: ->
			_ROOMS.push this
			console.log "room #{@id} started"
		# remove from actives
		stop: ->
			_ROOMS.remove this
			console.log "room #{@id} stopped"

# generate item
gen_item = (itype) ->
	ishape = new CANNON.Sphere _CFG.item.radius
	ibody = new CANNON.Body _CFG.item.mass, ishape
	ibody.position.set 0, 0, 0
	item =
		type: itype
		body: ibody

# initialize a room with players
initroom = (room, players) ->

	# THIS WILL BE SENT TO ALL PLAYERS
	objects = []

	# create spherical shell
	shellShape = new CANNON.Sphere _CFG.room.radius
	shellBody = new CANNON.Body 0, shellShape
	shellBody.position.set 0, 0, 0
	room.world.addBody shellBody

	objects.push
		name: "shell"
		radius: _CFG.room.radius
		mass: 0
		position: [0, 0, 0]

	# get positions. This is an array.
	coords = U.playerCoords _CFG.room

	# push players into room
	# index match to coords.
	`for (var i = 0; i < players.length; i++) {
		var player = players[i];

		// distribute position of players
		player.body.position.set(coords[i][0],coords[i][1],coords[i][2]);
		console.log(player.info.name+" coords@ "+player.body.position);

		// assign room
		player.room = room;
		room.world.addBody(player.body);
		room.players.push(player);
		console.log("added "+player.info.name+" to room "+room.id);

		// add player to objects array
		objects.push({
			name: "player",
			info: player.info,
			team: player.team,
			id: player.socket.id,
			radius: _CFG.player.radius,
			mass: _CFG.player.mass,
			position: coords[i]
			});
	}`

	# spawn flags
	# begin autospawn of items cycle

	# setup is done!

	# send the dang things now
	for player in players
		player.socket.emit 'roomJoin', objects, player.socket.id

	
	# begin timer until match start
	room.getset room, 5
	return

# Room queue. When 6 players enter, begin
Queue =
	__queue: []

	excise: (player) ->
		prevlength = @__queue.length
		@__queue.remove player
		if prevlength > @__queue.length
			console.log "player successfully removed"
		else
			console.log "error: player not removed"

	queue: (player) ->
		newroom
		# brevity reference
		t = _CFG.room.teams
		# assign team
		player.team = @__queue.length%t
		# add player to room
		@__queue.push player
		# put backreference
		player.room = @__queue
		console.log "added #{player.info.name} to queue"
		console.log "#{@__queue.length} players in queue"
		# when it's full, make room with ROOMS.length id
		if @__queue.length is _CFG.room.playersPerTeam * t
			newroom = gen_room _ROOMS.length
			initroom newroom, @__queue
			# reset lineup
			@__queue = []
			return
		# otherwise send some whatever to the client for room wait
		return

# GLOBAL TIMER
DUTYTIMER = 0

# DUTYCYCLE	RUNS THE GAME LOOP
DUTYCYCLE = ->
	DUTYTIMER++
	DUTYTIMER%=60
	# Physics step everything
	for aroom in _ROOMS
		aroom.world.step TIMESTEP
		# if DUTYTIMER is 0
			# console.log "#{aroom.id} tick"

# ON CONNECTION
io.on('connection', (socket) ->

	socket.AUTH = true

	console.log("CONNECTION RECEIVED FROM " + socket.id + " @" + 
		socket.request.connection.remoteAddress + " : " +
		socket.request.connection.remotePort);
		# get them to spectate a game

	# unnamed player, suchly
	socket.pinfo = {name: "unnamed player"}

	# AUTHENTICATION (tester key)
	socket.on 'validate_s', (key) ->
		result = U.validate key, _CFG.pass.hash, _CFG.pass.salt
		socket.AUTH = result
		socket.emit 'validate_r', result

	# a person has JOINED explicitly
	socket.on 'entry_guest', (name) ->
		return false if !socket.AUTH
		socket.pinfo = gen_playerinfo socket, name
		socket.player = gen_player socket.pinfo
		socket.player.socket = socket
		_PLAYERS.push socket.player
		# queue 'em into a room
		Queue.queue socket.player

	# on disconnect
	socket.on 'disconnect', ->
		if socket.player?
			_PLAYERS.remove socket.player
			console.log "#{socket.pinfo.name} has left"
			# remove from queues
			if socket.player.room is Queue.__queue
				debugger;
				Queue.excise socket.player
				console.log "#{socket.pinfo.name} was removed from queue"
				socket.player.room = null
			# remove from games
			else if socket.player.room?
				socket.player.room.excise socket.player
				# broadcast event



	# ASSETS ARE VECTOR GRAPHICS
	# client begin spectate room


	# assign to room and push to actives

	# begin game




	## IN GAME

		# get PICKUP.DROP get ACCEL.VEC get θ



	)


# _CFG.pass.hash = U.TESTKEY()
# jsonfile.writeFileSync(_pCFG, _CFG);

# Begin Game loop
GAMELOOP = setInterval DUTYCYCLE, TIMESTEP

# IP CONFIG

ipaddress = process.env.OPENSHIFT_NODEJS_IP or process.env.IP or '127.0.0.1'
serverport = process.env.OPENSHIFT_NODEJS_PORT or process.env.PORT or _CFG.port

if process.env.OPENSHIFT_NODEJS_IP?
    http.listen( serverport, ipaddress, -> console.log('[DEBUG] Listening on *:' + serverport))
    return
else
    http.listen( serverport, -> console.log('[DEBUG] Listening on *:' + _CFG.port))
    return
