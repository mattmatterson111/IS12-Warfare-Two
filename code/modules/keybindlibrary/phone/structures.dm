/*

 ___   _     ____  __   __      _____  _     _   __       __    ___   ___   ____
| |_) | |   | |_  ( (` ( (`      | |  | |_| | | ( (`     / /`  / / \ | | \ | |_
|_|_) |_|__ |_|__ _)_) _)_)      |_|  |_| | |_| _)_)     \_\_, \_\_/ |_|_/ |_|__

 _  _____      _      __    __       _      ___       ___   _   __    _    _____     _____  ___       ____  _     _   __  _____
| |  | |      | |_|  / /\  ( (`     | |\ | / / \     | |_) | | / /`_ | |_|  | |       | |  / / \     | |_  \ \_/ | | ( (`  | |
|_|  |_|      |_| | /_/--\ _)_)     |_| \| \_\_/     |_| \ |_| \_\_/ |_| |  |_|       |_|  \_\_/     |_|__ /_/ \ |_| _)_)  |_|

_____   __    _     ____      _     ____  ____  ___            __    ___   ___   ____  ___
 | |   / /\  | |_/ | |_      | |_| | |_  | |_  | | \  __      / /`  / / \ | | \ | |_  | |_)
 |_|  /_/--\ |_| \ |_|__     |_| | |_|__ |_|__ |_|_/ /_/)     \_\_, \_\_/ |_|_/ |_|__ |_| \

 _     ____  _     _         _      __    _     __        __    _     ____   __    ___
| |_| | |_  | |   | |       | |    / /\  \ \_/ ( (`      / /\  | |_| | |_   / /\  | | \  __
|_| | |_|__ |_|__ |_|__     |_|__ /_/--\  |_|  _)_)     /_/--\ |_| | |_|__ /_/--\ |_|_/ (_()


                           |~~~~~~~|
                           |       |
                         |~~~~~~~~~~~|
                         | B Y O N D |
                         |___________|
                           |       |
|~.\\\_\~~~~~~~~~~~~~~xx~~~         ~~~~~~~~~~~~~~~~~~~~~/_//;~|
|  \  o \_         ,XXXXX),                         _..-~ o /  |
|    ~~\  ~-.     XXXXX`)))),                 _.--~~   .-~~~   |
 ~~~~~~~`\   ~\~~~XXX' _/ ';))     |~~~~~~..-~     _.-~ ~~~~~~~
          `\   ~~--`_\~\, ;;;\)__.---.~~~      _.-~
            ~-.       `:;;/;; \          _..-~~
               ~-._      `''        /-~-~
                   `\              /  /
                     |         ,   | |
                      |  '        /  |
                       \/;          |
                        ;;          |
                        `;   .       |
                        |~~~-----.....|
                       | \             \
                      | /\~~--...__    |
                      (|  `\       __-\|
                      ||    \_   /~    |
                      |)     \~-'      |
                       |      | \      '
                       |      |  \    :
                        \     |  |    |
                         |    )  (    )
                          \  /;  /\  |
                          |    |/   |
                          |    |   |
                           \  .'  ||
                           |  |  | |
                           (  | |  |
                           |   \ \ |
                           || o `.)|
                           |`\\\\) |
                           |       |
                           |       |
                           |       |

*/



GLOBAL_LIST_EMPTY(phone_list)

