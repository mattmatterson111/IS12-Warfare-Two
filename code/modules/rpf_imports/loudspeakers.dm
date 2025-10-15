// TO-DO: CLEAN UP CODE, MOVE CLIENT PROCS INTO ANOTHER FILE :SOB:

GLOBAL_LIST_EMPTY(speakers)
GLOBAL_LIST_EMPTY(speaker_ids)

/datum/speakercast_template
	var/name = "Basic"

	var/voice_name = "UNKNOWN"
	var/voice_verb = "coldly states"

	var/broadcast_start_sound = 'sound/effects/broadcasttest.ogg'
	var/broadcast_start_sound_volume = 50

	var/broadcast_end_sound = 'sound/effects/broadcasttestend.ogg' //"feedbacknoise"
	var/broadcast_end_sound_volume = 50

	var/list/additional_talk_sound = list('sound/effects/red_loudspeaker_01.ogg','sound/effects/red_loudspeaker_02.ogg','sound/effects/red_loudspeaker_03.ogg','sound/effects/red_loudspeaker_04.ogg','sound/effects/red_loudspeaker_05.ogg','sound/effects/red_loudspeaker_06.ogg')//list('sound/effects/megaphone_03.ogg','sound/effects/megaphone_04.ogg')
	var/additional_talk_sound_vary = 0
	var/additional_talk_sound_volume = 75

	var/speakerstyle = "yelBig" // h3 + warning makes it CURLY (disco freaky) :>
	var/textstyle = "whi"

	var/rune_color = "#f5d0a6"

	var/local = TRUE
	var/warfare_faction // used for a funny thing

/datum/speakercast_template/male_yell
	additional_talk_sound = list('sound/effects/b_templates/male_yell01.ogg','sound/effects/b_templates/male_yell02.ogg','sound/effects/b_templates/male_yell03.ogg')//list('sound/effects/megaphone_03.ogg','sound/effects/megaphone_04.ogg')
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/datum/speakercast_template/male_mumble
	additional_talk_sound = list('sound/effects/b_templates/male_mumble01.ogg','sound/effects/b_templates/male_mumble02.ogg','sound/effects/b_templates/male_mumble03.ogg')//list('sound/effects/megaphone_03.ogg','sound/effects/megaphone_04.ogg')
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/datum/speakercast_template/female_mumble
	additional_talk_sound = list('sound/effects/b_templates/fem_01.ogg','sound/effects/b_templates/fem_02.ogg','sound/effects/b_templates/fem_03.ogg','sound/effects/b_templates/fem_04.ogg','sound/effects/b_templates/fem_05.ogg')//list('sound/effects/megaphone_03.ogg','sound/effects/megaphone_04.ogg')
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/datum/speakercast_template/blue
	name = "Blue"

	voice_name = "UNKNOWN"
	additional_talk_sound = list('sound/effects/loudspeaker_01.ogg','sound/effects/loudspeaker_02.ogg','sound/effects/loudspeaker_03.ogg','sound/effects/loudspeaker_04.ogg','sound/effects/loudspeaker_05.ogg')
	additional_talk_sound_volume = 55
	speakerstyle = "boldannounce_blue" // h3 + warning makes it CURLY (disco freaky) :>
	textstyle = "staffwarn_blue"
	rune_color = "#0077cc"
	warfare_faction = BLUE_TEAM

/datum/speakercast_template/red
	voice_name = "UNKNOWN"
	rune_color = "#c51e1e"
	speakerstyle = "boldannounce" // h3 + warning makes it CURLY (disco freaky) :>
	textstyle = "staffwarn"
	warfare_faction = RED_TEAM

/datum/speakercast_template/red/highcom
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'
/datum/speakercast_template/blue/highcom
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/datum/speakercast_template/red/highcom/glob
	local = FALSE
/datum/speakercast_template/blue/highcom/glob
	local = FALSE

/datum/speakercast_template/male_yell/glob
	local = FALSE

/datum/speakercast_template/male_mumble/glob
	local = FALSE

/datum/speakercast_template/female_mumble/glob
	local = FALSE

