/datum/terminal_page_controller
	var/obj/machinery/kaos/holder
	var/datum/terminal_page/current_page
	var/list/pages = list() // Holds all page datums

/datum/terminal_page_controller/proc/load_first()
	to_chat(world,"PICKING PAGE")
	var/datum/terminal_page/page = pages[1] // meant to be the FIRST one in the pages list. // ALWAYS NULL FOR SOME REASON?
	to_chat(world,"LOADING")
	load_page(page)
	to_chat(world,"LOADING GOOD")

/datum/terminal_page_controller/proc/load_page(var/datum/terminal_page/page)
	current_page = page
	current_page.load()

/datum/terminal_page_controller/proc/string_to_page(var/string)
	if(current_page)
		current_page.receive_string(string)

/datum/terminal_page_controller/proc/populate_pages()
	var/list/temp = list()
	for(var/A in pages)//Populate pages list.
		var/datum/terminal_page/page = new A
		page.holder = src
		temp += page
	if(!temp.len)//If there's nothing there afterwards return.
		return FALSE
	pages = temp
	return TRUE

/datum/terminal_page_controller/New()
	. = ..()
	populate_pages(pages)

/datum/terminal_page
	var/list/available_pages = list() // Pages accessible from this page
	var/datum/terminal_page_controller/holder

	// This proc toggles input and refreshes the display
/datum/terminal_page/proc/toggle_input(delay, sound)
	spawn(delay)
		holder.holder.input = !holder.holder.input
		holder.holder.refresh_page()
		if(sound)
			playsound(holder.holder.loc, 'sound/effects/computer/floppy_access.ogg', 100, 1)

/datum/terminal_page/proc/add_line(string, delay, sound)
	spawn(delay)
		holder.holder.t += string
		holder.holder.refresh_page()
		if(sound)
			playsound(holder.holder.loc, 'sound/effects/computer/floppy_access.ogg', 100, 1)

/datum/terminal_page/proc/clear_screen(delay, sound)
	spawn(delay)
		holder.holder.t = null
		holder.holder.input = FALSE
		holder.holder.refresh_page()
		if(sound)
			playsound(holder.holder.loc, 'sound/effects/computer/floppy_access.ogg', 100, 1)

/datum/terminal_page/proc/receive_string(var/string)
	// Checks if the string input matches any codes in available_pages
	for(var/entry in available_pages)
		if(entry["code"] == string)
			// Switches to the new page if a match is found
			holder.load_page(entry["datum"])
			return
	// If no match, add a line indicating invalid input
	add_line("Invalid command: [string]", 0, 'sound/effects/computer/floppy_access.ogg')

/datum/terminal_page/proc/load()
	// This is called when the page is loaded, can set up the page here
	clear_screen(0, 'sound/effects/computer/floppy_access.ogg')
	add_line("Page loaded.", 25, 'sound/effects/computer/floppy_access.ogg')
	return TRUE

/datum/terminal_page/proc/refresh()
	holder.holder.refresh_page()
	return TRUE

/datum/terminal_page_controller/test_controller
	pages = list(/datum/terminal_page/test1, /datum/terminal_page/test2, /datum/terminal_page/test3)

/obj/machinery/kaos
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_machine"
	var/is_bordered = FALSE
	var/t
	var/input = FALSE
	var/input_link
	var/powered = FALSE
	var/datum/terminal_page_controller/test_controller/controller

/obj/machinery/kaos/New()
	. = ..()
	input_link = "<form name='input_form' action='?src=\ref[src]' method='get'><input type='hidden' name='src' value='\ref[src]'><input type='hidden' name='choice' value='string_input'><input type='text' id='string' name='string' style='width:100%; background-color:black; color:#d49e00'><input type='submit' value='submit'></form><br>"
	controller = new
	controller.holder = src

/obj/machinery/kaos/RightClick(mob/user)
	. = ..()
	powered = !powered
	show_page(user)
	switch(powered)
		if(TRUE) power_on(user)
		else power_off(user)

/obj/machinery/kaos/attack_hand(mob/user)
	. = ..()
	if(!powered)
		return
	show_page(user)

/obj/machinery/kaos/proc/load_page(datum/terminal_page/page)
	controller.load_page(page)
	return TRUE

/obj/machinery/kaos/proc/refresh_page()
	var/href_list = params2list("src=\ref[src]&refresh=1")
	src.Topic("src=\ref[src];refresh=1", href_list)

/obj/machinery/kaos/proc/toggle_input(delay, sound)
	input = !input
	refresh_page()
	if(sound)
		playsound(src.loc, sound, 100, 1)
	sleep(delay)

/obj/machinery/kaos/proc/add_line(string, delay, sound)
	t += string
	refresh_page()
	if(sound)
		playsound(src.loc, sound, 100, 1)
	sleep(delay)