/obj/structure/phone
	name = "Base phone structure"
	desc = "YOU SHOULD NOT BE ABLE TO SEE THIS"
	icon = 'code/modules/keybindlibrary/phone/icon/telephone.dmi'
	icon_state = "redphone_1"
	var/obj/item/phone/handset = null // our handset..
	var/phonename // Phone name is seperate from the object name, for phone book stuff lmfao
	var/hiddenphone = FALSE // For hiding the phones from the phone book
	var/caninput = TRUE // This lets us disable inputting
	var/callactive // so we know if the phone's chattin'

	var/phoneprefix = "416-7912-" // 416-7912-randomnumbers //
	var/phonesuffix // Set this to 4 numbers if you want a specific phone number to be set.
	var/fullphonenumber // This is the full phone number, for phone books
	var/cleanedphonenumber // This is the cleaned one, without the -'s

	var/obj/structure/phone/oncallwith = null // This lets us have a back and forth communication between the phones.
	// IMPORTANT VARS GO UP HERE ^^
	// I PROMISE YOU I GOTTA DO THIS!! IM SO SORRY!!

	var/list/sound_map = list("!" = "yell.ogg", "?" = "question.ogg", "." = "normal.ogg") // This is for assigning sounds to ! . and ?

	var/datum/sound_token/sound_token // For looping sounds


	var/cooldown // Cooldown for inputs
	var/phonemounted = TRUE // This is a check for if the phone is mounted
	var/base_state // BASE ICON STATE. // i think theres a better way to do this
	var/currentnumbers // Current numbers dialoed/typed into the phone. AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	var/sound_id // ID For looping sounds. I'm not taking any fucking chances with this bullshit anymore.
	var/busy // so that we won't get called by numerous people at once
	var/ringing // unused
	var/fakenumbers // for nice chat text. // YEAH : )

/obj/structure/phone/examine(mob/user)
	. = ..()
	if(!isghost(user)) // fuck you ghosts peeking at the captain and admin phone numbers..
		to_chat(user, "\The [src] has a small number plate on it, it reads [fullphonenumber].")

/obj/structure/phone/attack_hand(mob/user)
	. = ..()
	if(phonemounted)
		if(handset)
			user.put_in_active_hand(handset)
			icon_state = "[icon_state]less"
			phonemounted = FALSE
			playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/phones/pickup1.ogg',100,0)
			START_PROCESSING(SSfastprocess,handset) // No other idea on how we can periodically check on the distance of the handset sorry
			if(oncallwith)
				stoploopingsound()
				oncallwith.stoploopingsound()
				playsound(get_turf(oncallwith.handset),'code/modules/keybindlibrary/phone/sound/phones/pickup_phone.ogg',100,0)
				callactive = TRUE
				oncallwith.callactive = TRUE
	else if(!phonemounted)
		to_chat(usr,"you hit the hook switch")
		playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/phones/hook_switch.ogg',100,0)
		clearconnection()

/obj/structure/phone/attackby(var/obj/item/O, mob/user)
	//	. = ..()
	if(!phonemounted)
		if(istype(O, /obj/item/phone)) // check if its a handset
			var/obj/item/phone/P = O // bullshittery
			if(P.linked_phone == src) // MAKE SURE ITS OUR PHONE. Do NOT mix and match!!
				stoploopingsound()
				//P.drop_sound = "code/modules/keybindlibrary/phone/sound/phones/putdown[rand(1,2)].ogg"
				icon_state = base_state
				user.remove_from_mob(P)
				O.forceMove(src)
				phonemounted = TRUE
				STOP_PROCESSING(SSfastprocess,handset)
				//STOP_PROCESSING(SSobj,src)
				if(user.a_intent == I_HURT)
					user.visible_message("<span class='danger'>[user] slams the handset into the phone!</span>")
					playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/phones/phone_slam.ogg',100,0)
					if(oncallwith)
						oncallwith.speakmessage("<span class='phonespeaker'>You hear the phone being slammed down on the other side.</span>")
				else
					playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/phones/putdown1.ogg',100,0)
					if(oncallwith)
						oncallwith.speakmessage("<span class='phonespeaker'>You hear the phone being put down on the other side.</span>")
	clearconnection()


	// New procs
/*
	Process(var/obj/item/phone/handset, mob/user)
		var/distance = get_dist(src, handset)
		if(distance <= 3)
			if(istype(handset.loc, /mob))
				user.remove_from_mob(handset)
			handset.forceMove(src)
			phonemounted = TRUE
			playsound(src.loc, "code/modules/keybindlibrary/phone/sound/phones/putdown1.ogg",100,0)
			STOP_PROCESSING(SSobj,src)
*/
// brokerd

