/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = ITEM_SIZE_SMALL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	worldicons = list("megaphone_world")

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")
	var/message_color = "#f8eedd"
// /obj/item/device/megaphone/attack_self(mob/living/user as mob)
// 	if (user.client)
// 		if(user.client.prefs.muted & MUTE_IC)
// 			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
// 			return
// 	if(user.silent)
// 		return
// 	if(spamcheck)
// 		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
// 		return

// 	var/message = sanitize(input(user, "Shout a message?", "Megaphone", null)  as text)
// 	if(!message)
// 		return
// 	message = capitalize(message)
// 	if ((src.loc == user && usr.stat == 0))
// 		if(emagged)
// 			if(insults)
// 				for(var/mob/O in (viewers(user)))
// 					O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>",2) // 2 stands for hearable message
// 				insults--
// 			else
// 				to_chat(user, "<span class='warning'>*BZZZZzzzzzt*</span>")
// 		else
// 			for(var/mob/O in (viewers(user)))
// 				O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2) // 2 stands for hearable message

// 		spamcheck = 1
// 		spawn(20)
// 			spamcheck = 0
// 		return

/obj/item/device/megaphone/attack_self(mob/living/user as mob)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
	if(user.silent)
		return
	if(spamcheck)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		return

	var/message = sanitize(input(user, "Shout a message?", "Megaphone", null)  as text)
	var/datum/language/lang

	if(!message)
		return

	lang = user.parse_language(message)
	if(lang)
		message = copytext_char(message, 2 + length_char(lang.key))
	else
		lang = user.get_default_language()

	if(lang.flags & (NONVERBAL | SIGNLANG))
		to_chat(user, SPAN_WARNING("You can't use sign language!"))
		return

	message = trim_left(message)
	message = capitalize(message)
	var/list/rec = list()
	if ((src.loc == user && usr.stat == 0))
		if(emagged)
			if(insults)
				var/picked = pick(insultmsg)
				for(var/mob/O in (viewers(user)))
					//O.hear_say(picked, "broadcasts", lang, null, 0, user, null, null, 6)

					if(O.client)
						rec |= O.client

				INVOKE_ASYNC(user, /atom/movable/proc/animate_chat, picked, lang, 0, rec, 5 SECONDS, 1)
				insults--
			else
				to_chat(user, "<span class='warning'>*BZZZZzzzzzt*</span>")
		else
			var/ending = copytext(message, -1)
			if(!(ending in PUNCTUATION))
				message = "[message]."

			message = replacetext(message, "/", "")
			message = replacetext(message, "~", "")
			message = replacetext(message, "@", "")
			message = replacetext(message, " i ", " I ")
			message = replacetext(message, " ive ", " I've ")
			message = replacetext(message, " im ", " I'm ")
			message = replacetext(message, " u ", " you ")

			for(var/mob/O in (viewers(world.view + 6, user))) // idea: increase the range of the sounda nd the rnage of this in general?
				if(!O.stat == UNCONSCIOUS || !O.is_deaf() || !O.stat == DEAD) // such a hacky way of doing this.
					//O.hear_say(message, "broadcasts", lang, null, 0, user, null, null, 6)
					to_chat(O,FONT_LARGE("<span class='warning'><font color='[message_color]'>[user] broadcasts,</font>\n[FONT_GIANT("<span class='danger' style='text-shadow: 0 0 7px #[message_color];'><font color='[message_color]'>\"[message]\"</font></span></span>")]"))
					if(O.client)
						rec |= O.client
			//soundoverlay(user, newplane = EFFECTS_ABOVE_LIGHTING_PLANE)
			playsound(src,"loudspeaker",100,0)
			//playsound(src,'sound/effects/broadcasttest.ogg',75,0)
			INVOKE_ASYNC(user, /atom/movable/proc/animate_chat, "<fon	t size='3' color='[message_color]'><b>[message]", lang, 0, rec, 5 SECONDS, 1)

		spamcheck = 1
		spawn(30) // 3 second cooldown seams reasonable
			spamcheck = 0
		return

/obj/item/device/megaphone/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return 1
