// =========================
// GLOBAL PROCS
// =========================

/proc/end_server_global()
	set waitfor = 0

	for(var/client/C in GLOB.clients)
		if(C.holder)
			continue
		winset(C, "", "command=.quit")

	sleep(10)
	world.Del()


/proc/server_explosion_global()
	set waitfor = 0

	var/obj/screen/cinematic = new
	cinematic.icon = 'icons/effects/serverboom.dmi'
	cinematic.icon_state = ""
	cinematic.plane = HUD_PLANE
	cinematic.layer = HUD_ABOVE_ITEM_LAYER
	cinematic.mouse_opacity = 2
	cinematic.screen_loc = "WEST, SOUTH"

	for(var/client/C in GLOB.clients)
		C.screen += cinematic

	sleep(10) // just to sync it, it had issues last time I used it

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
		if(C.holder)
			continue
		winset(C, "", "command=.quit")

	sleep(6)
	world.Del()


// =========================
// 		CLIENT PROCS
// =========================

/client/proc/end_server()
	set name = "close server"
	set category = "Server"
	set waitfor = 0
	if(!holder)
		return

	var/choice = alert("Are you sure you'd like to end the session?", "Confirmation", "Yes", "No")
	if(choice == "Yes")
		end_server_global()


/client/proc/server_explosion()
	set name = "server explosion"
	set category = "Server"
	set waitfor = 0
	if(!holder)
		return

	var/choice = alert("Are you sure you'd like to end the session?", "Confirmation", "Yes", "No")
	if(choice == "Yes")
		server_explosion_global()


/obj/machinery/button/server_explode_button
	name = "\the button that ends all that exists- and shall exist"
	desc = "This is no creation of man."

/obj/machinery/button/server_explode_button/activate(mob/living/user)
	active = !active
	update_icon()
	server_explosion_global()