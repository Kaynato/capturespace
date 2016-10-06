playerName = undefined
playerNameInput = document.getElementById('playerNameInput')

socket = undefined
engine = undefined


canvas = document.getElementById('cvs')


KEY_ENTER = 13
game = new Game canvas



# check if nick is valid alphanumeric characters (and underscores)
validNick = ->
	regex = /^\w*$/
	console.log 'Regex Test', regex.exec(playerNameInput.value)
	regex.exec(playerNameInput.value) != null

# Submit the nickname to the server and wait to join a game
submitNick = ->
	if validNick()
		playerName = playerNameInput.value.replace(/(<([^>]+)>)/ig, '')
		document.getElementById('gameCanvas').style.display = 'block'
		document.getElementById('startMenuWrapper').style.display = 'none'
		document.getElementById('textArea').innerHTML = "Waiting to join game..."

		# connection already established in onload. socket = io()
		SetupSocket socket
		socket.emit 'entry_guest', playerName
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

	# socket.emit 'validate_s', prompt "PLEASE ENTER KEY"

	socket.on 'validate_r', (result) ->
		if result
			alert "ENTRY GRANTED"
		else
			alert "ENTRY DENIED"
			window.location.replace("about:blank");
			return false

	entry_guest.onclick = ->
		submitNick()

	playerNameInput.addEventListener 'keypress', (e) ->
		key = e.which or e.keyCode
		if key is KEY_ENTER
			submitNick()
		return
	return

SetupSocket = (socket) ->
	game.handleNetwork socket
	return

window.addEventListener 'resize', (->
	engine.resize()
	return
), true