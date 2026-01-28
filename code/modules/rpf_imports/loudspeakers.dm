// Loudspeaker System
// Refactored to use Decls and support Languages.

GLOBAL_LIST_EMPTY(speakers)
GLOBAL_LIST_EMPTY(speaker_ids)
GLOBAL_LIST_EMPTY(announcement_microphones)

// ============================================================================
// TEMPLATES (DECLS)
// ============================================================================

/decl/speakercast_template
	var/name = "Basic"
	
	var/voice_name = "UNKNOWN"
	var/voice_verb = "coldly states"
	
	// Language support
	var/language_type = null // /datum/language/warfare/red etc.
	
	var/broadcast_start_sound = 'sound/effects/broadcasttest.ogg'
	var/broadcast_start_sound_volume = 50
	
	var/broadcast_end_sound = 'sound/effects/broadcasttestend.ogg'
	var/broadcast_end_sound_volume = 50
	
	var/list/additional_talk_sound = list('sound/effects/red_loudspeaker_01.ogg','sound/effects/red_loudspeaker_02.ogg','sound/effects/red_loudspeaker_03.ogg','sound/effects/red_loudspeaker_04.ogg','sound/effects/red_loudspeaker_05.ogg','sound/effects/red_loudspeaker_06.ogg')
	var/additional_talk_sound_vary = 0
	var/additional_talk_sound_volume = 75
	
	var/speakerstyle = "yelBig"
	var/textstyle = "whi"
	
	var/rune_color = "#f5d0a6"
	
	var/local = TRUE

/decl/speakercast_template/proc/get_speakers(speaker_id)
	if(speaker_id == "ALL") 
		return GLOB.speakers
	var/list/to_affect = list()
	for(var/obj/structure/announcementspeaker/spk in GLOB.speakers)
		if(speaker_id != spk.id)
			continue
		to_affect |= spk
	return to_affect

/decl/speakercast_template/proc/broadcast(text, speaker_id, mob/source_mob, datum/language/speaking_language = null)
	var/list/speakers = get_speakers(speaker_id)
	if(!length(speakers))
		return
	
	// Clean up text
	if(!(copytext(text, -1) in PUNCTUATION))
		text = "[text]."
	text = replacetext(text, "/", "")
	text = replacetext(text, "~", "")
	text = replacetext(text, "@", "")
	text = replacetext(text, " i ", " I ")
	text = replacetext(text, " u ", " you ")
	text = add_shout_append(capitalize(text))
	text = replace_characters(text, list("&#34;" = "\""))

	var/datum/language/L = null
	// Prioritize passed language (from mic speaker), then template language
	if(speaking_language)
		L = speaking_language
	else if(language_type)
		L = all_languages[language_type]

	// Scramble for non-speakers if a language is set
	var/list/clients = list()
	var/this_sound = null
	if(additional_talk_sound)
		this_sound = pick(shuffle(additional_talk_sound))
	
	// Collect valid listeners and handle visuals
	var/list/all_listeners = list()
	if(local)
		for(var/obj/structure/announcementspeaker/s in speakers)
			soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
			playsound(get_turf(s), this_sound , additional_talk_sound_volume, additional_talk_sound_vary, ignore_walls = FALSE, extrarange = 4)
			
			var/list/hearers = view(world.view + 8, get_turf(s))
			for(var/mob/m in hearers)
				if(!isobserver(m) && (m.stat == UNCONSCIOUS || m.is_deaf() || m.stat == DEAD))
					continue
				all_listeners |= m
				if(m.client)
					clients |= m.client
					
			INVOKE_ASYNC(s, /atom/movable/proc/animate_chat, "<font color='[rune_color]'><b>[text]", L, TRUE, clients, 5 SECONDS, 1)
	else
		for(var/mob/m in GLOB.player_list)
			if(m.client)
				all_listeners |= m
				clients |= m.client
		for(var/obj/structure/announcementspeaker/s in speakers)
			INVOKE_ASYNC(s, /atom/movable/proc/animate_chat, "<font color='[rune_color]'><b>[text]", L, TRUE, clients, 5 SECONDS, 1)
			soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)

	// Send chat message
	var/sound/talk_sound = sound(this_sound, repeat = 0, volume=additional_talk_sound_volume)
	
	for(var/mob/m in all_listeners)
		sound_to(m, talk_sound)
		
		var/final_text = text
		if(L && !m.say_understands(null, L))
			final_text = L.scramble(text)
		
		to_chat(m, "<h2><span class='[speakerstyle]'>[voice_name] [voice_verb], \"<span class='[textstyle]'>[final_text]</span>\"</span></h2>")


