playerName = undefined
playerNameInput = document.getElementById('playerNameInput')

socket = undefined
engine = undefined

screenWidth = window.innerWidth
screenHeight = window.innerHeight


canvas = document.getElementById('cvs')

# canvas.width = screenWidth
# canvas.height = screenHeight

KEY_ENTER = 13
game = new Game



scene = undefined



startGame = ->
	playerName = playerNameInput.value.replace(/(<([^>]+)>)/ig, '')
	document.getElementById('gameCanvas').style.display = 'block'
	document.getElementById('startMenuWrapper').style.display = 'none'

	# connection already established in onload. socket = io()
	SetupSocket socket
	socket.emit 'entry_guest', playerName



	engine = new BABYLON.Engine canvas, true

	scene = RSC.TestScene(canvas, engine)
	# animloop()
	engine.runRenderLoop -> scene.render()



	return







# check if nick is valid alphanumeric characters (and underscores)
validNick = ->
	regex = /^\w*$/
	console.log 'Regex Test', regex.exec(playerNameInput.value)
	regex.exec(playerNameInput.value) != null

submitNick = ->
	if validNick()
		startGame()
	else
		nickErrorText.style.display = 'inline'

# when window is done loading
window.onload = ->
	'use strict'
	entry_guest = document.getElementById('entry_guest')
	entry_login = document.getElementById('entry_login')
	nickErrorText = document.querySelector('#startMenu .input-error')

	# connect to server
	socket = io()

	socket.emit 'validate_s', prompt "PLEASE ENTER KEY"
	socket.on 'validate_r', (result) ->
		if result
			alert "ENTRY GRANTED"
		else
			alert "ENTRY DENIED"
			window.location.replace("about:blank");
			return false
			
	# GUEST ENTRY
	entry_guest.onclick = ->
		submitNick()
		return

	# LOGIN ENTRY (OAUTH) - not yet
	# entry_login.onclick = ->
		# socket.emit('entry_login', {name: iname, pass: }) ## HERE

	playerNameInput.addEventListener 'keypress', (e) ->
		key = e.which or e.keyCode
		if key == KEY_ENTER
			submitNick()
		return
	return

SetupSocket = (socket) ->
	game.handleNetwork socket
	return

requestAnimFrame = do ->
	return window.requestAnimationFrame if window.requestAnimationFrame?
	return window.webkitRequestAnimationFrame if window.webkitRequestAnimationFrame?
	return window.mozRequestAnimationFrame if window.mozRequestAnimationFrame?
	return (callback) ->
		window.setTimeout callback, 1000 / 60

# animloop = ->
# 	requestAnimFrame animloop
# 	gameLoop()
# 	return

# gameLoop = ->
# 	game.handleLogic()
# 	game.handleGraphics canvas
# 	return
	
window.addEventListener 'resize', (->
	engine.resize()

	screenWidth = window.innerWidth
	screenHeight = window.innerHeight
	# canvas.width = screenWidth
	# canvas.height = screenHeight

	return
), true