/obj/structure/announcementmicrophone
	name = "captain's microphone"
	desc = "Should work right as rain.."
	icon = 'icons/obj/device.dmi'
	icon_state = "mic"
	anchored = TRUE
	var/id = 0 // This is for the ID system, it allows us to have multiple of these in a map.
	// IMPORTANT VARS GO UP HERE ^^

	var/broadcast_start_sound = 'sound/effects/broadcasttest.ogg'
	var/broadcast_start_sound_volume = 50

	var/broadcast_end_sound = 'sound/effects/broadcasttestend.ogg' //"feedbacknoise"
	var/broadcast_end_sound_volume = 50

	var/list/additional_talk_sound = list('sound/effects/red_loudspeaker_01.ogg','sound/effects/red_loudspeaker_02.ogg','sound/effects/red_loudspeaker_03.ogg','sound/effects/red_loudspeaker_04.ogg','sound/effects/red_loudspeaker_05.ogg','sound/effects/red_loudspeaker_06.ogg')//list('sound/effects/megaphone_03.ogg','sound/effects/megaphone_04.ogg')
	var/additional_talk_sound_vary = 0
	var/additional_talk_sound_volume = 75

	var/rune_color = "#f5d0a6"

	var/speakerstyle = "boldannounce" // h3 + warning makes it CURLY (disco freaky) :>
	var/textstyle = "staffwarn"

	var/broadcasting  = FALSE
	var/listening = FALSE
	var/broadcast_range = 8

	var/cooldown // Cooldown for inputs

/obj/structure/announcementmicrophone/attack_hand(mob/user)
	. = ..()
	if(!cooldown)
		if(!broadcasting)
			broadcasting = TRUE
			listening = TRUE
			set_cooldown(6 SECONDS)
			for(var/obj/structure/announcementspeaker/s in world)
				if(id == s.id)
					soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
					playsound(s.loc, broadcast_start_sound, broadcast_start_sound_volume, 0)
					//s.overlays += image('icons/obj/structures.dmi', icon_state = "rpfsafe") // call a proc on the speakers in the future to update icon?
					// dunno if we wanna make it update icon at all

		else
			broadcasting = FALSE
			listening = FALSE
			set_cooldown(20 SECONDS)
			for(var/obj/structure/announcementspeaker/s in world)
				if(id == s.id)
					playsound(s.loc, broadcast_end_sound, broadcast_end_sound_volume, 0)
					s.overlays.Cut()
					soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
		playsound(src.loc, "button", 75, 1)
	update_icon()

/obj/structure/announcementmicrophone/RightClick(mob/user)
	. = ..()
	if(broadcasting)
		if(listening)
			listening = FALSE
		else
			listening = TRUE
		playsound(src.loc, "button", 75, 1)
		update_icon()

/obj/structure/announcementmicrophone/hear_talk(mob/living/M as mob, msg, var/verb="says", datum/language/speaking=null)
	if(broadcasting)
		if(listening)
			if(M in range(2, get_turf(src)))
				var/ending = copytext(msg, -1)
				if(!(ending in PUNCTUATION))
					msg = "[msg]."

				msg = replacetext(msg, "/", "")
				msg = replacetext(msg, "~", "")
				msg = replacetext(msg, "@", "")
				msg = replacetext(msg, " i ", " I ")
				msg = replacetext(msg, " ive ", " I've ")
				msg = replacetext(msg, " im ", " I'm ")
				msg = replacetext(msg, " u ", " you ")
				msg = add_shout_append(capitalize(msg))//So that if they end in an ! it gets bolded
				var/spkrname = ageAndGender2Desc(M.age, M.gender)
				msg = replace_characters(msg, list("&#34;" = "\""))
				transmitmessage(M.GetVoice(), msg, verb)