// SUBTYPES

/decl/speakercast_template/male_yell
	additional_talk_sound = list('sound/effects/b_templates/male_yell01.ogg','sound/effects/b_templates/male_yell02.ogg','sound/effects/b_templates/male_yell03.ogg')
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/decl/speakercast_template/male_mumble
	additional_talk_sound = list('sound/effects/b_templates/male_mumble01.ogg','sound/effects/b_templates/male_mumble02.ogg','sound/effects/b_templates/male_mumble03.ogg')
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/decl/speakercast_template/female_mumble
	additional_talk_sound = list('sound/effects/b_templates/fem_01.ogg','sound/effects/b_templates/fem_02.ogg','sound/effects/b_templates/fem_03.ogg','sound/effects/b_templates/fem_04.ogg','sound/effects/b_templates/fem_05.ogg')
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/decl/speakercast_template/blue
	name = "Blue"
	voice_name = "UNKNOWN"
	language_type = LANGUAGE_BLUE
	additional_talk_sound = list('sound/effects/loudspeaker_01.ogg','sound/effects/loudspeaker_02.ogg','sound/effects/loudspeaker_03.ogg','sound/effects/loudspeaker_04.ogg','sound/effects/loudspeaker_05.ogg')
	additional_talk_sound_volume = 55
	speakerstyle = "boldannounce_blue"
	textstyle = "staffwarn_blue"
	rune_color = "#0077cc"

/decl/speakercast_template/red
	voice_name = "UNKNOWN"
	language_type = LANGUAGE_RED
	rune_color = "#c51e1e"
	speakerstyle = "boldannounce"
	textstyle = "staffwarn"

/decl/speakercast_template/red/highcom
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/decl/speakercast_template/blue/highcom
	broadcast_start_sound = 'sound/effects/b_templates/friendcast_start.ogg'
	broadcast_end_sound = 'sound/effects/b_templates/friendcast_end.ogg'

/decl/speakercast_template/red/highcom/glob
	local = FALSE

/decl/speakercast_template/blue/highcom/glob
	local = FALSE

/decl/speakercast_template/male_yell/glob
	local = FALSE

/decl/speakercast_template/male_mumble/glob
	local = FALSE

/decl/speakercast_template/female_mumble/glob
	local = FALSE

// ============================================================================
// MICROPHONE
// ============================================================================

/obj/structure/announcementmicrophone
	name = "captain's microphone"
	desc = "Should work right as rain.."
	icon = 'icons/obj/device.dmi'
	icon_state = "mic"
	anchored = TRUE
	var/id = 0
	var/decl/speakercast_template/speakercast_decl
	var/speakercast_type = /decl/speakercast_template
	var/broadcasting  = FALSE
	var/listening = FALSE
	var/broadcast_range = 8 // Only check nearby if broadcasting locally (conceptually), but hear_talk handles range.
	var/cooldown // Cooldown for inputs
	var/list/speakers = list()

/obj/structure/announcementmicrophone/red
	id = RED_TEAM
	speakercast_type = /decl/speakercast_template/red

/obj/structure/announcementmicrophone/blue
	id = BLUE_TEAM
	speakercast_type = /decl/speakercast_template/blue

/obj/structure/announcementmicrophone/Initialize()
	. = ..()
	GLOB.listening_objects += src
	update_speakers()
	speakercast_decl = decls_repository.get_decl(speakercast_type)

/obj/structure/announcementmicrophone/Destroy()
	GLOB.listening_objects -= src
	return ..()