/obj/machinery/kaos/proc/clear_screen(delay, sound)
	t = null
	input = FALSE
	refresh_page()
	if(sound)
		playsound(src.loc, sound, 100, 1)
	sleep(delay)

/obj/machinery/kaos/proc/pass_string(var/string)
	controller.string_to_page(string)
	refresh_page()

/obj/machinery/kaos/proc/show_page(mob/user)
	user << browse("<HTML><HEAD><TITLE>[name]</TITLE><style>hr{background-color: #d49e00; border-color: #d49e00;} body{scrollbar-color: #d49e00 #FFBF00;}</style></HEAD><BODY bgcolor='black' style='color: #FFBF00;'><a onfocus ='this.blur()' href='byond://?src=\ref[src];toggletitle=1'>X</a></p><p>[t]</p>[input ? input_link : null]</BODY></HTML>", "window=[name];can_close=1;can_resize=1;width=1800;height=1400border=[is_bordered];titlebar=[is_bordered]")

/obj/machinery/kaos/proc/power_on(mob/user)
	playsound(src.loc,'sound/effects/computer/bootup.ogg',100,1)
	show_page()
	add_line("<center>...",10,'sound/effects/computer/floppy_access.ogg')
	add_line(" . . .",20,'sound/effects/computer/floppy_access.ogg')
	add_line("  .  .  .",30,'sound/effects/computer/floppy_access.ogg')
	add_line("-WELCOME TO",20,'sound/effects/computer/floppy_access.ogg')
	add_line("CARMINE OS-",10,'sound/effects/computer/floppy_access.ogg')
	add_line("  .  .  .",30,'sound/effects/computer/floppy_access.ogg')
	add_line(" . . .",20,'sound/effects/computer/floppy_access.ogg')
	add_line("...</center>",10,'sound/effects/computer/floppy_access.ogg')
	add_line("<hr>",25,'sound/effects/computer/floppy_access.ogg')
	clear_screen(10, 'sound/effects/computer/floppy_access.ogg')
	controller.load_first()

/obj/machinery/kaos/proc/power_off(mob/user)

/obj/machinery/kaos/Topic(href, href_list)
	. = ..()
	if(!usr || (usr.stat || usr.restrained()) || !Adjacent(usr))
		return
	if(href_list["choice"])
		switch(href_list["choice"])
			if("string_input")
				pass_string(href_list["string"])
	else if(href_list["toggletitle"])
		is_bordered = !is_bordered
		usr << browse(null, "window=[name]")
	else if(href_list["refresh"])
		show_page(usr)
		return TOPIC_REFRESH
	show_page(usr)
	return TOPIC_REFRESH



/datum/terminal_page/test1
	available_pages = list(
		list("code" = "1", "datum" = /datum/terminal_page/test2, "name" = "SECOND PAGE"),
		list("code" = "2", "datum" = /datum/terminal_page/test3, "name" = "THIRD PAGE")
	)

/datum/terminal_page/test1/load()
	add_line("[type]", 25, 'sound/effects/computer/floppy_access.ogg')
	for(var/entry in available_pages)
		add_line("[entry["code"]] - [entry["name"]]", 25, 'sound/effects/computer/floppy_access.ogg')
	toggle_input(50, 'sound/effects/computer/floppy_access.ogg')

/datum/terminal_page/test2
	available_pages = list(
		list("code" = "1", "datum" = /datum/terminal_page/test1, "name" = "FIRST PAGE"),
		list("code" = "2", "datum" = /datum/terminal_page/test3, "name" = "THIRD PAGE")
	)

/datum/terminal_page/test2/load()
	add_line("[type]", 25, 'sound/effects/computer/floppy_access.ogg')
	for(var/entry in available_pages)
		add_line("[entry["code"]] - [entry["name"]]", 25, 'sound/effects/computer/floppy_access.ogg')
	toggle_input(50, 'sound/effects/computer/floppy_access.ogg')

/datum/terminal_page/test3
	available_pages = list(
		list("code" = "1", "datum" = /datum/terminal_page/test1, "name" = "FIRST PAGE"),
		list("code" = "2", "datum" = /datum/terminal_page/test2, "name" = "SECOND PAGE")
	)

/datum/terminal_page/test3/load()
	add_line("[type]", 25, 'sound/effects/computer/floppy_access.ogg')
	for(var/entry in available_pages)
		add_line("[entry["code"]] - [entry["name"]]", 25, 'sound/effects/computer/floppy_access.ogg')
	toggle_input(50, 'sound/effects/computer/floppy_access.ogg')

/obj/machinery/kaos/test_terminal
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_machine"
	powered = FALSE