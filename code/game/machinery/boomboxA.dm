var/global/obj/item/device/adminboombox/youtube_request_target

/obj/item/device/adminboombox
	name = "Radio Boombox"
	icon = 'icons/obj/boombox.dmi'
	icon_state = "cdplayer"
	desc = "A smuggled in boombox used with smuggled in cassette tapes to listen to smuggled in tunes. Now with a AM/FM radio!"
	var/obj/item/device/cassette/casseta = null
	var/datum/sound_token/sound_token
	var/playing = 0
	var/youtube_mode = 0
	var/youtube_request_url
	var/mob/youtube_requester
	var/youtube_request_status
	var/sound/youtube_sound
	var/youtube_song_file
	var/youtube_song_duration = 0
	var/playback_timer
	var/sound_id
	worldicons = "cdplayerworld"
	w_class = ITEM_SIZE_NO_CONTAINER

/obj/item/device/adminboombox/attack_hand(mob/user as mob)
	if(istype(get_area(user), /area/warfare/battlefield/no_mans_land))//Do not take this into no man's land please.
		to_chat(user, "I can't take that with me into no man's land. Wouldn't want to lose it.")
		return
	else
		..()

/obj/item/device/adminboombox/New()
	..()
	sound_id = "[type]_[sequential_id(type)]"

/obj/item/device/adminboombox/Destroy()
	if(youtube_request_target == src)
		if(youtube_requester)
			to_chat(youtube_requester, "<span class='notice'>\icon[src] Your YouTube song request was cancelled because the boombox was removed.</span>")
		youtube_request_target = null
		youtube_request_url = null
		youtube_requester = null
		youtube_request_status = null
	StopPlaying()
	if(youtube_song_file)
		fdel(youtube_song_file)
	youtube_song_duration = 0
	. = ..()


/obj/item/device/adminboombox/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/cassette))
		if(youtube_mode)
			to_chat(user, "<span class='notice'>\icon[src] Switch to cassette mode before inserting a cassette.</span>")
			return
		if(casseta)
			to_chat(user, "<span class='notice'>\icon[src] There is already cassette inside.</span>")
			return
		if(!user.unEquip(I))
			return
		I.forceMove(src)
		casseta = I
		visible_message("<span class='notice'>[user] inserts a cassette into [src].</span>")
		playsound(get_turf(src), 'sound/machines/bominside.ogg', 50, 1)
		update_icon()
		return
	..()


/obj/item/device/adminboombox/MouseDrop(var/obj/over_object)
	if (!over_object || !(ishuman(usr) || issmall(usr)))
		return

	if (!(src.loc == usr))
		return

	switch(over_object.name)
		if("r_hand")
			eject()
		if("l_hand")
			eject()




/obj/item/device/adminboombox/proc/eject()
	if(usr.incapacitated())
		return
	if(!casseta)
		to_chat(usr, "<span class='notice'>\icon[src] There is no cassette inside.</span>")
		return

	if(youtube_mode)
		to_chat(usr, "<span class='notice'>\icon[src] Switch to cassette mode before ejecting the cassette.</span>")
		return

	if(playing)
		StopPlaying()
	visible_message("<span class='notice'>[usr] ejects cassette from [src].</span>")
	playsound(get_turf(src), 'sound/machines/bominside.ogg', 50, 1)
	usr.put_in_hands(casseta)
	casseta = null
	update_icon()

/obj/item/device/adminboombox/attack_self(mob/user)
	ui_interact(user)

/obj/item/device/adminboombox/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/list/data = list(
		"youtube_mode" = youtube_mode,
		"playing" = playing,
		"has_cassette" = !!casseta,
		"has_youtube_song" = !!youtube_sound
	)

	var/obj/item/device/adminboombox/request_target = youtube_request_target
	if(request_target)
		data["request_status"] = request_target.youtube_request_status

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "boombox.tmpl", "Boombox", 500, 400)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/item/device/adminboombox/Topic(href, href_list)
	if(..())
		return

	var/mob/user = usr
	if(href_list["toggle_mode"])
		if(youtube_request_target == src)
			to_chat(user, "<span class='notice'>\icon[src] You cannot change modes while this song request is being reviewed or downloaded.</span>")
		else
			youtube_mode = !youtube_mode
			StopPlaying()
			playsound(get_turf(src), 'sound/machines/bomclick.ogg', 50, 1)

	if(href_list["toggle_play"])
		if(playing)
			StopPlaying()
		else
			StartPlaying()
		playsound(get_turf(src), 'sound/machines/bomclick.ogg', 50, 1)

	if(href_list["eject"])
		eject()

	if(href_list["request_song"])
		request_youtube_song(user)

	if(href_list["explode_boombox"] || href_list["delete_boombox"])
		if(!check_rights(R_ADMIN, 0, user))
			to_chat(user, "<span class='notice'>\icon[src] You need +ADMIN permissions to manage this boombox.</span>")
		else if(href_list["explode_boombox"])
			log_and_message_admins("exploded a boombox.", user, get_turf(src))
			explosion(get_turf(src), 0, 1, 3)
			qdel(src)
			return
		else
			log_and_message_admins("deleted a boombox.", user, get_turf(src))
			qdel(src)
			return

	if(href_list["accept_song"] || href_list["deny_song"])
		var/obj/item/device/adminboombox/request_target = youtube_request_target
		if(!check_rights(R_ADMIN, 0, user))
			to_chat(user, "<span class='notice'>\icon[src] You need +ADMIN permissions to review song requests.</span>")
		else if(request_target != src)
			to_chat(user, "<span class='notice'>\icon[src] That song request is no longer active on this boombox.</span>")
		else if(request_target.youtube_request_status == "In review")
			if(href_list["accept_song"])
				log_and_message_admins("accepted the YouTube song request: <a href='[html_encode(request_target.youtube_request_url)]'>[html_encode(request_target.youtube_request_url)]</a>.", user, get_turf(src))
				request_target.accept_youtube_song()
			else
				log_and_message_admins("denied the YouTube song request: <a href='[html_encode(request_target.youtube_request_url)]'>[html_encode(request_target.youtube_request_url)]</a>.", user, get_turf(src))
				request_target.deny_youtube_song()

	update_boombox_uis()