/obj/structure/announcementmicrophone/proc/update_speakers()
	if(!speakers)
		speakers = list()
	speakers.Cut()
	for(var/obj/structure/announcementspeaker/s in GLOB.speakers)
		if(s.in_use_by)
			continue
		if(s.id != id)
			continue
		speakers |= s

/obj/structure/announcementmicrophone/proc/forward_sound(soundin, vol, frequency)
	for(var/obj/structure/announcementspeaker/s in speakers)
		playsound(s, soundin, vol, 0, 0, 0, 0, frequency, 0, TRUE, 2, TRUE, 0, 0)

/obj/structure/announcementmicrophone/proc/set_cooldown(var/delay)
	set waitfor = 0
	
	cooldown = 1
	sleep(delay)
	cooldown = 0

/obj/structure/announcementmicrophone/attack_hand(mob/user)
	. = ..()
	if(cooldown)
		return
	
	if(!broadcasting)
		broadcasting = TRUE
		listening = TRUE
		set_cooldown(6 SECONDS)
		start_broadcast()
	else
		broadcasting = FALSE
		listening = FALSE
		set_cooldown(20 SECONDS)
		stop_broadcast()
	
	playsound(src.loc, "button", 75, 1)
	update_icon()

/obj/structure/announcementmicrophone/proc/start_broadcast()
	update_speakers()
	for(var/obj/structure/announcementspeaker/s in speakers)
		if(id == s.id)
			soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
			playsound(s.loc, speakercast_decl.broadcast_start_sound, speakercast_decl.broadcast_start_sound_volume, 0)
			spawn(3)
				s.start_hum()

/obj/structure/announcementmicrophone/proc/stop_broadcast()
	for(var/obj/structure/announcementspeaker/s in speakers)
		if(id == s.id)
			playsound(s.loc, speakercast_decl.broadcast_end_sound, speakercast_decl.broadcast_end_sound_volume, 0)
			s.overlays.Cut()
			soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
			spawn(3)
				s.stop_hum()

/obj/structure/announcementmicrophone/RightClick(mob/user)
	. = ..()
	if(broadcasting)
		listening = !listening
		playsound(src.loc, "button", 75, 1)
		update_icon()

/obj/structure/announcementmicrophone/hear_talk(mob/living/M as mob, msg, var/verb="says", datum/language/speaking=null)
	if(!broadcasting || !listening)
		return
	if(!(M in range(2, get_turf(src))))
		return
	
	// Pass id directly to allow generic/team matching
	speakercast_decl.broadcast(msg, id, M, speaking)

// IO Support for Microphone
/obj/structure/announcementmicrophone/IO_receive_input(input_name, atom/activator, atom/caller, list/params)
	switch(lowertext(input_name))
		if("broadcast")
			if(!broadcasting)
				attack_hand(activator)
			return TRUE
		if("endbroadcast")
			if(broadcasting)
				attack_hand(activator)
			return TRUE
		if("togglebroadcast")
			attack_hand(activator)
			return TRUE
	return FALSE

// ============================================================================
// SPEAKER
// ============================================================================

/obj/structure/announcementspeaker
	name = "Loudspeaker"
	icon = 'icons/obj/device.dmi'
	icon_state = "loudspeaker"
	anchored = TRUE
	plane = ABOVE_HUMAN_PLANE
	desc = "Something your captain will shout at you from."
	var/id = 0
	var/in_use_by = null
	// sound_emitter is in atom/movable

/obj/structure/announcementspeaker/red
	id = RED_TEAM

/obj/structure/announcementspeaker/blue
	id = BLUE_TEAM

/obj/structure/announcementspeaker/New()
	. = ..()
	GLOB.speakers |= src
	GLOB.speaker_ids |= id
	setup_sound()

/obj/structure/announcementspeaker/Destroy()
	stop_hum()
	qdel(sound_emitter)
	GLOB.speakers -= src
	return ..()

/obj/structure/announcementspeaker/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = 4)
	var/sound/audio = sound('sound/effects/ls_noise2.ogg')
	audio.repeat = TRUE
	audio.volume = 25
	sound_emitter.add(audio, "idle")

/obj/structure/announcementspeaker/proc/start_hum()
	sound_emitter.play("idle")