/obj/structure/phone/hear_talk(mob/living/M as mob, msg, var/verb="says", datum/language/speaking=null)
	if(handset)
		if(oncallwith)
			if(oncallwith.handset)
				if(callactive && oncallwith.callactive)
					if(M in range(1, get_turf(handset)))
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
						msg = replace_characters(msg	, list("&#34;" = "\""))
						transmitmessage(spkrname, msg, verb)

/obj/structure/phone/see_emote(mob/M as mob, text, var/emote_type)
	if(callactive && oncallwith.callactive)
		if(emote_type != AUDIBLE_MESSAGE)
			return
		if(M in range(1, get_turf(handset)))
			text = html_encode(text)
			/*to_chat(world, strip_html_properly(text))
			text = strip_html_properly(text)
			to_chat(world, replacetext(text, M, ""))
			text = replacetext(text, M, "")
			*/
			//var/spkrname = ageAndGender2Desc(M.age, M.gender)
			//transmitemote(spkrname, text)
			return // Not sure how to fix it. Right now it spits out this: Young Woman <B>Arb. Mcintosh Willey</B> screams!
		else
			return

/obj/structure/phone/proc/stopshittyprocessing()
	STOP_PROCESSING(SSfastprocess, handset)

/obj/structure/phone/proc/play_sound_based_on_message(var/message)
	var/sound = ""
	var/last_char
	if (message)
		last_char = message[length(message)]
	if (last_char in sound_map)
		sound = sound_map[last_char]
		playsound(get_turf(handset), "code/modules/keybindlibrary/phone/sound/phone_voice/[sound]", 100, 0.1)

/obj/structure/phone/proc/generaterandom4digit()
	var/YYYY = rand(1000, 9999)
	return "[YYYY]"

/obj/structure/phone/proc/removehyphens(phoneNumber)
	var/result = replacetext(phoneNumber, "-", "")
	return result

/obj/structure/phone/proc/clearconnection()
	if(oncallwith)
		oncallwith.stoploopingsound()
		oncallwith.busy = FALSE
		oncallwith.caninput = TRUE
		oncallwith.currentnumbers = ""
		oncallwith.fakenumbers = ""
		oncallwith.callactive = FALSE
		oncallwith.oncallwith = null

	oncallwith = null
	caninput = TRUE
	busy = FALSE
	currentnumbers = ""
	callactive = FALSE
	fakenumbers = ""
	stoploopingsound()

/obj/structure/phone/proc/ring()
	QDEL_NULL(sound_token)
	sound_token = sound_player.PlayLoopingSound(src, sound_id, 'code/modules/keybindlibrary/phone/sound/phones/phone_ring.ogg', volume = 35, range = 9, falloff = 3, prefer_mute = TRUE, ignore_vis = TRUE)
	audible_message("\icon[src]<span class='warning'>[src.name] begins ringing!</span>")
	ringing = TRUE

/obj/structure/phone/proc/dialing()
	QDEL_NULL(sound_token)
	sound_token = sound_player.PlayLoopingSound(handset, sound_id, 'code/modules/keybindlibrary/phone/sound/phones/calling.ogg', volume = 35, range = 3, falloff = 0.1, prefer_mute = TRUE, ignore_vis = TRUE)

/obj/structure/phone/proc/dialtone()
	QDEL_NULL(sound_token)
	sound_token = sound_player.PlayLoopingSound(handset, sound_id, 'code/modules/keybindlibrary/phone/sound/phones/dialtone.ogg', volume = 35, range = 3, falloff = 0.1, prefer_mute = TRUE, ignore_vis = TRUE)

/obj/structure/phone/proc/stoploopingsound()
	QDEL_NULL(sound_token)
	ringing = FALSE

/obj/structure/phone/proc/transmitmessage(spkrname, msg, var/verbtxt)
	if(!handset.covered)
		oncallwith.speakmessage("<span class='phonespeaker'>[spkrname] [verbtxt], \"</span><span class='phonetext'>[msg]</span><span class='phonespeaker'>\"")
		oncallwith.play_sound_based_on_message(text)
/obj/structure/phone/proc/transmitemote(spkrname, emote)
	if(!handset.covered)
		oncallwith.speakmessage("<span class='phonespeaker'>[spkrname] [emote]</span>")