/obj/item/device/adminboombox/proc/request_youtube_song(mob/user)
	if(!youtube_mode)
		return
	if(youtube_request_target)
		to_chat(user, "<span class='notice'>\icon[src] A YouTube song is already in review or downloading.</span>")
		return

	var/song_url = input(user, "Enter a YouTube or youtu.be link.", "Request a song") as text|null
	if(isnull(song_url))
		return
	if(!user || user.incapacitated() || !youtube_mode || youtube_request_target)
		return
	if(!is_valid_youtube_url(song_url))
		to_chat(user, "<span class='notice'>\icon[src] Only youtube.com and youtu.be links are accepted.</span>")
		return

	youtube_request_url = song_url
	youtube_requester = user
	youtube_request_status = "In review"
	youtube_request_target = src
	notify_song_request_result("A YouTube song has been submitted for admin review.")
	var/video_url = html_encode(youtube_request_url)
	var/admin_message = "requested a YouTube song: <a href='[video_url]'>[video_url]</a> (<a href='?src=\ref[src];accept_song=1'>Accept</a> | <a href='?src=\ref[src];deny_song=1'>Deny</a> | <a href='?src=\ref[src];explode_boombox=1'>Explode</a> | <a href='?src=\ref[src];delete_boombox=1'>Delete</a>)."
	log_and_message_admins(admin_message, user, get_turf(src))
	update_boombox_uis()

/obj/item/device/adminboombox/proc/is_valid_youtube_url(var/song_url)
	if(!song_url || findtext(song_url, "\n") || findtext(song_url, ascii2text(13)) || findtext(song_url, " "))
		return FALSE

	var/lower_url = lowertext(song_url)
	if(copytext(lower_url, 1, 9) != "https://" && copytext(lower_url, 1, 8) != "http://")
		return FALSE

	var/host_start = findtext(lower_url, "://") + 3
	var/host_end = length(lower_url) + 1
	var/path_start = findtext(lower_url, "/", host_start)
	var/query_start = findtext(lower_url, "?", host_start)
	var/fragment_start = findtext(lower_url, "#", host_start)
	if(path_start && path_start < host_end)
		host_end = path_start
	if(query_start && query_start < host_end)
		host_end = query_start
	if(fragment_start && fragment_start < host_end)
		host_end = fragment_start

	var/host = copytext(lower_url, host_start, host_end)
	return host == "youtube.com" || host == "www.youtube.com" || host == "youtu.be"

/obj/item/device/adminboombox/proc/accept_youtube_song()
	if(youtube_request_target != src || youtube_request_status != "In review")
		return

	youtube_request_status = "Downloading"
	notify_song_request_result("An admin accepted the YouTube song request. The boombox is downloading it now.")
	update_boombox_uis()

	spawn(0)
		download_youtube_song()

/obj/item/device/adminboombox/proc/deny_youtube_song()
	if(youtube_request_target != src || youtube_request_status != "In review")
		return

	notify_song_request_result("An admin denied the YouTube song request.")
	clear_youtube_request()
	update_boombox_uis()

