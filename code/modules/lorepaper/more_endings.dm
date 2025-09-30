
/client/proc/end_server()
	set name = "close server"
	set category = "Server"
	if(!holder)
		return
	var/choice = alert("Are you sure you'd like to end the session?", "Confirmation","Yes", "No")
	if(!choice) return
	for(var/client/C in GLOB.clients)
		winset(C, "", "command=.quit")
		//C.Del()
	sleep(10)
	world.Del()

// doesn't actually destroy the server

/client/proc/server_explosion()
	set name = "server explosion"
	set category = "Server"
	set waitfor = 0
	if(!holder)
		return

	var/choice = alert("Are you sure you'd like to end the session?", "Confirmation", "Yes", "No")
	if(choice != "Yes")
		return

	var/obj/screen/cinematic = new
	cinematic.icon = 'icons/effects/serverboom.dmi'
	cinematic.icon_state = ""
	cinematic.plane = HUD_PLANE
	cinematic.layer = HUD_ABOVE_ITEM_LAYER
	cinematic.mouse_opacity = 2
	cinematic.screen_loc = "WEST, SOUTH"

	for(var/client/C in GLOB.clients)
		C.screen += cinematic

	for(var/i = 1, i <= 3, i++)
		cinematic.icon_state = "1"
		sound_to(world, 'sound/effects/klaxon1.ogg')
		sleep(6)
		cinematic.icon_state = "0"
		sleep(6)

	cinematic.icon_state = "2"
	sound_to(world, 'sound/effects/explode_1.ogg')
	sleep(6)
	for(var/client/C in GLOB.clients)
		winset(C, "", "command=.quit")

	sleep(10)
	world.Del()