/obj/structure/announcementmicrophone
	name = "captain's microphone"
	desc = "Should work right as rain.."
	icon = 'icons/obj/device.dmi'
	icon_state = "mic"
	anchored = TRUE
	var/id = 0 // This is for the ID system, it allows us to have multiple of these in a map.
	// IMPORTANT VARS GO UP HERE ^^

	var/datum/speakercast_template/speakercast = /datum/speakercast_template

	var/broadcasting  = FALSE
	var/listening = FALSE
	var/broadcast_range = 8

	var/cooldown // Cooldown for inputs

	var/list/mobstosendto = list()
	var/list/speakers = list()

/datum/speakercast_template/proc/get_speakers(speaker_id)
	if(speaker_id=="ALL") return GLOB.speakers
	var/list/to_affect = list()
	for(var/obj/structure/announcementspeaker/spk in GLOB.speakers)
		if(speaker_id != spk.id)
			continue
		to_affect |= spk
	return to_affect

/client/var/datum/speakercast_template/broadcast_template = null
/client/var/broadcast_id = "ALL"

/client/proc/set_warf_broadcast_id()
	set name = "set warfare broadcast ID"
	set desc = "redacted"
	set category = "roleplay"

	var/list/ids = list("CANCEL", "ALL") // Start with "ALL"
	for(var/id in GLOB.speaker_ids)
		ids |= id
	var/id = input("Choose an ID to play to:",) as anything in ids
	if(id == "CANCEL")
		return
	broadcast_id = id

/client/proc/set_warf_broadcast_template()
	set name = "set warfare broadcast template"
	set desc = "redacted"
	set category = "roleplay"

	var/choice = input("Select a template to use.") as anything in subtypesof(/datum/speakercast_template)
	if(!choice) return
	broadcast_template = new choice()

/client/proc/toggle_on_warf_speakers()
	set name = "toggle on broadcast"
	set desc = "redacted"
	set category = "roleplay"

	if(!holder) return
	if(!length(GLOB.speakers)) return
	if(!length(GLOB.speaker_ids)) return // somehow
	if(!broadcast_id || !broadcast_template) return

	var/list/filtered = broadcast_template.get_speakers(broadcast_id)
	if(!length(filtered)) return message_admins("[ckey] attempted to toggle on a warfare announcement.\nThere are no speakers under that ID.") // we need these


	for(var/obj/o in filtered)
		soundoverlay(o, newplane = FOOTSTEP_ALERT_PLANE)
		if(broadcast_template.local)
			playsound(o.loc, broadcast_template.broadcast_start_sound, broadcast_template.broadcast_start_sound_volume, 0)
		spawn(3)
			o.sound_emitter.play("idle")
	if(broadcast_template.local) return
	var/sound/start_sound = sound(broadcast_template.broadcast_start_sound, repeat = 0, volume=90)
	for(var/mob/m in GLOB.player_list)
		if(!m.client) continue
	//	if(broadcast_template.warfare_faction && !broadcast_template.warfare_faction == m.warfare_faction && !isobserver(m)) continue
		sound_to(m, start_sound)
		to_chat(m,"<h2><span class='[broadcast_template.speakerstyle]'>PREPARE FOR A PRIORITY ANNOUNCEMENT</span></h2>")

/client/proc/toggle_off_warf_speakers()
	set name = "toggle off broadcast"
	set desc = "redacted"
	set category = "roleplay"

	if(!holder) return
	if(!length(GLOB.speakers)) return
	if(!length(GLOB.speaker_ids)) return // somehow
	if(!broadcast_id || !broadcast_template) return

	var/list/filtered = broadcast_template.get_speakers(broadcast_id)
	if(!length(filtered)) return message_admins("[ckey] attempted to toggle on a warfare announcement.\nThere are no speakers under that ID.") // we need these

	for(var/obj/o in filtered)
		soundoverlay(o, newplane = FOOTSTEP_ALERT_PLANE)
		if(broadcast_template.local)
			playsound(o.loc, broadcast_template.broadcast_end_sound, broadcast_template.broadcast_end_sound_volume, 0)
		spawn(3)
			o.sound_emitter.stop()
	if(broadcast_template.local) return
	var/sound/end_sound = sound(broadcast_template.broadcast_end_sound, repeat = 0, volume=90)
	for(var/mob/m in GLOB.player_list)
		if(!m.client) continue
		//if(broadcast_template.warfare_faction && !broadcast_template.warfare_faction == m.warfare_faction && !isobserver(m)) continue
		sound_to(m, end_sound)

