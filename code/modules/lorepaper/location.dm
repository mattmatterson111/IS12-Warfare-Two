/atom/movable/screen/text/screen_text/battlefield
	color = "#d8d4cf"
	style_open = "<span style=\"text-align: left; vertical-align:'top'; font-family: 'Javanese Text'; -dm-text-outline: 1 black; font-size: 12px;\">"
	screen_loc = "LEFT+3.5, BOTTOM-3.5";
	maptext_height = 192
	maptext_width = 512
	fade_out_delay = 3 SECONDS
	play_delay = 1.5

/atom/movable/screen/text/screen_text/mood
	color = "#c0bdbaff"
	style_open = "<span style=\"text-align: center; vertical-align:'bottom'; font-family: 'Javanese Text'; -dm-text-outline: 1 black; font-size: 12px; background-color: #00000080;\">"
	screen_loc = "CENTER-7, BOTTOM";
	alpha = 185
	maptext_height = 192
	maptext_width = 512
	fade_out_delay = 3 SECONDS
	play_delay = 0.85

/atom/movable/screen/text/screen_text/audible
/**
 *  [ REFERENCE ]
 *
    icon = null
	icon_state = null
	alpha = 255
	plane = HUD_PLANE

	maptext_height = 64
	maptext_width = 480
	maptext_x = 0
	maptext_y = 0
	screen_loc = "LEFT,TOP-3"

	///A weakref to the client this belongs to
	var/client/owner_ref

	///Time taken to fade in as we start printing text
	var/fade_in_time = 0
	///Time before fade out after printing is finished
	var/fade_out_delay = 8 SECONDS
	///Time taken when fading out after fade_out_delay
	var/fade_out_time = 0.5 SECONDS
	///delay between playing each letter. in general use 1 for fluff and 0.5 for time sensitive messsages
	var/play_delay = 1
	///letters to update by per text to per play_delay
	var/letters_per_update = 1

	///opening styling for the message
	var/style_open = "<span class='maptext' style=font-size:20pt;text-align:center valign='top'>"
	///closing styling for the message
	var/style_close = "</span>"
	///var for the text we are going to play
	var/text_to_play

	/// Should this automatically end?
	var/auto_end = TRUE
 *
 * **/

/**
 *
 *  It's simple:
 * 		A list that holds a list associated to a string
 * 		It's shitty, it works, I like it like this for some reason
 *
 * 		list(sound,sound,sound)
 * 		<3
 */

		// A few basic sfx //
	// 'sound/effects/text/source_type.ogg' // - The source chat message sfx
	// 'sound/effects/text/ui_rollover.ogg' // - HL2 UI Rollover sfx, commonly used in GMOD servers for text that's typed out
		//   -Aurawatch-   // | HL2RP Server SFX |
	// 'sound/effects/text/aw_harsh.ogg' // - High pitched, harsh
	// 'sound/effects/text/aw_soft.ogg' // - High pitch, soft

	var/tmp/list/type_sounds = list(
		"key" = list('sound/effects/text/source_type.ogg'),
		"new_line" = list(),
		"space" = list(),
		"end" = list(),
		"volume" = 45,
		"vary" = FALSE,
	)

// this will be ugly.
/atom/movable/screen/text/screen_text/audible/play_to_client()

	var/client/owner = owner_ref
	if(!owner)
		return

	owner.screen += src

	if(fade_in_time)
		animate(src, alpha = 255)

	var/list/lines_to_skip = list()
	var/static/html_locate_regex = regex("<.*>")
	var/tag_position = findtext(text_to_play, html_locate_regex)
	var/reading_tag = TRUE

	while(tag_position)
		if(reading_tag)
			if(text_to_play[tag_position] == ">")
				reading_tag = FALSE
				lines_to_skip += tag_position
			else
				lines_to_skip += tag_position
			tag_position++
		else
			tag_position = findtext(text_to_play, html_locate_regex, tag_position)
			reading_tag = TRUE

	// tag_position = findtext(text_to_play, "&nbsp;")
	// while(tag_position)
	// 	lines_to_skip.Add(tag_position, tag_position+1, tag_position+2, tag_position+3, tag_position+4, tag_position+5)
	// 	tag_position = tag_position + 6
	// 	tag_position = findtext(text_to_play, "&nbsp;", tag_position)
	for(var/letter = 2 to length(text_to_play) + letters_per_update step letters_per_update)
		if(letter in lines_to_skip)
			continue

		maptext = "[style_open][copytext_char(text_to_play, 1, letter)][style_close]"
		var/char = copytext_char(text_to_play, letter-1, letter)
		var/sfx = null
		if (letter >= length(text_to_play) && length(type_sounds["end"]) && !sfx)
			sfx = safepick(type_sounds["end"])
		else if(char == "\n" && length(type_sounds["new_line"])  && !sfx)
			sfx = safepick(type_sounds["new_line"])
		else if(char == " " && length(type_sounds["space"]) && !sfx)
			sfx = safepick(type_sounds["space"])
		else if(char && length(type_sounds["key"]) && !sfx)
			sfx = safepick(type_sounds["key"])
		if(sfx)
			owner = owner_ref
			if(!owner)
				end_play()
			owner.mob.playsound_local(owner.mob.loc, sfx, type_sounds["volume"], type_sounds["vary"])
		if(QDELETED(src))
			return
		sleep(play_delay)

	if(auto_end)
		addtimer(CALLBACK(src, .proc/fade_out), fade_out_delay)
