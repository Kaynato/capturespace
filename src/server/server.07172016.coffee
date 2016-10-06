# app / index.Coffee

U = require './lib/util'
FSPH = require './lib/FSPH'
jsonfile = require 'jsonfile'
# sha256 = require 'js-sha256'
express = require 'express'
app = express()
http = require('http').Server app
io = require('socket.io') http

quadtree = require 'simple-quadtree'

# config
_pCFG = 'data/cfg.json'
_CFG = jsonfile.readFileSync(_pCFG)

# user info and preferences - includes guest info - preset players, oauthless
_pUINFO = 'data/uinfo.json'
_UINFO = jsonfile.readFileSync(_pUINFO)

app.use(express.static(__dirname + '/../client'));

Array::remove = (o) ->
	if this.indexOf(o) >= 0 then this.splice this.indexOf(o), 1
	else console.error "Element not in array!"





_PLAYERS = [] # oauthless player info, by ID.

_SESID = [] # session ids. Integers only.
_ROOMS = [] # ACTIVE rooms. contains room objects
_NAMES = [] # names. active names.




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
	player =
		info: playerinfo
		phys: new FSPH.FSphere _CFG.player.mass, _CFG.player.radius
		item: Item.NONE
		jailed: false # whether we are jailed
		team: -1 # unassigned
		room: null
	console.dir player
	return player

# generate a room
gen_room = (iid) ->
	room =
		id: iid
		world: new FSPH.World ->
			# DETERMINING FUNCTION
			
			
			
		# items: [] #GENERATE ITEMS
		chat: []
		# remove player
		excise: (player) ->
			@actors.remove player
			console.log "#{player.info.name} was removed from room #{@id}"
			return


# generate item
gen_item = (itype) ->
	item =
		type: itype
		phys: new FSPH.FSphere _CFG.item.mass, _CFG.item.radius

# initialize a room with players
initroom = (room, players) ->
	# push players into room
	for player in players
		# assign room
		player.room = room
		room.actors.push player
		console.log "added #{player.info.name} to room #{room.id}"
	# distribute position of players
	# spawn flags
	# begin autospawn of items cycle
	# begin timer until match start
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
			# add room to actives
			_ROOMS.push newroom
			return
		# otherwise send some whatever to the client for room wait
		return
		

# ON CONNECTION
io.on('connection', (socket) ->

	console.log("CONNECTION RECEIVED FROM " + socket.id + " @" + 
		socket.request.connection.remoteAddress + " : " +
		socket.request.connection.remotePort);
		# get them to spectate a game

	# unnamed player, suchly
	socket.pinfo = {name: "unnamed player"}

	# a person has JOINED explicitly
	socket.on 'entry_guest', (name) ->
		socket.pinfo = gen_playerinfo socket, name
		socket.player = gen_player socket.pinfo
		# queue 'em into a room
		Queue.queue socket.player

	# on disconnect
	socket.on 'disconnect', ->
		console.log "#{socket.pinfo.name} has left"
		if socket.player?
			# remove from queues
			if socket.player.room is Queue.__queue
				debugger;
				Queue.excise socket.player
				console.log "#{socket.pinfo.name} was removed from queue"
				socket.player.room = null
			# remove from games
			else if socket.player.room?
				socket.player.room.excise(socket.player)
				# broadcast event



	# ASSETS ARE VECTOR GRAPHICS
	# client begin spectate room


	# assign to room and push to actives

	# begin game




	## IN GAME

		# get PICKUP.DROP get ACCEL.VEC get θ



	)






# IP CONFIG

ipaddress = process.env.OPENSHIFT_NODEJS_IP or process.env.IP or '127.0.0.1'
serverport = process.env.OPENSHIFT_NODEJS_PORT or process.env.PORT or _CFG.port

if process.env.OPENSHIFT_NODEJS_IP?
    http.listen( serverport, ipaddress, -> console.log('[DEBUG] Listening on *:' + serverport))
    return
else
    http.listen( serverport, -> console.log('[DEBUG] Listening on *:' + _CFG.port))
    return
