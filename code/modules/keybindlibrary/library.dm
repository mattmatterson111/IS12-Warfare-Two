/* ------- THIS FILE IS FOR OBJECTS THAT INTERACT WITH KEYPRESSES OR SCROLLWHEEL STUFF, I WANT TO DIE ----- */

/atom/proc/keyPress(key as text, mob/user)
	return

/client/verb/keyPress(key as text)
	set instant = 1
	set hidden = 1
	if(!src.mob)
		return
	//to_chat(usr, "[ckey] -[key] down") //(DEBUG)
	// for writing stuff
	if(key in list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9", "Numpad0")) // for number stuff // TODO: Add numpad support.
	/*	switch(key)
			if("Numpad0") key = "0"
			if("Numpad1") key = "1"
			if("Numpad2") key = "2"
			if("Numpad3") key = "3"
			if("Numpad4") key = "4"
			if("Numpad5") key = "5"
			if("Numpad6") key = "6"
			if("Numpad7") key = "7"
			if("Numpad8") key = "8"
			if("Numpad9") key = "9" */
		var/atom/A = mob.get_active_hand()
		if(A)
			if(A.keyPress(null, mob)) // for items we hold
				A.keyPress(key, mob)
				return TRUE
		for(var/atom/C in view(1, mob))
			if(isworld(C.loc)) // somehow??
				if(C.keyPress(null, mob))
					C.keyPress(key, mob)
					return TRUE
			continue
		switch(key) // AUGH
			if("1")
				usr.a_intent_change(I_HELP)
				return
			if("2")
				usr.a_intent_change(I_DISARM)
				return
			if("3")
				usr.a_intent_change(I_GRAB)
				return
			if("4")
				usr.a_intent_change(I_HURT)
				return
			/* // Was used for debugging
			if(istype(I, /obj/item))
				I.showoff(src.mob)
				return
			*/
	//	keyRelease(key as text) // TO-DO, figure out how to make it so we can check if we're holding shif whilst typing! ^v^
	//		set instant = 1, hidden = 1
			//to_chat(usr, "[ckey] -[key] up") //(DEBUG)

// NOTE: RADIO USES A ATOM PROC!! HENCE WHY ITS NOT HERE!!