/obj/item/device/adminboombox/proc/download_youtube_song()
	var/song_id = sequential_id(/obj/item/device/boombox)
	var/request_file = "data/boombox_request_[song_id].txt"
	var/output_file = "data/boombox_song_[song_id].ogg"
	var/duration_file = "data/boombox_duration_[song_id].txt"
	var/output_template = "data/boombox_song_[song_id].%(ext)s"

	// Keep the user-provided URL out of the shell command.
	text2file(youtube_request_url, request_file)
	if(!fexists(request_file))
		youtube_download_failed(request_file, output_file)
		return

	// Prefer YouTube's original-language track when the extractor identifies one.
	var/command = "\"yt-dlp_x86.exe\" --no-playlist --force-overwrites --format \"bestaudio\" --format-sort \"lang\" --extract-audio --audio-format vorbis --audio-quality 9 --print-to-file \"after_move:%(duration)s\" \"[duration_file]\" --output \"[output_template]\" --batch-file \"[request_file]\""
	shell(command)
	fdel(request_file)

	if(youtube_request_target != src || QDELETED(src))
		fdel(output_file)
		fdel(duration_file)
		return
	if(!fexists(output_file))
		youtube_download_failed(request_file, output_file, duration_file)
		return

	var/song_duration = 0
	if(fexists(duration_file))
		song_duration = text2num(file2text(duration_file))
	fdel(duration_file)

	var/old_song_file = youtube_song_file
	var/sound/old_youtube_sound = youtube_sound
	var/old_song_duration = youtube_song_duration
	var/song_resource = fcopy_rsc(output_file)
	if(!song_resource)
		youtube_download_failed(request_file, output_file)
		return
	youtube_sound = sound(song_resource)
	if(!youtube_sound)
		youtube_download_failed(request_file, output_file)
		return
	youtube_song_duration = song_duration

	StartPlaying()
	if(!playing)
		youtube_sound = old_youtube_sound
		youtube_song_duration = old_song_duration
		youtube_download_failed(request_file, output_file)
		return

	youtube_song_file = output_file
	if(old_song_file && old_song_file != output_file)
		fdel(old_song_file)
	notify_song_request_result("The accepted YouTube song is ready and is now playing.")
	clear_youtube_request()
	update_boombox_uis()

/obj/item/device/adminboombox/proc/youtube_download_failed(var/request_file, var/output_file, var/duration_file = null)
	fdel(request_file)
	fdel(output_file)
	if(duration_file)
		fdel(duration_file)
	if(youtube_request_target == src)
		notify_song_request_result("Error downloading the requested YouTube link. Is FFmpeg installed?")
		clear_youtube_request()
		world.log << "Boombox YouTube download failed for [src]."
		update_boombox_uis()

/obj/item/device/adminboombox/proc/clear_youtube_request()
	if(youtube_request_target == src)
		youtube_request_target = null
	youtube_request_url = null
	youtube_requester = null
	youtube_request_status = null

/obj/item/device/adminboombox/proc/notify_song_request_result(var/message)
	var/notice = "<span class='notice'>\icon[src] [message]</span>"
	if(ismob(loc))
		var/mob/holder = loc
		to_chat(holder, notice)
		return
	var/turf/source_turf = get_turf(src)
	for(var/mob/M in hearers(1, source_turf))
		to_chat(M, notice)

/proc/update_boombox_uis()
	for(var/obj/item/device/adminboombox/B in world)
		SSnanoui.update_uis(B)

/obj/item/device/adminboombox/proc/StopPlaying()
	playing = 0
	if(playback_timer)
		deltimer(playback_timer)
		playback_timer = null
	QDEL_NULL(sound_token)

/obj/item/device/adminboombox/proc/StartPlaying()
	StopPlaying()
	var/sound/sound_to_play
	if(youtube_mode)
		sound_to_play = youtube_sound
	else if(casseta)
		sound_to_play = casseta.sound_inside
	if(!sound_to_play)
		return

	sound_token = sound_player.PlayLoopingSound(src, sound_id, sound_to_play, volume = 25, range = 9, falloff = 3, prefer_mute = TRUE, ignore_vis = TRUE, synchronize_playback = TRUE, repeat_sound = FALSE)
	if(!sound_token)
		return
	playing = 1
	if(youtube_mode && youtube_song_duration > 0)
		playback_timer = addtimer(CALLBACK(src, PROC_REF(stop_after_song)), youtube_song_duration * 10, TIMER_STOPPABLE)

/obj/item/device/adminboombox/proc/stop_after_song()
	playback_timer = null
	StopPlaying()

/proc/replay_boombox_audio(var/mob/listener)
	if(!listener || !listener.client)
		return
	for(var/obj/item/device/adminboombox/B in world)
		if(B.playing && B.sound_token)
			B.sound_token.ReplayToListener(listener)

/obj/item/device/adminboombox/update_icon()
	. = ..()
	if(isworld(loc))
		if(casseta)
			worldicons = "cdplayerworld"
			originalstate = "cdplayer"
		else
			worldicons = "cdplayerworld_open"
			originalstate = "cdplayer_open"
	if(!isworld(loc))
		if(casseta)
			icon_state = "cdplayer"
			worldicons = "cdplayerworld"
		else
			icon_state = "cdplayer_open"
			worldicons = "cdplayerworld_open"

/obj/item/device/adminboombox/stationary
	anchored = TRUE

/obj/item/device/adminboombox/stationary/attack_hand(mob/user)
	attack_self(user)

/obj/item/device/adminboombox/stationary/MouseDrop(obj/over_object)
	eject()