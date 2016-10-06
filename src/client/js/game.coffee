Game = (@canvas) ->

# ...static... fields.
Game::ID = 0
Game::player = undefined
Game::scene = undefined

Game::objects = []
Game::engine = undefined

# Start the dang game
Game::startGame = (objects) ->
	# Engine
	Game::engine = new BABYLON.Engine @canvas, true

	# I need to start using a linter
	retObject = RSC.Game @canvas, Game::engine, objects, Game::ID

	# player
	Game::player = retObject.me

	# Create Scene
	Game::scene = retObject.scene

	# HA HA OH BOY YEP HA HA TIME TO DO ALL THIS RENDERING and also logic
	Game::engine.runRenderLoop @gameLoop

Game::handleNetwork = (socket) ->
	console.log socket
	# Socket whatever

	# closure workaround...
	toStart = this

	socket.on 'roomJoin', (objects, ID) ->
		document.getElementById('textArea').innerHTML = "Joined a game!"
		Game::ID = ID
		console.log "Received this player's id of #{ID}"
		toStart.startGame objects


	return

# Game Loop
Game::gameLoop = ->
	Game::scene.render()
	
	# acquire view vector
	Game::scene.activeCamera # blah

	return