/obj/structure/announcementspeaker/proc/stop_hum()
	sound_emitter.stop()

// ============================================================================
// CLIENT VERBS
// ============================================================================

/client/var/decl/speakercast_template/broadcast_template = null
/client/var/broadcast_id = "ALL"

/client/proc/set_warf_broadcast_id()
	set name = "set warfare broadcast ID"
	set desc = "Selects which ID of speakers to broadcast to."
	set category = "roleplay"

	var/list/ids = list("CANCEL", "ALL")
	for(var/id in GLOB.speaker_ids)
		ids |= id
	var/id = input("Choose an ID to play to:",) as anything in ids
	if(id == "CANCEL")
		return
	broadcast_id = id

/client/proc/set_warf_broadcast_template()
	set name = "set warfare broadcast template"
	set desc = "Selects the voice/style of the broadcast."
	set category = "roleplay"

	var/choice = input("Select a template to use.") as anything in subtypesof(/decl/speakercast_template)
	if(!choice) return
	broadcast_template = decls_repository.get_decl(choice)

/client/proc/toggle_on_warf_speakers()
	set name = "toggle on broadcast"
	set category = "roleplay"

	if(!holder || !length(GLOB.speakers)) return
	if(!broadcast_id || !broadcast_template) return

	var/list/filtered = broadcast_template.get_speakers(broadcast_id)
	if(!length(filtered)) 
		to_chat(src, "No speakers found with that ID.")
		return 
	
	for(var/obj/structure/announcementspeaker/o in filtered)
		soundoverlay(o, newplane = FOOTSTEP_ALERT_PLANE)
		if(broadcast_template.local)
			playsound(o.loc, broadcast_template.broadcast_start_sound, broadcast_template.broadcast_start_sound_volume, 0)
		spawn(3)
			o.start_hum()
			
	if(broadcast_template.local) return

	var/sound/start_sound = sound(broadcast_template.broadcast_start_sound, repeat = 0, volume=90)
	for(var/mob/m in GLOB.player_list)
		if(m.client)
			sound_to(m, start_sound)
			to_chat(m,"<h2><span class='[broadcast_template.speakerstyle]'>PREPARE FOR A PRIORITY ANNOUNCEMENT</span></h2>")

/client/proc/toggle_off_warf_speakers()
	set name = "toggle off broadcast"
	set category = "roleplay"

	if(!holder || !length(GLOB.speakers)) return
	if(!broadcast_id || !broadcast_template) return

	var/list/filtered = broadcast_template.get_speakers(broadcast_id)
	
	for(var/obj/structure/announcementspeaker/o in filtered)
		soundoverlay(o, newplane = FOOTSTEP_ALERT_PLANE)
		if(broadcast_template.local)
			playsound(o.loc, broadcast_template.broadcast_end_sound, broadcast_template.broadcast_end_sound_volume, 0)
		spawn(3)
			o.stop_hum()
			
	if(broadcast_template.local) return
	
	var/sound/end_sound = sound(broadcast_template.broadcast_end_sound, repeat = 0, volume=90)
	for(var/mob/m in GLOB.player_list)
		if(m.client)
			sound_to(m, end_sound)

/client/proc/warfare_announcement()
	set name = "make broadcast"
	set category = "roleplay"

	if(!holder || !length(GLOB.speakers)) return
	if(!broadcast_id || !broadcast_template) return

	var/list/filtered = broadcast_template.get_speakers(broadcast_id)
	if(!length(filtered))
		to_chat(src, "No speakers found.")
		return

	var/text = input("Please enter the contents") as text
	if(!text) return

	broadcast_template.broadcast(text, broadcast_id, src.mob)

/client/proc/nuke_server()
	set name = "nuke server"
	set category = "roleplay"
	
	if(!holder) return

	var/text = input("Please enter the contents (NUKE)") as text
	if(!text) return

	var/sound/start_sound = sound('sound/effects/siren.ogg', repeat = 0, volume=90)

	for(var/mob/m in GLOB.player_list)
		if(m.client)
			sound_to(m, start_sound)
			to_chat(m,"<h2><span class='boldannounce'>[text]</span></h2>")