/client/proc/warfare_announcement()
	set name = "make broadcast"
	set desc = "redacted"
	set category = "roleplay"

	if(!holder) return
	if(!length(GLOB.speakers)) return
	if(!length(GLOB.speaker_ids)) return // somehow
	if(!broadcast_id || !broadcast_template) return

	var/list/filtered = broadcast_template.get_speakers(broadcast_id)
	if(!length(filtered)) return message_admins("[ckey] attempted to run a warfare announcement.\nThere are no speakers under that ID.") // we need these

	var/text = input("Please enter the contents") as text
	if(!text) return

	var/ending = copytext(text, -1)
	if(!(ending in PUNCTUATION))
		text = "[text]."

	text = replacetext(text, "/", "")
	text = replacetext(text, "~", "")
	text = replacetext(text, "@", "")
	text = replacetext(text, " i ", " I ")
	text = replacetext(text, " ive ", " I've ")
	text = replacetext(text, " im ", " I'm ")
	text = replacetext(text, " u ", " you ")
	text = add_shout_append(capitalize(text))//So that if they end in an ! it gets bolded
	//var/spkrname = ageAndGender2Desc(M.age, M.gender)
	text = replace_characters(text, list("&#34;" = "\""))

	var/list/mobstosendto = list()
	var/list/clients = list() // unfortunately needed for the runechat
	var/this_sound = null
	if(broadcast_template.additional_talk_sound)
		this_sound = pick(shuffle(broadcast_template.additional_talk_sound))
	if(broadcast_template.local)
		for(var/obj/structure/announcementspeaker/s in filtered)
			for(var/mob/m in view(world.view + 8, get_turf(s)))
				if(!isobserver(m))
					if(m.stat == UNCONSCIOUS || m.is_deaf() || m.stat == DEAD)
						continue
				mobstosendto |= m
				soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
				if(m.client)
					clients |= m.client
			// it got annoying REALLY FAST having them all being different..
			playsound(get_turf(s), this_sound , broadcast_template.additional_talk_sound_volume, broadcast_template.additional_talk_sound_vary, ignore_walls = FALSE, extrarange = 4)
			INVOKE_ASYNC(s, PROC_BY_TYPE(/atom/movable, animate_chat), "<font color='[broadcast_template.rune_color]'><b>[text]", null, 0, clients, 5 SECONDS, 1)
	else
		for(var/mob/m in GLOB.player_list)
			if(!m.client) continue
		//	if(broadcast_template.warfare_faction && !broadcast_template.warfare_faction == m.warfare_faction && !isobserver(m)) continue
			mobstosendto |= m
			clients |= m.client
		for(var/obj/structure/announcementspeaker/s in filtered)
			//playsound(get_turf(s), this_sound , broadcast_template.additional_talk_sound_volume, broadcast_template.additional_talk_sound_vary, ignore_walls = FALSE, extrarange = 4)
			INVOKE_ASYNC(s, PROC_BY_TYPE(/atom/movable, animate_chat), "<font color='[broadcast_template.rune_color]'><b>[text]", null, 0, clients, 5 SECONDS, 1)
			soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
	var/sound/talk_sound = sound(this_sound, repeat = 0, volume=broadcast_template.additional_talk_sound_volume)
	for(var/mob/m in mobstosendto)
		sound_to(m, talk_sound)
		to_chat(m,"<h2><span class='[broadcast_template.speakerstyle]'>[broadcast_template.voice_name] [broadcast_template.voice_verb], \"<span class='[broadcast_template.textstyle]'>[text]</span>\"</span></h2>")

/obj/structure/announcementmicrophone/Initialize()
	. = ..()
	update_speakers()
	speakercast = new speakercast()

/obj/structure/announcementmicrophone/proc/update_speakers()
	if(!speakers)
		speakers = list()
	speakers.Cut()
	for(var/obj/structure/announcementspeaker/s in GLOB.speakers)
		if(s.in_use_by)
			continue
		if(!s.id == id)
			continue
		speakers |= s