/obj/structure/phone/proc/speakmessage(var/text)
	var/turf/die = get_turf(handset)
	die.audible_message("\icon[handset] [text]",hearing_distance = 2)// TEMP HACKY FIX!!

/obj/structure/phone/proc/set_cooldown(var/delay)
	cooldown = 1
	spawn(delay)
		if(cooldown)
			cooldown = 0



/obj/structure/phone/proc/startcalling(var/dialingnumber, mob/user) // mob user incase we want to send messages to the users omeday.
	caninput = FALSE
	busy = TRUE
	dialing()
	var/phone_found = FALSE
	for (var/obj/structure/phone/phone in GLOB.phone_list)
		if (dialingnumber == phone.cleanedphonenumber)
			phone_found = TRUE

			if (phone == src)
				dialtone()
				break
			else if (phone.busy || !phone.phonemounted || phone.oncallwith)
				dialtone()
				caninput = TRUE
				break
			else
				phone.busy = TRUE
				phone.ring()
				oncallwith = phone
				phone.oncallwith = src
				spawn(20 SECONDS)
					if(callactive)
						break
					else
						clearconnection()
						speakmessage("The line goes dead..")
	if (!phone_found)
		dialtone()


/obj/structure/phone/proc/inputnumber(key as text, mob/living/user)
	if (!CanPhysicallyInteract(user) || !caninput || oncallwith || phonemounted || cooldown)
		return
	if (!phonemounted && key in list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"))
		set_cooldown(0.1 SECONDS)
		if (length(fakenumbers) == 3 || length(currentnumbers) == 7)
			fakenumbers = "[fakenumbers]"+"-"
		playsound(get_turf(handset), "code/modules/keybindlibrary/phone/sound/phones/touchtone/Touchtone[key].ogg", 100, 0)
		currentnumbers += key
		fakenumbers += key
		user.visible_message("[user] dials [key].", "\icon[src]<span class='phonespeaker'>You dial</span> <span class='danger'>[fakenumbers]</span><span class='phonespeaker'> into the phone.</span>")
		if (length(currentnumbers) == 11 && !busy)
			startcalling(currentnumbers)
		return


/obj/structure/phone/New() // To me, New() and Initialize are the same LMFAO
	. = ..()

	base_state = icon_state

	// -- Sets the handset as our fucking handset, duhh
	var/obj/item/phone/P = new(src.loc)
	P.forceMove(src)
	handset = P
	P.linked_phone = src

//	GLOB.phonesinworld += src  // Not to self: Figure out how to initialize a global list independent of this shitty fucking structure, so we can add all the phones in the world post-init or smth
 // or just reliably add phones to it somehow aJIFASJFJIFJ

	GLOB.phone_list |= src

	// Phone number bullshit.
	var/randomSuffix
	if(!phonesuffix)
		randomSuffix = generaterandom4digit()
	else
		randomSuffix = phonesuffix

	fullphonenumber = phoneprefix + randomSuffix
	cleanedphonenumber = removehyphens(fullphonenumber)

	// for looping sounds
	sound_id = "[type]_[sequential_id(type)]"





// ITEMS



		// NOTES:
			// GOTTA MAKE A GLOBAL LIST!! //List of all human mobs and sub-types, including clientless

/obj/structure/phone/rotary
	name = "Rotary phone"
	desc = "The height of our technology- A rotary phone!"
	icon_state = "rotaryphone"
	base_state = "rotaryphone"
	anchored = TRUE

/obj/structure/phone/rotary/attack_hand(mob/user)
	if(phonemounted)
		if(handset)
			START_PROCESSING(SSfastprocess, handset)
			user.put_in_active_hand(handset)
			icon_state = "[icon_state]less"
			phonemounted = FALSE
			playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/rotaryphone/pickup1.ogg',100,0)
			//START_PROCESSING(SSobj,src) // No other idea on how we can periodically check on the distance of the handset sorry
			if(oncallwith)
				stoploopingsound()
				oncallwith.stoploopingsound()
				playsound(get_turf(oncallwith.handset),'code/modules/keybindlibrary/phone/sound/rotaryphone/pickup_phone.ogg',100,0)
				callactive = TRUE
				oncallwith.callactive = TRUE
	else if(!phonemounted)
		to_chat(usr,"you hit the hook switch")
		playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/rotaryphone/hook_switch.ogg',100,0)
		clearconnection()




/obj/structure/phone/rotary/attackby(var/obj/item/O, mob/user)
	//	. = ..()
	if(!phonemounted)
		if(istype(O, /obj/item/phone)) // check if its a handset
			var/obj/item/phone/P = O // bullshittery
			if(P.linked_phone == src) // MAKE SURE ITS OUR PHONE. Do NOT mix and match!!
				stoploopingsound()
				icon_state = base_state
				user.remove_from_mob(P)
				O.forceMove(src)
				phonemounted = TRUE
				STOP_PROCESSING(SSfastprocess,handset)
				if(user.a_intent == I_HURT)
					user.visible_message("<span class='danger'>[user] slams the handset into the phone!</span>")
					playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/rotaryphone/phone_slam.ogg',100,0)
					if(oncallwith)
						oncallwith.speakmessage("<span class='phonespeaker'>You hear the phone being slammed down on the other side.</span>")
				else
					playsound(src.loc, 'code/modules/keybindlibrary/phone/sound/rotaryphone/putdown1.ogg',100,0)
					if(oncallwith)
						oncallwith.speakmessage("<span class='phonespeaker'>You hear the phone being put down on the other side.</span>")
				clearconnection()


	// New procs
/*
	Process(var/obj/item/phone/handset, mob/user)
		var/distance = get_dist(src, handset)
		if(distance <= 3)
			if(istype(handset.loc, /mob))
				user.remove_from_mob(handset)
			handset.forceMove(src)
			phonemounted = TRUE
			playsound(src.loc, "code/modules/keybindlibrary/phone/sound/phones/putdown1.ogg",100,0)
			STOP_PROCESSING(SSobj,src)
*/
// brokerd

/obj/structure/phone/rotary/ring()
	QDEL_NULL(sound_token)
	sound_token = sound_player.PlayLoopingSound(src, sound_id, 'code/modules/keybindlibrary/phone/sound/rotaryphone/phone_ring.ogg', volume = 35, range = 9, falloff = 3, prefer_mute = TRUE, ignore_vis = TRUE)
	audible_message("\icon[src]<span class='warning'>[src.name] begins ringing!</span>")
	ringing = TRUE

/obj/structure/phone/rotary/dialing()
	QDEL_NULL(sound_token)
	sound_token = sound_player.PlayLoopingSound(handset, sound_id, 'code/modules/keybindlibrary/phone/sound/rotaryphone/calling.ogg', volume = 35, range = 3, falloff = 0.1, prefer_mute = TRUE, ignore_vis = TRUE)

/obj/structure/phone/rotary/dialtone()
	QDEL_NULL(sound_token)
	sound_token = sound_player.PlayLoopingSound(handset, sound_id, 'code/modules/keybindlibrary/phone/sound/rotaryphone/dialtone.ogg', volume = 35, range = 3, falloff = 0.1, prefer_mute = TRUE, ignore_vis = TRUE)

/obj/structure/phone/rotary/inputnumber(key as text, mob/living/user)
	if (!CanPhysicallyInteract(user) || !caninput || oncallwith || phonemounted || cooldown)
		return
	if (!phonemounted && key in list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"))
		var/keycooldown
		switch(key)
			if("0") keycooldown = 2.31
			if("1")	keycooldown = 0.67
			if("2")	keycooldown = 0.95
			if("3") keycooldown = 1
			if("4") keycooldown = 1.3
			if("5") keycooldown = 1.4
			if("6") keycooldown = 1.8
			if("7") keycooldown = 1.6
			if("8") keycooldown = 1.8
			if("9") keycooldown = 2
		set_cooldown(keycooldown SECONDS)
		if (length(fakenumbers) == 3 || length(currentnumbers) == 7)
			fakenumbers = "[fakenumbers]"+"-"
		playsound(get_turf(handset), "code/modules/keybindlibrary/phone/sound/rotaryphone/touchtone/Touchtone[key].ogg", 100, 0)
		currentnumbers += key
		fakenumbers += key
		user.visible_message("[user] dials [key].", "\icon[src]<span class='phonespeaker'>You dial</span> <span class='danger'>[fakenumbers]</span><span class='phonespeaker'> into the phone.</span>")
		if (length(currentnumbers) == 11 && !busy)
			startcalling(currentnumbers)
		return

/obj/structure/phone/rotary/New() // To me, New() and Initialize are the same LMFAO

	base_state = icon_state

	// -- Sets the handset as our fucking handset, duhh
	var/obj/item/phone/rotary/P = new(src.loc)
	P.forceMove(src)
	handset = P
	P.linked_phone = src

//	GLOB.phonesinworld += src  // Not to self: Figure out how to initialize a global list independent of this shitty fucking structure, so we can add all the phones in the world post-init or smth
 // or just reliably add phones to it somehow aJIFASJFJIFJ

	GLOB.phone_list |= src

	// Phone number bullshit.
	var/randomSuffix
	if(!phonesuffix)
		randomSuffix = generaterandom4digit()
	else
		randomSuffix = phonesuffix

	fullphonenumber = phoneprefix + randomSuffix
	cleanedphonenumber = removehyphens(fullphonenumber)

	// for looping sounds
	sound_id = "[type]_[sequential_id(type)]"

/obj/structure/phone/rotary/redcaptain
	name = "Rotary phone"
	desc = "The height of Redistani technology- A rotary phone!"
	icon = 'code/modules/keybindlibrary/phone/icon/phones.dmi'
	phonename = RED_TEAM
	icon_state = "red"
	base_state = "red"

/obj/structure/phone/rotary/bluecaptain
	name = "Rotary phone"
	desc = "The height of Blusnian technology- A rotary phone!"
	icon = 'code/modules/keybindlibrary/phone/icon/phones.dmi'
	phonename = BLUE_TEAM
	icon_state = "blue"
	base_state = "blue"

// I FEEL SO BAD ABOUT COPY AND PASTING ALL OF THIS. SO MAN TIMES..

/obj/structure/phone/rotary/bluecaptain/New() // To me, New() and Initialize are the same LMFAO

	base_state = icon_state

	// -- Sets the handset as our fucking handset, duhh
	var/obj/item/phone/blue/P = new(src.loc)
	P.forceMove(src)
	handset = P
	P.linked_phone = src

//	GLOB.phonesinworld += src  // Not to self: Figure out how to initialize a global list independent of this shitty fucking structure, so we can add all the phones in the world post-init or smth
 // or just reliably add phones to it somehow aJIFASJFJIFJ

	GLOB.phone_list |= src

	// Phone number bullshit.
	var/randomSuffix
	if(!phonesuffix)
		randomSuffix = generaterandom4digit()
	else
		randomSuffix = phonesuffix

	fullphonenumber = phoneprefix + randomSuffix
	cleanedphonenumber = removehyphens(fullphonenumber)

	// for looping sounds
	sound_id = "[type]_[sequential_id(type)]"

/obj/structure/phone/rotary/redcaptain/New() // To me, New() and Initialize are the same LMFAO

	base_state = icon_state

	// -- Sets the handset as our fucking handset, duhh
	var/obj/item/phone/red/P = new(src.loc)
	P.forceMove(src)
	handset = P
	P.linked_phone = src

//	GLOB.phonesinworld += src  // Not to self: Figure out how to initialize a global list independent of this shitty fucking structure, so we can add all the phones in the world post-init or smth
 // or just reliably add phones to it somehow aJIFASJFJIFJ

	GLOB.phone_list |= src

	// Phone number bullshit.
	var/randomSuffix
	if(!phonesuffix)
		randomSuffix = generaterandom4digit()
	else
		randomSuffix = phonesuffix

	fullphonenumber = phoneprefix + randomSuffix
	cleanedphonenumber = removehyphens(fullphonenumber)

	// for looping sounds
	sound_id = "[type]_[sequential_id(type)]"