/*
/obj/structure/announcementmicrophone/see_emote(mob/M as mob, text, var/emote_type)
	if(broadcasting)
		if(listening)
			if(emote_type != AUDIBLE_MESSAGE)
				return
			if(M in range(2, get_turf(src)))
				var/start_pos = findtext(text, "</B>") + length("</B>")
				var/output = copytext(text, start_pos)
				output = trim(output)
				var/spkrname = ageAndGender2Desc(M.age, M.gender)
				transmitemote(spkrname, output)
				return // Not sure how to fix it. Right now it spits out this: Young Woman <B>Arb. Mcintosh Willey</B> screams!
			else
				return
*/
/obj/structure/announcementmicrophone/proc/transmitmessage(spkrname, msg, var/verbtxt)
	var/list/mobstosendto = list()
	var/list/clients = list()
	var/this_sound = null
	if(additional_talk_sound)
		this_sound = pick(shuffle(additional_talk_sound))
	for(var/obj/structure/announcementspeaker/s in world)
		if(id == s.id)
			for(var/mob/living/carbon/m in view(world.view + broadcast_range, get_turf(s)))
				if(!m.stat == UNCONSCIOUS || !m.is_deaf() || !m.stat == DEAD)
					mobstosendto |= m
					soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
					if(m.client)
						clients |= m.client
			// it got annoying REALLY FAST having them all being different..
			playsound(get_turf(s),this_sound , additional_talk_sound_volume, additional_talk_sound_vary, ignore_walls = FALSE, extrarange = 4)
			INVOKE_ASYNC(s, /atom/movable/proc/animate_chat, "<font color='[rune_color]'><b>[msg]", null, 0, clients, 5 SECONDS, 1)
	for(var/mob/living/carbon/m in mobstosendto)
		to_chat(m,"<h2><span class='[speakerstyle]'>[spkrname] [verbtxt], \"<span class='[textstyle]'>[msg]</span>\"</span></h2>")

/obj/structure/announcementmicrophone/proc/transmitemote(spkrname, emote)
	var/list/mobstosendto = list()
	for(var/obj/structure/announcementspeaker/s in world)
		if(id == s.id)
			for(var/mob/living/carbon/m in view(world.view + broadcast_range, get_turf(s)))
				if(!m.stat == UNCONSCIOUS || !m.is_deaf() || !m.stat == DEAD)
					mobstosendto |= m
					soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
	for(var/mob/living/carbon/m in mobstosendto)
		to_chat(m,"<h2><span class='[speakerstyle]'>[spkrname] [emote]</h2>")

/*
/obj/structure/announcementmicrophone/proc/speakmessage(var/text)
	var/turf/die = get_turf(handset)
	die.audible_message("\icon[handset] [text]",hearing_distance = 2)// TEMP HACKY FIX!!
*/

/obj/structure/announcementmicrophone/proc/set_cooldown(var/delay)
	cooldown = 1
	spawn(delay)
		if(cooldown)
			cooldown = 0

/obj/structure/announcementmicrophone/update_icon()
	. = ..()
	overlays.Cut()
	if(broadcasting && !listening)
		var/image/I = image(icon=src.icon, icon_state = "mic_silent")
		I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		overlays += I
	else if(broadcasting && listening)
		var/image/I = image(icon=src.icon, icon_state = "mic_on")
		I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		overlays += I

/obj/structure/announcementspeaker/
	name = "Loudspeaker"
	icon = 'icons/obj/device.dmi'
	icon_state = "loudspeaker"
	anchored = TRUE
	plane = ABOVE_HUMAN_PLANE
	var/id = 0

/obj/structure/announcementspeaker/red
    id = RED_TEAM

/obj/structure/announcementspeaker/blue
    id = BLUE_TEAM

/obj/structure/announcementmicrophone/red
	id = RED_TEAM
	rune_color = "#c51e1e"

/obj/structure/announcementmicrophone/blue
	id = BLUE_TEAM
	additional_talk_sound = list('sound/effects/loudspeaker_01.ogg','sound/effects/loudspeaker_02.ogg','sound/effects/loudspeaker_03.ogg','sound/effects/loudspeaker_04.ogg','sound/effects/loudspeaker_05.ogg')
	additional_talk_sound_volume = 55
	speakerstyle = "boldannounce_blue" // h3 + warning makes it CURLY (disco freaky) :>
	textstyle = "staffwarn_blue"
	rune_color = "#0077cc"