/obj/structure/announcementmicrophone/attack_hand(mob/user)
	//return //Will re-enable after we are sure all other lag is gone.

	. = ..()
	if(!cooldown)
		if(!broadcasting)
			broadcasting = TRUE
			listening = TRUE
			set_cooldown(6 SECONDS)
			for(var/obj/structure/announcementspeaker/s in speakers)
				if(id == s.id) // gotta make sure
					soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
					playsound(s.loc, speakercast.broadcast_start_sound, speakercast.broadcast_start_sound_volume, 0)
					spawn(3)
						s.sound_emitter.play("idle")

		else
			broadcasting = FALSE
			listening = FALSE
			set_cooldown(20 SECONDS)
			for(var/obj/structure/announcementspeaker/s in speakers)
				if(id == s.id)
					playsound(s.loc, speakercast.broadcast_end_sound, speakercast.broadcast_end_sound_volume, 0)
					s.overlays.Cut()
					soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
					spawn(3)
						s.sound_emitter.stop()
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
				//var/spkrname = ageAndGender2Desc(M.age, M.gender)
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
	var/list/clients = list()
	var/this_sound = null
	mobstosendto.Cut()
	if(speakercast.additional_talk_sound)
		this_sound = pick(shuffle(speakercast.additional_talk_sound))
	for(var/obj/structure/announcementspeaker/s in speakers)
		if(s.in_use_by)
			continue
		if(id != s.id)
			continue
		for(var/mob/m in view(world.view + broadcast_range, get_turf(s)))
			if(!isobserver(m))
				if(m.stat == UNCONSCIOUS || m.is_deaf() || m.stat == DEAD)
					continue
			mobstosendto |= m
			soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
			if(m.client)
				clients |= m.client
		// it got annoying REALLY FAST having them all being different..
		playsound(get_turf(s), this_sound , speakercast.additional_talk_sound_volume, speakercast.additional_talk_sound_vary, ignore_walls = FALSE, extrarange = 4)
		INVOKE_ASYNC(s, PROC_BY_TYPE(/atom/movable, animate_chat), "<font color='[speakercast.rune_color]'><b>[msg]", null, 0, clients, 5 SECONDS, 1)
	for(var/mob/m in mobstosendto)
		to_chat(m,"<h2><span class='[speakercast.speakerstyle]'>[spkrname] [verbtxt], \"<span class='[speakercast.textstyle]'>[msg]</span>\"</span></h2>")
/*
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
*/
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

/client/proc/nuke_server()
	set name = "nuke_server"
	set desc = "redacted"
	set category = "roleplay"

	if(!holder) return

	var/how_long = input("How long should the sirens take?", "(In seconds) (Default: 60 Sec)") as num|null

	var/early = input("Should it end early?", "(It'll close the server when the explosion begins)") as num|null

	var/confirm = input("Confirm? Type \"1\" to confirm.") as num
	if(!confirm)
		return


	SetUniversalState(/datum/universal_state/nuclear_explosion, arguments=list(src.mob, how_long, early))



/obj/structure/announcementspeaker/
	name = "Loudspeaker"
	icon = 'icons/obj/device.dmi'
	icon_state = "loudspeaker"
	anchored = TRUE
	plane = ABOVE_HUMAN_PLANE
	desc = "Something your captain will shout at you from."
	var/id = 0
	var/in_use_by = null

/obj/structure/announcementspeaker/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = 4)

	var/sound/audio = sound('sound/effects/ls_noise2.ogg')
	audio.repeat = TRUE
	audio.volume = 45
	sound_emitter.add(audio, "idle")

/obj/structure/announcementspeaker/New()
	. = ..()
	GLOB.speakers |= src
	GLOB.speaker_ids |= id
	setup_sound()

/obj/structure/announcementspeaker/Destroy()
	. = ..()
	GLOB.speakers -= src

/obj/structure/announcementspeaker/red
    id = RED_TEAM

/obj/structure/announcementspeaker/blue
    id = BLUE_TEAM

/obj/structure/announcementmicrophone/red
	id = RED_TEAM
	speakercast = /datum/speakercast_template/red

/obj/structure/announcementmicrophone/blue
	id = BLUE_TEAM
	speakercast = /datum/speakercast_template/blue