// but it works

/atom/movable/screen/text/screen_text/audible/mood
	color = "#c0bdbaff"
	style_open = "<span style=\"text-align: left; vertical-align:'top'; font-family: 'Javanese Text'; -dm-text-outline: 1 black; font-size: 10px; background-color: #00000080;\">"
	screen_loc = "LEFT+3.5, BOTTOM-4.5";
	alpha = 185
	maptext_height = 192
	maptext_width = 512
	fade_out_delay = 3 SECONDS
	play_delay = 0.90

/client/proc/debug_screentext()
	set name = "Debug Screen Text"
	set category = "Debug"

	var/typepick = input("SELECT THE DESIRED TYPE") as anything in subtypesof(/atom/movable/screen/text/screen_text)
	var/text = input("INPUT THE TEXT") as message
	mob.play_screen_text(text, alert = typepick)

/client/proc/send_screentext(mob/M as mob in SSmobs.mob_list)
	set name = "Send Screentext"
	set category = "Fun"

	var/typepick = input("SELECT THE DESIRED TYPE") as anything in subtypesof(/atom/movable/screen/text/screen_text)
	var/text = input("INPUT THE TEXT") as message
	mob.play_screen_text(text, alert = typepick)
	M.play_screen_text(text, alert = typepick)

/atom/movable/screen/text/screen_text/audible/mood/aw
		// A few basic sfx //
	// 'sound/effects/text/source_type.ogg' // - The source chat message sfx
	// 'sound/effects/text/ui_rollover.ogg' // - HL2 UI Rollover sfx, commonly used in GMOD servers for text that's typed out
		//   -Aurawatch-   // | HL2RP Server SFX |
	// 'sound/effects/text/aw_harsh.ogg' // - High pitched, harsh
	// 'sound/effects/text/aw_soft.ogg' // - High pitch, soft

	type_sounds = list(
		"key" = list('sound/effects/text/aw_harsh.ogg'),
		"new_line" = list(),
		"space" = list(),
		"end" = list(),
		"volume" = 45,
		"vary" = FALSE,
	)

/atom/movable/screen/text/screen_text/audible/mood/awsoft
	type_sounds = list(
		"key" = list('sound/effects/text/aw_soft.ogg'),
		"new_line" = list(),
		"space" = list(),
		"end" = list(),
		"volume" = 45,
		"vary" = FALSE,
	)

/atom/movable/screen/text/screen_text/audible/mood/hl2
	type_sounds = list(
		"key" = list('sound/effects/text/ui_rollover.ogg'),
		"new_line" = list(),
		"space" = list(),
		"end" = list(),
		"volume" = 15,
		"vary" = TRUE,
	)

/client/proc/debug_env()
	set name = "Debug Env"
	set category = "Debug"

	var/list/environment_types = list(
    "GENERIC" = 0,
    "PADDED_CELL" = 1,
    "ROOM" = 2,
    "BATHROOM" = 3,
    "LIVINGROOM" = 4,
    "STONEROOM" = 5,
    "AUDITORIUM" = 6,
    "CONCERT_HALL" = 7,
    "CAVE" = 8,
    "ARENA" = 9,
    "HANGAR" = 10,
    "CARPETED_HALLWAY" = 11,
    "HALLWAY" = 12,
    "STONE_CORRIDOR" = 13,
    "ALLEY" = 14,
    "FOREST" = 15,
    "CITY" = 16,
    "MOUNTAINS" = 17,
    "QUARRY" = 18,
    "PLAIN" = 19,
    "PARKING_LOT" = 20,
    "SEWER_PIPE" = 21,
    "UNDERWATER" = 22,
    "DRUGGED" = 23,
    "DIZZY" = 24,
    "PSYCHOTIC" = 25
	)


	var/typepick = input("SELECT THE DESIRED TYPE") as anything in environment_types
	var/area/A = get_area(mob)
	A.sound_env = environment_types[typepick]
	mob.lastarea = A
	to_chat(src, "Changed.")