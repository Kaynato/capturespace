# Rendering Scene / Gamemode
# Uses BABYLON JS for rendering. Clientside.
RSC = exports ? -> this.RSC = {}

_sph_resolution = 40
_view_radius_default = 10

_team1Lighting = new BABYLON.Color3 1, 0, 0
_team2Lighting = new BABYLON.Color3 0, 0, 1

# NEW GAME
# params:
#
#  canvas: to draw on
#  engine: needed for setup
#  objects: received from server
#  ID: received from server. used to identify this player from players in objects
#  
# returns an object:
#
#   scene: to render
#   player: this player. needed for control nonsense
#
RSC.Game = (canvas, engine, objects, ID) ->
	console.log "Setting up game..."
	# console.log "Player's ID is [ #{ID} ]"

	# Setup scene
	scene = new BABYLON.Scene engine
	scene.clearColor = new BABYLON.Color3 0, 0, 0


	# Add the everything from the objects
	# aw heck
	@me = null
	@shell = null
	@players = []

	setup_position = (pos, coord) ->
		pos.x = coord[0]
		pos.y = coord[1]
		pos.z = coord[2]

	for object in objects
		switch object.name
			when "shell"
				# you wouldn't download a shell...
				ns = BABYLON.Mesh.CreateSphere "shell", _sph_resolution, object.radius*2, scene, false, BABYLON.Mesh.DOUBLESIDE

				# shell material
				nmat = new BABYLON.StandardMaterial "smat", scene
				ncol = new BABYLON.Color3(0.2, 0.2, 0.2)
				nmat.ambientColor = ncol
				nmat.diffuseColor = ncol
				nmat.emissiveColor = new BABYLON.Color3(0.1, 0.1, 0.1)
				nmat.specularColor = new BABYLON.Color3(0, 0, 0)

				ns.material = nmat
				
				console.log "shell of radius #{object.radius} created"
				setup_position ns.position, object.position
				# establish ref
				@shell = ns


			when "player"
				console.log "Received player ID [ #{object.id} ]"
				# you wouldn't download... a human being...!
				np = BABYLON.Mesh.CreateSphere object.info.name, _sph_resolution, object.radius*2, scene
				setup_position np.position, object.position
				
				# making the color thing
				nmat = new BABYLON.StandardMaterial "pmat", scene

				console.log "Player info:"
				console.dir object

				hexc = object.info.color
				ncol = new BABYLON.Color3(
					((hexc&0xFF0000)>>16)/255, 
					((hexc&0x00FF00)>>8 )/255,
					 (hexc&0x0000FF)     /255)
				nmat.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1)
				nmat.diffuseColor = new BABYLON.Color3(0.1, 0.1, 0.1)
				nmat.ambientColor = ncol
				np.material = nmat

				# if this is the thing we are the thing which to look for
				# that is, if this player is our player
				if object.id is ID
					# camera...
					ini_campos = new BABYLON.Vector3(
						object.position[0],
						object.position[1],
						object.position[2] + 10*Math.sign(object.position[2])
						)
					# starts behind the player, facing to the other side
					# establish callback, and also for return
					@me = np

				# establish ref
				@players.push np

	# Well, you obviously need lighting
	light1Dir = new BABYLON.Vector3 0, 0,+1
	light1 = new BABYLON.HemisphericLight "teamA", light1Dir, scene
	light1.intensity = .5
	light1.diffuse = _team1Lighting

	light2Dir = new BABYLON.Vector3 0, 0,-1
	light2 = new BABYLON.HemisphericLight "teamB", light2Dir, scene
	light2.intensity = .5
	light2.diffuse = _team2Lighting

	# Colors
	scene.ambientColor = new BABYLON.Color3(1, 1, 1)

	# Setup orthocamera pointed towards sprite
	camera = new BABYLON.FreeCamera "playercam", ini_campos, scene

	# attach camera
	scene.activeCamera = camera

	# ATTACH CONTROL
	camera.attachControl canvas, false

	# look at player
	camtgt = @me.position.clone()
	camera.setTarget camtgt

	gravityVector = new BABYLON.Vector3(0, 0, 0)
	physicsPlugin = new BABYLON.CannonJSPlugin()
	scene.enablePhysics gravityVector, physicsPlugin

	return {scene: scene, me: @me}
	