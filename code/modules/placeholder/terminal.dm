// Glory be to my godawful cargo code V2.

//
/datum/terminal_page_controller
	var/obj/machinery/kaos/holder
	var/datum/terminal_page/current_page
	var/previous_page
	var/list/pages = list() // Holds /datum/terminal_page instances
	var/list/page_registry = list() // Maps name => /datum/terminal_page

	var/busy = FALSE /// To prevent page overlap

/datum/terminal_page_controller/New(var/list/to_add)
	. = ..()
	pages = to_add // We pass the list incase we wanna do smth with it
	populate_pages(pages)

/datum/terminal_page_controller/proc/populate_pages(pages)
/*
	var/list/temp = list()
	page_registry = list()
	for(var/A in to_create)
		var/datum/terminal_page/page = new A
		page.holder = src
		temp += page
	*/ // <<
	for(var/datum/terminal_page/page in pages)
		page.holder = src
		if(!page.name)
			continue
		var/key = page.name

		page_registry[key] = page

	// pages = temp
	if(length(page_registry) != length(pages))
		message_admins("Couldnt create a registry for all pages: [src]")
		return FALSE
	return TRUE

/datum/terminal_page_controller/proc/load_first()
	if (length(pages))
		load_page(pages[1])

/datum/terminal_page_controller/proc/load_page(var/datum/terminal_page/page, arg)
	busy = TRUE
	if(current_page && current_page != previous_page)
		previous_page = current_page
	if(page == src)
		load_first()
		return // FATAL CRASH
	current_page = page
	if(prob(25))
		if(holder.input)
			holder.toggle_input(5, TRUE)
		holder.think(9)
	playsound(holder.loc, holder.load_sfx, 100, 0)
	current_page.load(arg)
	busy = FALSE

/datum/terminal_page_controller/proc/string_to_page(var/input, var/mob/user)
	if(busy)
		return
	if (current_page)
		current_page.receive_string(input, user)

/datum/terminal_page_controller/proc/get_page(string)
	string = lowertext(string)
	for(var/entry in page_registry)
		if(entry == string)
			var/page = page_registry[entry]
			if(page)
				return page
	return FALSE

/datum/terminal_page
	var/list/available_pages
	var/datum/terminal_page_controller/holder
	var/name = null

/datum/terminal_page/proc/load()
	clear_screen(10, TRUE)
	add_line("Page loaded.", 10, TRUE)
	return TRUE

/datum/terminal_page/proc/refresh()
	holder.holder.refresh_page()
	return TRUE

/datum/terminal_page/proc/receive_string(var/string, var/mob/user)
	string = lowertext(string)
	for(var/entry in available_pages)
		if(entry["code"] == string)
			var/name = entry["page_name"]
			if(!name)
				name = "[entry["datum"]]" // fallback if not manually defined
			var/page = holder.page_registry[name]
			if(page)
				holder.load_page(page)
				return
	add_line("Invalid command: [string]", 0)
	holder.holder.deny_sound()

/datum/terminal_page/proc/toggle_input(delay, sound)
	holder.holder.toggle_input(delay, sound)

/datum/terminal_page/proc/add_line(string, delay, sound)
	holder.holder.add_line(string, delay, sound)

/datum/terminal_page/proc/clear_screen(delay, sound)
	holder.holder.clear_screen(delay, sound)

/datum/terminal_page/proc/add_choice(string, description, delay, sound) // Doesn't actually add it, it's a visual thing
	add_line(add_line("<fieldset style='border: none; padding: 0; margin: 0;'><legend style='background-color: black; color: [holder.holder.Textcolor];' class='blink'>{ <b>[string]</b> }</legend> - [description]</fieldset>", delay, sound))

// PAGE SUBTYPES //

/datum/terminal_page/multiselect
	name = null

/datum/terminal_page/multiselect/New(list/to_grant, name_to_assume)
	. = ..()
	if(to_grant && !available_pages)
		available_pages = to_grant
	if(name_to_assume && !name)
		name = name_to_assume

/datum/terminal_page/multiselect/load()
	clear_screen(10, TRUE)
	add_line("<h1>[name]</h1>")
	if(holder.holder.input)
		toggle_input(5, TRUE)
	for (var/entry in available_pages)
		add_choice(entry["code"], entry["name"], 2, TRUE)
		//add_line("<fieldset style='border: none; padding: 0; margin: 0;'><legend style='background-color: [Textcolor]; color: black;' class='blink'>{ <b>[entry["code"]]</b> }</legend> - [entry["name"]]</fieldset>", 2, TRUE)
	if(!holder.holder.input)
		toggle_input(5, TRUE)

/datum/terminal_page/login
	name = null // don't add to registry, we'll do it ourselves
	var/redirect_to = null
	var/attempts = 0
	var/next_try = 0
	var/password = "password"
	var/saved_prev = null
	var/passed = 0

/datum/terminal_page/login/New(var/list/base)
	password = replacetext(password, "%CARGO", GLOB.cargo_password)
	password = base[1]
	name = base[2]
	redirect_to = base[3]

/datum/terminal_page/login/load(backtrack)
	if(!saved_prev)
		saved_prev = holder.previous_page
	if(passed || backtrack)
		holder.load_page(saved_prev)
		holder.previous_page = saved_prev
		passed = 0
		return FALSE
	if(!holder.get_page(redirect_to))
		add_line("Redirect after successful login is invalid. Notify administrator.<br>ERROR:[redirect_to]", 5, TRUE)
		holder.holder.think(9, TRUE)
		holder.load_page(holder.previous_page)
		return FALSE
	if(REALTIMEOFDAY - next_try < 30 SECONDS)
		add_line("Login is on cooldown for, <b>[REALTIMEOFDAY - next_try]</b> seconds.", 5, TRUE)
		holder.holder.think(9, TRUE)
		holder.load_page(holder.previous_page)
		return FALSE
	clear_screen(10, TRUE)
	if(holder.holder.input)
		toggle_input(5, TRUE)
	add_line("Enter the password,</i>", 10, TRUE)
	add_line("or enter \"BACK\" to return.</i>", 5, FALSE)
	add_line("----------------------------", 5, TRUE)
	holder.holder.think(9, TRUE)
	if(!holder.holder.input)
		toggle_input(5, TRUE)

/datum/terminal_page/login/receive_string(string, user)
	if(!string)
		add_line(".", 5, TRUE)
		add_line(".", 3, TRUE)
		add_line(".", 7, TRUE)
		holder.holder.deny_sound(5)
		add_line("<i>No message detected.</i>", 10, TRUE)
		add_line("<i>Try again, or type \"BACK\" to return.</i>", 15, TRUE)
		attempts++
		holder.load_page(src)
		return FALSE
	if(attempts >= 3 || lowertext(string) == "back")
		add_line(".", 3, TRUE)
		add_line(".", 7, TRUE)
		add_line(".", 4, TRUE)
		if(attempts >= 3)
			next_try = REALTIMEOFDAY
			attempts = 0
		holder.load_page(holder.previous_page)
		return FALSE
	add_line(".", 2, TRUE)
	add_line(".", 5, TRUE)
	add_line(".", 4, TRUE)
	holder.holder.think(9, TRUE)
	if(lowertext(string) == GLOB.cargo_password)
		add_line("<b>LOGIN SUCCESSFUL.</b>", 10, TRUE)
		holder.load_page(holder.get_page(redirect_to))
		passed = 1
		return
	else
		holder.holder.deny_sound()
		add_line("<b>INVALID LOGIN.</b>", 10, TRUE)
		holder.load_page(src)
		return

/datum/terminal_page/message_staff
	name = "message_staff"
	available_pages = null
	var/attempts = 0

/datum/terminal_page/message_staff/load()
	clear_screen(10, TRUE)
	if(holder.holder.input)
		toggle_input(5, TRUE)
	add_line("Choose your words <i>carefully,</i>", 10, TRUE)
	add_line("or enter \"BACK\" to return.</i>", 5, FALSE)
	add_line("----------------------------", 5, TRUE)
	holder.holder.think(9, TRUE)
	if(!holder.holder.input)
		toggle_input(5, TRUE)

/datum/terminal_page/message_staff/receive_string(string, user)
	if(holder.holder.input)
		toggle_input(5, TRUE)
	if(lowertext(string) == "back")
		add_line(".", 3, TRUE)
		add_line(".", 7, TRUE)
		add_line(".", 4, TRUE)
		holder.load_page(holder.previous_page, TRUE)
		attempts = 0
		return FALSE
	if(!string)
		add_line(".", 7, TRUE)
		add_line(".", 3, TRUE)
		add_line(".", 6, TRUE)
		holder.holder.deny_sound(5)
		add_line("<i>No message detected.</i>", 5, TRUE)
		add_line("<i>Try again, or type \"BACK\" to return.</i>", 15, TRUE)
		attempts++
		holder.load_page(src)
		return FALSE
	add_line(".", 7, TRUE)
	add_line(".", 3, TRUE)
	add_line(".", 5, TRUE)
	add_line("----------------------------", 3, TRUE)
	playsound(holder.holder.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 85, 0)
	add_line("<i>Message Sent</i>", 5, TRUE)
	message_admins("MESSAGE SENT BY [user] | \"[string]\" | (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[holder.holder.x];Y=[holder.holder.y];Z=[holder.holder.z]'>JMP</a>")
	holder.load_page(holder.previous_page, TRUE)
	return TRUE

// Message hub, basically botched emails

/datum/terminal_page/terminal_msg
	name = null // Null, is set in New()
	var/contents = "" /// Message's contents. Sanitized.
	var/sent_at = ""
	var/from = "" /// The sender computer name.
	var/seen = FALSE
	var/hidden_name = FALSE

/datum/terminal_page/terminal_msg/load()
	if(holder.holder.input)
		toggle_input(3, TRUE)
	clear_screen(10, TRUE)
	if(!seen)
		seen = TRUE
	var/datum/terminal_page/my_messages/hub = holder.get_page("my_messages")
	add_line("[sent_at] - FROM:[hidden_name ? "REDACTED" : from], TO: [hub.account_name] << [seen ? "" : "{*}"]")
	add_line("--", 5, TRUE)
	add_line("[contents]", 10, TRUE)
	add_line("--", 5, TRUE)
	add_line("Enter \"PRINT\" to print out the message.", 4, TRUE)
	add_line("Or enter \"BACK\" to return to the message select screen.", 3, TRUE)
	if(!holder.holder.input)
		toggle_input(3, TRUE)

/datum/terminal_page/terminal_msg/receive_string(string, mob/user)
	if(!string)
		holder.holder.deny_sound()
		return
	if(lowertext(string) == "back")
		if(holder.holder.input)
			toggle_input(3, TRUE)
		holder.holder.think(9)
		holder.load_page(holder.previous_page)
	else if(lowertext(string) == "print")
		if(holder.holder.input)
			toggle_input(3, TRUE)
		add_line("Please wait.", 3, TRUE)
		var/datum/terminal_page/my_messages/hub = holder.get_page("my_messages")
		holder.holder.think(9)
		playsound(holder.holder.loc, holder.holder.print_sfx, 100)
		sleep(holder.holder.print_duration)
		new /obj/item/paper(holder.holder.loc, "<b><font face='ms gothic' size=4>[sent_at]<br>From: [hidden_name ? "REDACTED" : from], To: [hub.account_name]</b><br><br></font><font face='ms gothic' size=3>[contents]</font><br><br><font face='ms gothic'>- PRINTED COPY -</font>", "PRINTOUT")
		add_line("Print completed successfully.", 3, TRUE)
		holder.load_page(holder.previous_page)
		return
	else
		holder.holder.deny_sound()
		return

/datum/terminal_page/terminal_msg/New(message, sent_by, send_time, redacted)
	name = "[type]_[sequential_id(type)]"
	if(!contents && message)	contents = message
	if(!sent_by && !send_time)	sent_at = "[time2text(world.realtime, "MM-DD")]-[time2text(world.timeofday, "hh:mm")]"
	if(!from && sent_by)	from = sent_by
	if(redacted) hidden_name = TRUE

GLOBAL_LIST_EMPTY(chat_clients)

/datum/terminal_page/my_messages
	name = "my_messages"
	var/list/messages_dts = list() /// The actual message datums themselves, can
	var/account_name /// Null, set in New(), is responsible for the from var in terminal_msg
	var/datum/terminal_page/return_to = null /// We store the previous page here, because going to messages would just make us return to the messages when trying to return.
	var/datum/terminal_page/send_message/message_sender = null
	var/datum/terminal_page/name_change/name_changer = null
	var/new_messages = 0

/datum/terminal_page/my_messages/proc/new_message(contents, sent_by, hidden)
	var/datum/terminal_page/terminal_msg/message = new (contents, sent_by, redacted = hidden)
	messages_dts += message
	message.holder = holder
	holder.holder.visible_message("\icon[holder.holder] [SPAN_YELLOW("[holder.holder] pings. You've got mail!")]")
	holder.holder.overlays.Cut()
	var/image/I = image(holder.holder.icon, holder.holder.loc, "captaincomp_alert")
	I.plane = EFFECTS_ABOVE_LIGHTING_PLANE // icky but it looks nice =w=
	holder.holder.overlays += I
	playsound(holder.holder.loc, holder.holder.mail_sfx, 100, 0, ignore_walls = FALSE)
	if(holder.holder.is_powered_on)
		spawn(3 SECONDS)
			I = image(holder.holder.icon, holder.holder.loc, "captaincomp_idle")
			I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
			holder.holder.overlays += I
	//var/page = return_to
	if(holder.current_page==src)
		load(src)
	//holder.load_page(src)
	//holder.previous_page = page
	return

/datum/terminal_page/my_messages/proc/update_newmsgs_count() /// Updates our new messages counter :)
	var/news = 0
	for(var/datum/terminal_page/terminal_msg/terminal_msg in messages_dts)
		if(terminal_msg.seen) continue
		news++
	new_messages = news

/datum/terminal_page/my_messages/load()
	if(!return_to) return_to = holder.previous_page
	if(!account_name) account_name = GenerateKey()
	update_newmsgs_count()
	//GLOB.chat_clients += account_name

		// This should be in new, but account name seems to have trouble with coming into existence.
	if(holder.holder.input)
		toggle_input(3, TRUE)
	clear_screen(10, TRUE)
	holder.holder.think(9)
	add_line("<font size=4>You have <b>[new_messages == 0 ? "no" : new_messages]</b> [new_messages == 1 ? "message." : "messages."]</font>")
	add_line("<font size=3>Username: - <u><i>[account_name]</i></u> -</font><br>")
	var/num = 1 // Replace num with a title later on
	for(var/datum/terminal_page/terminal_msg/terminal_msg in messages_dts)
		add_line(">> [num] - [terminal_msg.sent_at] - FROM: [terminal_msg.hidden_name ? "REDACTED" : terminal_msg.from], TO: [account_name] << [terminal_msg.seen ? "" : "<b>{*}</b>"]", 3, TRUE)
		num++
	if(!length(messages_dts))
		add_line(">> <B>NO MESSAGES</B> <<", 5, TRUE)
	add_line("-----------------", 5, TRUE)
	holder.holder.think(9)
	add_choice("#", "Open message by #", 2, TRUE)
	add_choice("SEND", "Send a message to another user", 2, TRUE)
	//add_choice("NAME", "Change the local username", 2, TRUE)
	if(return_to)
		add_choice("BACK", "RETURN TO { [return_to.name] }", 2, TRUE)
	if(!holder.holder.input)
		toggle_input(3, TRUE)
	return TRUE

/datum/terminal_page/my_messages/receive_string(string, mob/user)
	if(holder.holder.input)
		toggle_input(3, TRUE)
	if(!string)
		holder.holder.deny_sound()
		return
	else if(lowertext(string) == "back" && return_to)
		holder.load_page(return_to)
		return
	else if(lowertext(string) == "send")
		holder.load_page(message_sender)
		return
	/*
	else if(lowertext(string) == "name")
		holder.load_page(name_changer)
		return*/
	else
		var/numb = text2num(string)
		if(!isnum(numb) || numb > length(messages_dts))
			holder.holder.deny_sound(5)
			if(!holder.holder.input)
				toggle_input(3, TRUE)
			return
		var/msg = messages_dts[numb]
		if(!msg)
			holder.holder.deny_sound(5)
			if(!holder.holder.input)
				toggle_input(3, TRUE)
			return
		holder.load_page(msg)

/datum/terminal_page/my_messages/New(account_username, messages)
	if(!messages_dts && messages) messages_dts = messages
	// debug

	spawn(2 SECOND) // need the spawn 1 second.
		if(account_username) account_name = account_username
		else account_name = GenerateKey()
		message_sender = new /datum/terminal_page/send_message(account_name)
		name_changer = new /datum/terminal_page/name_change()
		message_sender.holder = holder
		name_changer.holder = holder
		if(message_sender.hidden) return
		GLOB.chat_clients[account_name] = src


/datum/terminal_page/name_change/load()
	//GLOB.chat_clients += account_name
	var/datum/terminal_page/my_messages/hub = holder.get_page("my_messages")
		// This should be in new, but account name seems to have trouble with coming into existence.
	if(holder.holder.input)
		toggle_input(3, TRUE)
	clear_screen(10, TRUE)
	holder.holder.think(9)
	add_line("- CURRENT USERNAME -", 10, TRUE)
	add_line("-{[ hub.account_name ]}-")
	add_line("-----------------", 5, TRUE)
	holder.holder.think(9)
	add_choice("ENTER", "The desired username", 2, TRUE)
	add_choice("BACK", "Return to { [holder.previous_page] }", 2, TRUE)
	if(!holder.holder.input)
		toggle_input(3, TRUE)
	return TRUE

/datum/terminal_page/name_change/receive_string(string, mob/user)
	if(!string)
		holder.holder.deny_sound()
		return
	string = lowertext(string)
	string = replacetext(string, " ", "_")
	string = copytext(string,1, 10)

	if(string in list("back", "redacted", "unknown", "high_command", "redistani_high_command", "blusnian_high_command", "admin"))
		holder.load_page(holder.previous_page)
		return
	else
		holder.holder.think(9, TRUE)
		var/datum/terminal_page/my_messages/hub = holder.get_page("my_messages")
		if(hub.message_sender.hidden)
			hub.account_name = string // Doesn't matter
			hub.message_sender.account_name = string
		if(!hub.message_sender.hidden)
			GLOB.chat_clients -= hub.account_name
			hub.account_name = string
			hub.message_sender.account_name = string
			GLOB.chat_clients[string] = hub
		holder.load_page(holder.previous_page)
		return


/datum/terminal_page/send_message
	var/account_name /// Same as my_messages.
	var/previous_page
	var/hidden = FALSE
	var/datum/terminal_page/my_messages/selected_user = null /// Lets us know if we've selected a user, must be a hub.

/datum/terminal_page/send_message/New(account_username)
	if(account_username && !account_name) account_name = account_username

/datum/terminal_page/send_message/load()
	if(!previous_page) previous_page = holder.previous_page
	if(holder.holder.input)
		toggle_input(3, TRUE)
	clear_screen(10, TRUE)
	// no user
	if(!selected_user)
		if(length(GLOB.chat_clients-account_name))
			add_line("-- AVAILABLE USERS:", 4, TRUE)
			holder.holder.think(9, TRUE)
			for(var/entry in GLOB.chat_clients-account_name)
				add_line(">> [entry] <<", 3, TRUE)
			holder.holder.think(9, TRUE)
			add_line("-- END OF AVAILABLE USERS", 5, TRUE)
			add_choice("ENTER", "An available username to send a message to", 2, TRUE)
			add_choice("BACK", "Return to { [holder.previous_page] }", 2, TRUE)
			if(!holder.holder.input)
				toggle_input(3, TRUE)
			return
		else
			add_line("-- NO AVAILABLE USERS --", 10, TRUE)
			holder.holder.think(9, TRUE)
			holder.load_page(previous_page)
			return
	// If we have a user
	add_line("> SELECTED USER: <b>[selected_user.account_name]</b> <", 10, TRUE)
	add_line("--  -- -- -- -- -- -- --<br>", 10, TRUE)
	add_choice("ENTER", "The contents of your message", 2, TRUE)
	add_choice("BACK", "Return to the hub", 2, TRUE)
	if(!holder.holder.input)
		toggle_input(3, TRUE)

/datum/terminal_page/send_message/proc/get_chatclient(string)
	var/chatter = GLOB.chat_clients[lowertext(string)]
	if(chatter != src)
		return chatter

/datum/terminal_page/send_message/receive_string(string, mob/user)
	if(!string)
		holder.holder.deny_sound()
		return
	else if(lowertext(string) == "back")
		selected_user = null
		holder.load_page(previous_page)
		return
	var/datum/terminal_page/my_messages/hub = holder.get_page("my_messages")
	if(!selected_user)
		if(hub.account_name == string)
			holder.holder.deny_sound()
			return
		selected_user = get_chatclient(string)
		if(!selected_user)
			holder.holder.deny_sound()
			return
		holder.load_page(src)
		return
	else
		selected_user.new_message(string, account_name, hidden)
		selected_user = null
		var/datum/terminal_page/terminal_msg/message = new (string, "OUTGOING", redacted = hidden)
		message.seen = TRUE
		hub.messages_dts += message
		message.holder = hub.holder
		holder.load_page(previous_page)
		message_admins("Message sent: [string]; by user: [user]")
		return

/datum/terminal_page/money_manager
	name = null
	var/previous_page = null /// I hate to do it over and over, but it's uselful
	var/account = null /// uses global faction money
	var/datum/terminal_page/cargo/supply = null /// The link to our cargo, should we be able to have cargo.
	var/visited = FALSE /// If we should show our logo when loaded.
	var/artillery = FALSE /// Display the artillery barrage page? Don't need cargo for this to be available

/datum/terminal_page/money_manager/proc/get_money_sum()
	return GLOB.faction_dosh[account]

/datum/terminal_page/money_manager/proc/has_enough_money(price)

	return GLOB.faction_dosh[account] >= price

/datum/terminal_page/money_manager/proc/grant_money(amount)

	return GLOB.faction_dosh[account] += amount

/datum/terminal_page/money_manager/proc/remove_money(amount)

	GLOB.faction_dosh[account] -= amount
	if(get_money_sum() < 0)
		GLOB.faction_dosh[account] = 0
	return get_money_sum()

/datum/terminal_page/money_manager/New(var/list/args) //List is products for cargo <3 snowflake cargo supply datums!
	spawn(20) // not that much of an issue if we sleep it a bit. to-do: fix the holder issue
		account = args[1]					// account_id, default_dosh, has_cargo, cargo_name, cargo_page_name, cargo_pad_override, list())
		if(!get_money_sum()) // In the event it isn't in the list.
			GLOB.faction_dosh[account] = args[2]
		var/arty = /datum/snowflake_supply/artillery
		if(arty in args[7])
			args[7] -= arty
			//artillery = TRUE // REENABLE WHEN ARTY'S DONE
		if(args[3])
			supply = new (cargo_name = args[4], pad_override = args[6], products = args[7], manager = src)
			supply.holder = holder
			name = args[5]
			spawn(50)
				if(!holder.get_page(name))
					holder.page_registry[name] = src

/datum/terminal_page/money_manager/load()
	if(!previous_page) previous_page = holder.previous_page

	if(!visited)
		visited = TRUE
		clear_screen(6, TRUE)
		holder.holder.think(9, TRUE) // we need like a cool logo loading bs thing :sob:
		add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: center;'><b>Brass.Co - \"Serving all your needs!\"</b></legend></	fieldset>", 15, TRUE)
		holder.holder.think(9, TRUE)

	clear_screen(6, TRUE)
	if(holder.holder.input)
		toggle_input(3, TRUE)
	holder.holder.think(6, TRUE)
	add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: center;'><b>> [account] - [get_money_sum()] <</b></legend></fieldset>", 6, TRUE)
	holder.holder.think(9, TRUE)
	add_choice("SUPPLY", "access the [supply.display_name]", 2, TRUE)
	if(artillery)
		holder.holder.think(5, TRUE)
		add_choice("ARTILLERY", "access the artillery barrage control menu", 2, TRUE)
	add_choice("BALANCE", "refresh the visible balance", 4)
	if(previous_page)
		add_choice("BACK", "return to the main screen", 3, TRUE)
	holder.holder.think(3, TRUE)
	if(!holder.holder.input)
		toggle_input(3, TRUE)

/datum/terminal_page/money_manager/receive_string(string, mob/user)
	if(holder.holder.input)
		toggle_input(3, TRUE)
	if(!string)
		holder.holder.think(7, TRUE)
		holder.holder.deny_sound(4)
		holder.load_page(src)
		return
	string = lowertext(string)
	if(string == "back" && previous_page)
		holder.holder.think(7, TRUE)
		holder.load_page(previous_page)
		return
	else if(string == "supply")
		holder.holder.think(7, TRUE)
		holder.load_page(supply)
		return

/datum/terminal_page/cargo
	var/display_name = "" /// Display name for the manager to show. different than internal page name
	var/datum/terminal_page/money_manager/manager = null /// we belong to this. We do not exist otherwise
	var/list/categories = list() /// Storing cargo_cat's here
	var/pad_override /// Cargo pad ID override
	var/datum/terminal_page/cargo_calibration/calib_page = null
	var/list/pads = list()

/datum/terminal_page/cargo/New(cargo_name, pad_override, list/products, manager)
	sleep(50)
	src.manager = manager
	src.display_name = cargo_name


	src.pad_override = pad_override
	if(!pad_override)	src.pad_override = src.manager.account // pull the account Id if we don't have a pad override.

	// Here we fucking go..
	var/list/temporary_storage = list()
	for(var/type in products)
		var/datum/snowflake_supply/S = new type()
		if(!S.name) S.name = S.type // << Initializing this bullshit, but if it doesnt have a name ufck you fUCK YOU FUCK YOU
		if(!S.category) S.category = "Undefined"
		temporary_storage[S] = S.category
		// Put them under the lists..

	// second filtration
	for(var/catego in temporary_storage)
		catego = temporary_storage[catego]
		var/list/sorted = list()
		for(var/datum/snowflake_supply/product in temporary_storage)
			if(product.category != catego)
				continue
			sorted |= product

		var/datum/terminal_page/cargo_cat/category = new(catego, sorted)

		var/datum/terminal_page/cargo_calibration/calibratory = new(pad_override, src)
		calib_page = calibratory

		category.supply = src
		categories[lowertext(catego)] = category
		spawn(10)
			calibratory.holder = src.manager.holder
			category.holder = src.manager.holder


/datum/terminal_page/cargo/proc/get_Category(string)
	return categories[lowertext(string)]

/datum/terminal_page/cargo/load()
	clear_screen(6, TRUE)
	if(holder.holder.input)
		toggle_input(3, TRUE)
	holder.holder.think(6, TRUE)
	add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: center;'><b>> AVAILABLE CATEGORIES <</b></legend>", 4, TRUE)
	holder.holder.think(9, TRUE)
	var/num = 1
	for(var/cat in categories)
		add_choice(num, cat, rand(2,5), TRUE)
		num++
	add_line("</fieldset>", 6, TRUE)
	add_choice("ENTER", "a corresponding number to view the category", 2, TRUE)
	add_choice("CALIBRATE", "send out a ping to the nearby teleport pads", 2, TRUE)
	add_choice("BALANCE", "inspect the balance of the current account", 4)
	add_choice("BACK", "return to the main fund management screen", 3, TRUE)
	holder.holder.think(3, TRUE)
	if(!holder.holder.input)
		toggle_input(3, TRUE)

/datum/terminal_page/cargo/receive_string(string, mob/user)
	if(holder.holder.input)
		toggle_input(3, TRUE)
	if(!string)
		holder.holder.think(7, TRUE)
		holder.holder.deny_sound(4)
		holder.load_page(src)
		return
	string = lowertext(string)
	if(string == "back")
		holder.holder.think(7, TRUE)
		holder.load_page(manager)
		return
	if(string == "calibrate")
		holder.holder.think(8)
		holder.load_page(calib_page)
		return
	else if(string == "balance")
		clear_screen(4, TRUE)
		holder.holder.think(7, TRUE)
		add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: center;'><b>> [manager.account] <</b></legend>", 6, TRUE)
		holder.holder.think(7, TRUE)
		add_line("<center><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: left;'><b>> [manager.get_money_sum()] <</b></legend></center></fieldset>", 20, TRUE)
		holder.load_page(src)
		return
	if(categories[text2num(string)])
		holder.holder.think(3, TRUE)
		holder.holder.think(4, TRUE)
		var/page = categories[text2num(string)]
		holder.load_page(categories[page])
		return
	else
		holder.holder.deny_sound(3)
		holder.holder.think(7)
		holder.load_page(src)
		return

/datum/terminal_page/cargo_calibration
	var/id
	var/list/pads = null
	var/datum/terminal_page/cargo/hell

/datum/terminal_page/cargo_calibration/New(id, kargo)
	src.id = id
	hell = kargo

/datum/terminal_page/cargo_calibration/proc/pingpads()
	for(var/obj/structure/cargo_pad/pad in pads)
		pad.pingpad()

/datum/terminal_page/cargo_calibration/load()
	clear_screen(2)
	holder.holder.think(5)
	pads = GLOB.cargo_pads[id]
	add_line("Ping 1<br>", 6, TRUE, FALSE)
	pingpads()
	add_line("Ping 2<br>", 6, TRUE, FALSE)
	pingpads()
	add_line("Ping 3<br>", 6, TRUE, FALSE)
	pingpads()
	add_line("Ping 4<br>", 6, TRUE, FALSE)
	pingpads()
	add_line("Ping 5<br>", 6, TRUE, FALSE)
	pingpads()
	add_line("Ping 6<br>", 6, TRUE, FALSE)
	holder.holder.think(6, TRUE)
	hell.pads = src.pads
	holder.load_page(holder.previous_page)

/datum/terminal_page/cargo_cat
	var/category
	var/list/contents
	var/datum/terminal_page/cargo/supply
	var/state = 0 /// Used to control if we're making sure we want to purchase smth, 0 is idle, 1 is yes
	var/datum/snowflake_supply/selected = null

/datum/terminal_page/cargo_cat/New(category, temporary_storage	)
	src.category = category
	contents = temporary_storage

/datum/terminal_page/cargo_cat/load()
	if(holder.holder.input)
		toggle_input(0, TRUE)
	clear_screen(6, TRUE)
	holder.holder.think(6, TRUE)
	add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: left;'><b>> AVAILABLE PRODUCTS <</b></legend>", 4, TRUE)
	holder.holder.think(9, TRUE)
	var/num = 1
	for(var/product in contents)
		add_choice(num, product, rand(2,5), TRUE)
		num++
	add_line("</fieldset>", 6, TRUE)
	add_choice("ENTER", "a corresponding number to purchase the listed product", 2, TRUE)
	add_choice("BALANCE", "inspect the balance of the current account", 4)
	add_choice("BACK", "return to the main fund management screen", 3, TRUE)
	holder.holder.think(3, TRUE)
	if(!holder.holder.input)
		toggle_input(3, TRUE)

/datum/terminal_page/cargo_cat/receive_string(string, mob/user)

	if(holder.holder.input)
		toggle_input(3, TRUE)
	if(string && state)

		if(!supply.manager.has_enough_money(selected.price))
			clear_screen(3)
			holder.holder.deny_sound(5)
			holder.holder.think(7)
			add_line("TO PURCHASE [selected.name]", 4, TRUE, FALSE)
			add_line("YOU REQUIRE: [supply.manager.get_money_sum() - selected.price] CREDITS", 7, TRUE, FALSE)
			selected = null
			state = 0
			holder.load_page(src)
			return

		clear_screen(3)

		if(string == "y")

			if(!length(supply.pads) && selected.container != null)
				holder.holder.think(9)
				add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: left;' class='blink'><b>CRITICAL ERROR</b></legend>", 7, TRUE)
				holder.holder.think(7)
				add_line("<legend style='background-color: [holder.holder.Textcolor]; color: black;'>NO PADS DETECTED</legend>", 3, TRUE)
				add_line("<legend style='background-color: [holder.holder.Textcolor]; color: black;'>ATTEMPT CALIBRATION OR CONSULT A QUALIFIED TECHNICIAN</legend></fieldset>", 8, TRUE)
				holder.holder.think(7)
				state = 0
				selected = null
				holder.load_page(src)
				return

			var/obj/structure/cargo_pad/pad = safepick(supply.pads)

			if(!pad && selected.container)
				holder.holder.think(7)
				state = 0
				selected = null
				holder.load_page(src)
				return
			if(selected.container == null)
				selected.Spawn(holder.holder.loc)
				supply.manager.remove_money(selected.price)
				holder.holder.think(7)
				selected = null
				state = 0
				holder.load_page(src)
				return
			pad.handle_spawn(selected)
			supply.manager.remove_money(selected.price)
			holder.holder.think(7)
			selected = null
			state = 0
			holder.load_page(src)
			return
		if(string == "n")
			add_line("CANCELLED OPERATION -- RETURNING", 8, TRUE)
			holder.holder.think(7)
			selected = null
			state = 0
			holder.load_page(src)
			return
		else
			holder.load_page(src)
			holder.holder.think(7)
			selected = null
			state = 0
			return
	if(!string)
		holder.holder.think(7, TRUE)
		holder.holder.deny_sound(4)
		selected = null
		state = 0
		holder.load_page(src)
		return
	string = lowertext(string)
	if(string == "back" && !state)
		holder.holder.think(7, TRUE)
		selected = null
		state = 0
		holder.load_page(supply)
		return
	else if(string == "balance" && !state)
		clear_screen(4, TRUE)
		holder.holder.think(7, TRUE)
		add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: center;'><b>> [supply.manager.account] <</b></legend>", 6, TRUE)
		holder.holder.think(7, TRUE)
		add_line("<center><legend style='background-color: [holder.holder.Textcolor]; color: black; margin-left: 1em; text-transform: uppercase; text-align: left;'><b>> [supply.manager.get_money_sum()] <</b></legend></center></fieldset>", 20, TRUE)
		selected = null
		state = 0
		holder.load_page(src)
		return
	if(string && !state)
		if(contents[text2num(string)])
			var/datum/snowflake_supply/snowflake = contents[text2num(string)]
			if(!supply.manager.has_enough_money(snowflake.price))
				clear_screen(3)
				holder.holder.deny_sound(5)
				holder.holder.think(7)
				add_line("BALANCE IS TOO LOW TO PURCHASE [snowflake.name]", 4, TRUE, FALSE)
				add_line("YOU REQUIRE: [supply.manager.get_money_sum() - snowflake.price] CREDITS", 7, TRUE, FALSE)
				holder.load_page(src)
				selected = null
				state = 0
				return
			state = 1
			selected = snowflake
			clear_screen(3)
			holder.holder.think(7, TRUE)
			add_line("<fieldset style='margin: 15px 0; opacity: 0.75; border: 3px double [holder.holder.Textcolor]; padding: 2px;'><legend style='background-color: [holder.holder.Textcolor]; color: black; 	margin-left: 1em; text-transform: uppercase; text-align: center;'><b>> [snowflake.name] - [snowflake.price] <</b></legend>", 6, TRUE)
			add_line("<span><center>[snowflake.description ? snowflake.description : "NO DESCRIPTION"]</center></span></fieldset>")
			holder.holder.think(7, TRUE)
			add_choice("Y", "Confirm purchase", 5, TRUE)
			add_choice("N", "Cancel purchase", 3, TRUE)
			holder.holder.think(7)
			if(!holder.holder.input)
				toggle_input(3, TRUE)
			return
		else
			holder.holder.deny_sound(3)
			holder.holder.think(7)

/obj/machinery/kaos
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_machine"

	var/input = FALSE /// Do not touch this. Used for checks to see if the input link is visible.

	var/t = "" /// Do not touch this. This handles the text that's visible. t = text.

	var/is_bordered = TRUE /// Window borders.

	var/window_width = 700 /// Self explanatory.
	var/window_height = 650 /// Self explanatory.

	var/is_powered_on = FALSE /// Self explanatory.

	var/input_link = "<form id='input_form' action='?src=%SRC' method='get'><input type='hidden' name='src' value='%SRC' autocomplete=off><input type='hidden' id='terminal_input' name='terminal_input' value='string_input'><input type='text' id='string' name='string' autofocus><input id='submit_button' type='submit' value='' tabindex='-1'></form>"  /// The input bar, %SRC is replaced with \ref[src] at runtime. // Did it like this incase subtype's meant to have a different look/structure to it

	var/datum/terminal_page_controller/controller /// do NOT touch this, unless you subtype it.

	var/bootup_sound = 'sound/effects/new_comp/bootup.ogg' /// Plays on bootup
	var/bootup_duration = 6.492 SECONDS /// Bootup duration, self explanatory

	var/idle_sfx = 'sound/effects/new_comp/idle_run.ogg' /// Looping sound, plays continously post-bootup.

	var/load_sfx = 'sound/effects/new_comp/load.ogg' /// Self explanatory, sfx for loading new pages

	var/list/think_sfx = list('sound/effects/new_comp/think1.ogg', 'sound/effects/new_comp/think2.ogg') /// Generally used for short loading, or when the computer's 'thinking'.
	var/last_think  /// just so people don't keep getting the same sound over and over, it's grating.

	var/list/clear_sfx = list('sound/effects/new_comp/clear1.ogg', 'sound/effects/new_comp/clear2.ogg') /// Played when the screen's cleared. Self explanatory other than that.
	var/last_clear  /// just so people don't keep getting the same sound over and over, it's grating.

	var/list/input_sfx = list('sound/effects/new_comp/input1.ogg', 'sound/effects/new_comp/input2.ogg', 'sound/effects/new_comp/input3.ogg') /// SFX to pick from when typing/inputting
	var/last_input /// Ditto. Same as last_think.

	var/deny_sfx = 'sound/effects/new_comp/deny.ogg' /// Plays when the input command is invalid, may be used for other stuff

	var/mail_sfx = 'sound/effects/new_comp/mail.ogg' /// Used exclusively for the built in messaging system.

	var/print_sfx = 'sound/effects/new_comp/print.ogg' /// Print SFX, call when the comp's printing stuff.
	var/print_duration = 9.838 SECONDS

	var/datum/sound_token/sound_token /// Do not touch this. It is responsible for the looping sfx.
	var/sound_id /// Do not touch this. It is responsible for the unique sound token ID. :pray:

	// CSS //
	var/Textcolor = "gold"
	var/bgcolor = "black"

	var/style_override = ""

	/// Current format is:
	/// list(
	///	page datum type,
	/// page arg1,
	/// page arg2,
	/// )
	/// ETC

	/// In the event its multiselect, you can pass ARG1 as a list of pages it will show, and ARG2 as it's own name to be referenced.
	/// example:
	/// list("code = "code you have to type to visit this page", "page_name" = "internal name for the page to visit", "name" = "the shown name, can be HTML")
	var/tmp/list/pages = list(
		list(
			/datum/terminal_page/multiselect,
			list(
				list("code" = "1", "page_name" = "PAGE 2", "name" = "SECOND PAGE"),
				list("code" = "2", "page_name" = "msg_staff_login", "name" = "MESSAGE COMMAND")
				),
			"PAGE 1"
		),
		list(
			/datum/terminal_page/multiselect,
			list(
				list("code" = "1", "page_name" = "PAGE 1", "name" = "FIRST PAGE"),
				list("code" = "2", "page_name" = "my_messages", "name" = "MESSAGE HUB" ),
				list("code" = "3", "page_name" = "money_manager_main", "name" = "FUND MANAGEMENT - MAIN" ),
				list("code" = "4", "page_name" = "money_manager_captain_login", "name" = "FUND MANAGEMENT - PRIVATE" )
				),
			"PAGE 2"
		),
		list(
			/datum/terminal_page/message_staff,
			null,
			null
		),
		list(
			/datum/terminal_page/login,
			list("%CARGO", "msg_staff_login", "message_staff"), // list("password", "name", "redirect_to")
			null
		),
		list(
			/datum/terminal_page/my_messages,
			null,
			null
		),
		list(
			/datum/terminal_page/money_manager,
			list(RED_TEAM, 500, TRUE, "R.E.D. CATALOGUE", "money_manager_main", RED_TEAM, list(/datum/snowflake_supply/shotgun_ammo_pack,/datum/snowflake_supply/rifle_ammo_pack,/datum/snowflake_supply/pistol_ammo_pack,/datum/snowflake_supply/revolver_ammo_pack,/datum/snowflake_supply/soulburn_ammo_pack,/datum/snowflake_supply/hmg_ammo_pack,/datum/snowflake_supply/warmonger_ammo,/datum/snowflake_supply/flamethrower_ammo_pack,/datum/snowflake_supply/ptsd_ammo_pack,/datum/snowflake_supply/mortar_ammo,/datum/snowflake_supply/illumination_mortar_red,/datum/snowflake_supply/shotgun_pack,/datum/snowflake_supply/pistol_pack,/datum/snowflake_supply/harbinger_pack,/datum/snowflake_supply/warmonger_pack,/datum/snowflake_supply/shovel_pack,/datum/snowflake_supply/doublebarrel_shotgun_pack,/datum/snowflake_supply/bolt_action_rifle_pack,/datum/snowflake_supply/soulburn_pack,/datum/snowflake_supply/flamethrower_pack,/datum/snowflake_supply/frag_grenade_pack,/datum/snowflake_supply/trench_club_pack,/datum/snowflake_supply/mortar_pack,/datum/snowflake_supply/gas_mask_pack,/datum/snowflake_supply/barbwire_pack,/datum/snowflake_supply/canned_food_pack,/datum/snowflake_supply/bodybag_pack,/datum/snowflake_supply/cigarette_pack,/datum/snowflake_supply/first_aid_pack,/datum/snowflake_supply/advanced_first_aid_pack,/datum/snowflake_supply/medical_belt_pack,/datum/snowflake_supply/booze_pack,/datum/snowflake_supply/atepoine_pack,/datum/snowflake_supply/blood_injector_pack,/datum/snowflake_supply/smoke_grenade_pack,/datum/snowflake_supply/job/unit_red_sniper,/datum/snowflake_supply/job/unit_red_flametrooper,/datum/snowflake_supply/job/unit_red_sentry,/datum/snowflake_supply/reinforcements/red)
), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null																												// List of cargo is just datum snowflake types
		),
		list(
			/datum/terminal_page/money_manager,
			list(RED_TEAM, 500, TRUE, "EXCLUSIVE CATALOGUE", "money_manager_captain", "Redcoats_C", list(/datum/snowflake_supply/booze_pack, /datum/snowflake_supply/cigarette_pack, /datum/snowflake_supply/artillery)), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null																												// List of cargo is just datum snowflake types
		),
		list(
			/datum/terminal_page/login,
			list("%CARGO", "money_manager_captain_login", "money_manager_captain"), // list("password", "name", "redirect_to")
			null
		)
		)

/obj/machinery/kaos/bluecaptain
	Textcolor = "cyan"
	pages = list(
		list(
			/datum/terminal_page/multiselect,
			list(
				list("code" = "1", "page_name" = "PAGE 2", "name" = "SECOND PAGE"),
				list("code" = "2", "page_name" = "msg_staff_login", "name" = "MESSAGE COMMAND")
				),
			"PAGE 1"
		),
		list(
			/datum/terminal_page/multiselect,
			list(
				list("code" = "1", "page_name" = "PAGE 1", "name" = "FIRST PAGE"),
				list("code" = "2", "page_name" = "my_messages", "name" = "MESSAGE HUB" ),
				list("code" = "3", "page_name" = "money_manager_main", "name" = "FUND MANAGEMENT - MAIN" ),
				list("code" = "4", "page_name" = "money_manager_captain_login", "name" = "FUND MANAGEMENT - PRIVATE" )
				),
			"PAGE 2"
		),
		list(
			/datum/terminal_page/message_staff,
			null,
			null
		),
		list(
			/datum/terminal_page/login,
			list("%CARGO", "msg_staff_login", "message_staff"), // list("password", "name", "redirect_to")
			null
		),
		list(
			/datum/terminal_page/my_messages,
			"blucaptain",
			null
		),
		list(
			/datum/terminal_page/money_manager,
			list(BLUE_TEAM, 500, TRUE, "B.L.U.E. CATALOGUE", "money_manager_main", BLUE_TEAM, list(/datum/snowflake_supply/shotgun_ammo_pack,/datum/snowflake_supply/rifle_ammo_pack,/datum/snowflake_supply/pistol_ammo_pack,/datum/snowflake_supply/revolver_ammo_pack,/datum/snowflake_supply/soulburn_ammo_pack,/datum/snowflake_supply/hmg_ammo_pack,/datum/snowflake_supply/warmonger_ammo,/datum/snowflake_supply/flamethrower_ammo_pack,/datum/snowflake_supply/ptsd_ammo_pack,/datum/snowflake_supply/mortar_ammo,/datum/snowflake_supply/illumination_mortar_blue,/datum/snowflake_supply/shotgun_pack,/datum/snowflake_supply/pistol_pack,/datum/snowflake_supply/harbinger_pack,/datum/snowflake_supply/warmonger_pack,/datum/snowflake_supply/shovel_pack,/datum/snowflake_supply/doublebarrel_shotgun_pack,/datum/snowflake_supply/bolt_action_rifle_pack,/datum/snowflake_supply/soulburn_pack,/datum/snowflake_supply/flamethrower_pack,/datum/snowflake_supply/frag_grenade_pack,/datum/snowflake_supply/trench_club_pack,/datum/snowflake_supply/mortar_pack,/datum/snowflake_supply/gas_mask_pack,/datum/snowflake_supply/barbwire_pack,/datum/snowflake_supply/canned_food_pack,/datum/snowflake_supply/bodybag_pack,/datum/snowflake_supply/cigarette_pack,/datum/snowflake_supply/first_aid_pack,/datum/snowflake_supply/advanced_first_aid_pack,/datum/snowflake_supply/medical_belt_pack,/datum/snowflake_supply/booze_pack,/datum/snowflake_supply/atepoine_pack,/datum/snowflake_supply/blood_injector_pack,/datum/snowflake_supply/smoke_grenade_pack,/datum/snowflake_supply/job/unit_blue_sniper,/datum/snowflake_supply/job/unit_blue_flametrooper,/datum/snowflake_supply/job/unit_blue_sentry,/datum/snowflake_supply/reinforcements/blue)), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)// list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null																												// List of cargo is just datum snowflake types
		),
		list(
			/datum/terminal_page/money_manager,
			list(BLUE_TEAM, 500, TRUE, "EXCLUSIVE CATALOGUE", "money_manager_captain", "Bluecoats_C", list(/datum/snowflake_supply/booze_pack, /datum/snowflake_supply/cigarette_pack, /datum/snowflake_supply/artillery)), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null																												// List of cargo is just datum snowflake types
		),
		list(
			/datum/terminal_page/login,
			list("%CARGO", "money_manager_captain_login", "money_manager_captain"), // list("password", "name", "redirect_to")
			null
		)
		)

/obj/machinery/kaos/redcaptain
	pages = list(
		list(
			/datum/terminal_page/multiselect,
			list(
				list("code" = "1", "page_name" = "PAGE 2", "name" = "SECOND PAGE"),
				list("code" = "2", "page_name" = "msg_staff_login", "name" = "MESSAGE COMMAND")
				),
			"PAGE 1"
		),
		list(
			/datum/terminal_page/multiselect,
			list(
				list("code" = "1", "page_name" = "PAGE 1", "name" = "FIRST PAGE"),
				list("code" = "2", "page_name" = "my_messages", "name" = "MESSAGE HUB" ),
				list("code" = "3", "page_name" = "money_manager_main", "name" = "FUND MANAGEMENT - MAIN" ),
				list("code" = "4", "page_name" = "money_manager_captain_login", "name" = "FUND MANAGEMENT - PRIVATE" )
				),
			"PAGE 2"
		),
		list(
			/datum/terminal_page/message_staff,
			null,
			null
		),
		list(
			/datum/terminal_page/login,
			list("%CARGO", "msg_staff_login", "message_staff"), // list("password", "name", "redirect_to")
			null
		),
		list(
			/datum/terminal_page/my_messages,
			"redcaptain",
			null
		),
		list(
			/datum/terminal_page/money_manager,
			list(RED_TEAM, 500, TRUE, "R.E.D. CATALOGUE", "money_manager_main", RED_TEAM, list(/datum/snowflake_supply/shotgun_ammo_pack,/datum/snowflake_supply/rifle_ammo_pack,/datum/snowflake_supply/pistol_ammo_pack,/datum/snowflake_supply/revolver_ammo_pack,/datum/snowflake_supply/soulburn_ammo_pack,/datum/snowflake_supply/hmg_ammo_pack,/datum/snowflake_supply/warmonger_ammo,/datum/snowflake_supply/flamethrower_ammo_pack,/datum/snowflake_supply/ptsd_ammo_pack,/datum/snowflake_supply/mortar_ammo,/datum/snowflake_supply/illumination_mortar_red,/datum/snowflake_supply/shotgun_pack,/datum/snowflake_supply/pistol_pack,/datum/snowflake_supply/harbinger_pack,/datum/snowflake_supply/warmonger_pack,/datum/snowflake_supply/shovel_pack,/datum/snowflake_supply/doublebarrel_shotgun_pack,/datum/snowflake_supply/bolt_action_rifle_pack,/datum/snowflake_supply/soulburn_pack,/datum/snowflake_supply/flamethrower_pack,/datum/snowflake_supply/frag_grenade_pack,/datum/snowflake_supply/trench_club_pack,/datum/snowflake_supply/mortar_pack,/datum/snowflake_supply/gas_mask_pack,/datum/snowflake_supply/barbwire_pack,/datum/snowflake_supply/canned_food_pack,/datum/snowflake_supply/bodybag_pack,/datum/snowflake_supply/cigarette_pack,/datum/snowflake_supply/first_aid_pack,/datum/snowflake_supply/advanced_first_aid_pack,/datum/snowflake_supply/medical_belt_pack,/datum/snowflake_supply/booze_pack,/datum/snowflake_supply/atepoine_pack,/datum/snowflake_supply/blood_injector_pack,/datum/snowflake_supply/smoke_grenade_pack,/datum/snowflake_supply/job/unit_red_sniper,/datum/snowflake_supply/job/unit_red_flametrooper,/datum/snowflake_supply/job/unit_red_sentry,/datum/snowflake_supply/reinforcements/red)
), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null																												// List of cargo is just datum snowflake types
		),
		list(
			/datum/terminal_page/money_manager,
			list(RED_TEAM, 500, TRUE, "EXCLUSIVE CATALOGUE", "money_manager_captain", "Redcoats_C", list(/datum/snowflake_supply/booze_pack, /datum/snowflake_supply/cigarette_pack, /datum/snowflake_supply/artillery)), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null																												// List of cargo is just datum snowflake types
		),
		list(
			/datum/terminal_page/login,
			list("%CARGO", "money_manager_captain_login", "money_manager_captain"), // list("password", "name", "redirect_to")
			null
		)
		)


/obj/machinery/kaos/redcargo
	pages = list(
			list(
			/datum/terminal_page/money_manager,
			list(RED_TEAM, 500, TRUE, "B.L.U.E. CATALOGUE", "money_manager_main", RED_TEAM, list(/datum/snowflake_supply/shotgun_ammo_pack,/datum/snowflake_supply/rifle_ammo_pack,/datum/snowflake_supply/pistol_ammo_pack,/datum/snowflake_supply/revolver_ammo_pack,/datum/snowflake_supply/soulburn_ammo_pack,/datum/snowflake_supply/hmg_ammo_pack,/datum/snowflake_supply/warmonger_ammo,/datum/snowflake_supply/flamethrower_ammo_pack,/datum/snowflake_supply/ptsd_ammo_pack,/datum/snowflake_supply/mortar_ammo,/datum/snowflake_supply/illumination_mortar_red,/datum/snowflake_supply/shotgun_pack,/datum/snowflake_supply/pistol_pack,/datum/snowflake_supply/harbinger_pack,/datum/snowflake_supply/warmonger_pack,/datum/snowflake_supply/shovel_pack,/datum/snowflake_supply/doublebarrel_shotgun_pack,/datum/snowflake_supply/bolt_action_rifle_pack,/datum/snowflake_supply/soulburn_pack,/datum/snowflake_supply/flamethrower_pack,/datum/snowflake_supply/frag_grenade_pack,/datum/snowflake_supply/trench_club_pack,/datum/snowflake_supply/mortar_pack,/datum/snowflake_supply/gas_mask_pack,/datum/snowflake_supply/barbwire_pack,/datum/snowflake_supply/canned_food_pack,/datum/snowflake_supply/bodybag_pack,/datum/snowflake_supply/cigarette_pack,/datum/snowflake_supply/first_aid_pack,/datum/snowflake_supply/advanced_first_aid_pack,/datum/snowflake_supply/medical_belt_pack,/datum/snowflake_supply/booze_pack,/datum/snowflake_supply/atepoine_pack,/datum/snowflake_supply/blood_injector_pack,/datum/snowflake_supply/smoke_grenade_pack,/datum/snowflake_supply/job/unit_red_sniper,/datum/snowflake_supply/job/unit_red_flametrooper,/datum/snowflake_supply/job/unit_red_sentry,/datum/snowflake_supply/reinforcements/red)), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null)
			)
/obj/machinery/kaos/bluecargo
	Textcolor = "cyan"
	pages = list(
			list(
			/datum/terminal_page/money_manager,
			list(BLUE_TEAM, 500, TRUE, "B.L.U.E. CATALOGUE", "money_manager_main", BLUE_TEAM, list(/datum/snowflake_supply/shotgun_ammo_pack,/datum/snowflake_supply/rifle_ammo_pack,/datum/snowflake_supply/pistol_ammo_pack,/datum/snowflake_supply/revolver_ammo_pack,/datum/snowflake_supply/soulburn_ammo_pack,/datum/snowflake_supply/hmg_ammo_pack,/datum/snowflake_supply/warmonger_ammo,/datum/snowflake_supply/flamethrower_ammo_pack,/datum/snowflake_supply/ptsd_ammo_pack,/datum/snowflake_supply/mortar_ammo,/datum/snowflake_supply/illumination_mortar_blue,/datum/snowflake_supply/shotgun_pack,/datum/snowflake_supply/pistol_pack,/datum/snowflake_supply/harbinger_pack,/datum/snowflake_supply/warmonger_pack,/datum/snowflake_supply/shovel_pack,/datum/snowflake_supply/doublebarrel_shotgun_pack,/datum/snowflake_supply/bolt_action_rifle_pack,/datum/snowflake_supply/soulburn_pack,/datum/snowflake_supply/flamethrower_pack,/datum/snowflake_supply/frag_grenade_pack,/datum/snowflake_supply/trench_club_pack,/datum/snowflake_supply/mortar_pack,/datum/snowflake_supply/gas_mask_pack,/datum/snowflake_supply/barbwire_pack,/datum/snowflake_supply/canned_food_pack,/datum/snowflake_supply/bodybag_pack,/datum/snowflake_supply/cigarette_pack,/datum/snowflake_supply/first_aid_pack,/datum/snowflake_supply/advanced_first_aid_pack,/datum/snowflake_supply/medical_belt_pack,/datum/snowflake_supply/booze_pack,/datum/snowflake_supply/atepoine_pack,/datum/snowflake_supply/blood_injector_pack,/datum/snowflake_supply/smoke_grenade_pack,/datum/snowflake_supply/job/unit_blue_sniper,/datum/snowflake_supply/job/unit_blue_flametrooper,/datum/snowflake_supply/job/unit_blue_sentry,/datum/snowflake_supply/reinforcements/blue)), // list(Money ID in accordnace with the global list of dosh, Whether it has cargo, page name, Cargo name, cargo pad override, list of cargo shit)
			null)
			)

GLOBAL_LIST_EMPTY(terminals)
// THIS CODE IS FUCKING INSANE Oh MY GOd
/obj/machinery/kaos/New()
	. = ..()
	GLOB.terminals["[x][y][z]"] = src

	var/list/fuck = list()
	for(var/t in pages)
		var/agh = t[1]
		var/page = new agh(t[2], t[3])
		fuck += page
	pages = fuck

	if(!length(pages) || length(pages) !=  length(fuck))
		message_admins("Failed to create pages at [src], (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>")

	controller = new(pages)
	controller.holder = src

	if(findtext(input_link, "%SRC"))
		input_link = replacetext(input_link, "%SRC", "\ref[src]")

	sound_id = "[type]_[sequential_id(type)]"

/obj/machinery/kaos/RightClick(mob/user)
	. = ..()
	is_powered_on = !is_powered_on
	if (is_powered_on)
		power_on(user)
	else
		if(!input) // prevent issues.
			return
		power_off(user)

/obj/machinery/kaos/attack_hand(mob/user)
	if (is_powered_on)
		show_page(user)
		return
	else
		is_powered_on = !is_powered_on
		power_on(user)

/obj/machinery/kaos/proc/show_page(mob/user)
	user << browse({"
	<HTML style="background: black; border-radius: 0px; border: 0px;;>
	<HEAD>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<TITLE>[name]</TITLE>
	<link href="https://fonts.cdnfonts.com/css/perfect-dos-vga-437" rel="stylesheet"> <!--Fuck this shit I'm just going to import it.-->
	<!-- TO:DO Replace this with an actual font file oh my god -->
	<script type="text/javascript" src="jquery.min.js"></script>

	<style>

	* {
		font-family: "Perfect DOS VGA 437";
		padding: 0px;
		margin: 0px;
		font-size: 18px;
		letter-spacing:0;
		line-height: 100%;
		border: 0px;
  		-ms-overflow-style: none;  /* IE and Edge */
  		scrollbar-width: none;  /* Firefox */
	}

	body {
		color: [Textcolor];
		text-shadow: [Textcolor] 0px 0px 8px;
		height: 100%;
		position: relative;
	}

	#submit_button {
		position: relative;
		width: 0px;
		height: 0px;
		left: -9999px;
	}

	#string {
		color: [Textcolor];
		height: 16px;
		width: 97%;
		background-color: transparent;
		text-shadow: [Textcolor] 0px 0px 8px;
		box-shadow: [Textcolor] 0px 0px 8px;
		border: 1px solid [Textcolor];
		padding: 3px;
		caret-color: [Textcolor];
		margin-bototm: 2px;
	}

	.scanlines {
		position: absolute;
		width: 100%;
		height: 100%;
		top: 0;
		left: 0;
		background: linear-gradient(0deg,
			rgba(0,0,0,0) 50%,
			rgba(0,0,0,0.3) 50%);
		background-size: 100% 5px;
		pointer-events: none;
		animation: scanline 1s linear infinite;
		z-index: 9999;
	}

	@keyframes scanline {
		from { transform: translateY(-4px); }
		to { transform: translateY(0); }
	}

	.main {
		height: 100%;
		width: 95%;
		display: block;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		margin: auto;
		margin-top: 3%;
		gap: 1em; /* adds spacing between elements */
		overflow: visible; /* avoids clipping if content overflows */
	}
	</style>
	<style>[style_override]</style>
	</HEAD>
	<body>
	<div class="scanlines"></div>
	<div class='main'>
	<span>[t]</span>
	[input ? input_link : ""]
	</div>
	<script>

		setInterval(blink, 500);


		function blink() {
			$('.blink').each(function(){
				var backColor = $(this).css('background-color');
				var textColor = $(this).css('color');
				var backShadow = $(this).css('box-shadow');
				var textShadow = $(this).css('text-shadow');


				$(this).css('background', textColor);
				$(this).css('color', backColor);
				$(this).css('box-shadow', textShadow);
				$(this).css('text-shadow', backShadow);
			});
		};
	</script>

	</script>"}, "window=[name];can_close=1;can_resize=1;size=[window_width]x[window_height];border=[is_bordered];titlebar=[is_bordered]")

/obj/machinery/kaos/proc/refresh_page()
	var/href_list = params2list("src=\ref[src]&refresh=1")
	src.Topic("src=\ref[src];refresh=1", href_list)

/obj/machinery/kaos/proc/load_page(datum/terminal_page/page, whatever_args)
	controller.load_page(page, whatever_args)
	return TRUE

// independent of having a page

/obj/machinery/kaos/proc/toggle_input(delay=0, sound)
	input = !input
	refresh_page()
	if (sound)
		playsound(src.loc, sound, 100, 1)
	sleep(delay)

/obj/machinery/kaos/proc/deny_sound(delay=0)
	playsound(src.loc, deny_sfx, 100, 0)
	sleep(delay)

/obj/machinery/kaos/proc/add_line(string, delay=0, sound, include_br = TRUE)
	t += "[string][include_br ? "<br>" : ""]"
	refresh_page()
	if (sound)
		if(sound == TRUE)
			var/sfx = pick(clear_sfx - last_clear)
			last_clear = sfx
			playsound(src.loc, sfx, 100, 0)
			sleep(delay * 0.5)  // shitty hacky change before i rewrite it all, I want it to be faster..
			return
		playsound(src.loc, sound, 100, 1)
	sleep(delay * 0.5)

/obj/machinery/kaos/proc/clear_screen(delay=0, sound)
	t = ""
	input = FALSE
	refresh_page()
	if (sound)
		if(sound == TRUE)
			var/sfx = pick(clear_sfx - last_clear)
			last_clear = sfx
			playsound(src.loc, sfx, 100, 0)
			sleep(delay)
			return
		playsound(src.loc, sound, 100, 1)
	sleep(delay)

/obj/machinery/kaos/proc/think(delay=0, sound)
	if (sound)
		if(sound == TRUE)
			var/sfx = pick(think_sfx - last_think)
			last_think = sfx
			playsound(src.loc, sfx, 100, 0)
			sleep(delay)
			return
		playsound(src.loc, sound, 100, 1)

// independent of having a page

/obj/machinery/kaos/proc/pass_string(var/string, var/mob/user)
	controller.string_to_page(sanitize(string), user)

/obj/machinery/kaos/proc/post_bootup(mob/user)
	overlays.Cut()
	sound_token = sound_player.PlayLoopingSound(src, sound_id, idle_sfx, 50, 2, 0.5)
	clear_screen(10, TRUE)
	controller.load_first()
	var/image/I = image(icon, loc, "captaincomp_idle")
	I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
	overlays += I

/obj/machinery/kaos/proc/power_on(mob/user)
	spawn(bootup_duration)
		post_bootup(user)
	var/image/I = image(icon, loc, "captaincomp_boot")
	I.plane = EFFECTS_ABOVE_LIGHTING_PLANE
	overlays += I
	playsound(src.loc, bootup_sound, 100, 0)
	show_page(user)
	clear_screen(3, TRUE)
	add_line("<font size=5>", 5, TRUE)
	add_line("-GENERIC OS NAME INDUSTRIES / OS-", 10, TRUE)

/obj/machinery/kaos/proc/power_off(mob/user)
	if(sound_token)
		QDEL_NULL(sound_token)
	overlays.Cut()
	// Optional shutdown bs

/obj/machinery/kaos/Topic(href, href_list)
	if (!usr || usr.stat || usr.restrained() || !Adjacent(usr))
		return

	if (href_list["terminal_input"] == "string_input")
		if(!href_list["string"])
			return
		playsound(src.loc, pick(input_sfx - last_input), 100, 0)
		pass_string(href_list["string"], usr)
		return
	else if (href_list["refresh"])
		if(!Adjacent(usr))
			return
		show_page(usr) // dont remember if this is necessary
		return TOPIC_REFRESH

	show_page(usr)
	return TOPIC_REFRESH


/obj/machinery/kaos/proc/get_page(var/string)
	string = lowertext(string)
	for(var/datum/terminal_page/entry in pages)
		if(entry.name == string)
			return entry
	return FALSE

/client/proc/mail_message()
	set category = "roleplay"
	set name = "terminal message"

	var/obj/machinery/kaos/terminal = null
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/list/display = list()
	for(var/key in GLOB.terminals)
		var/obj/machinery/kaos/term = GLOB.terminals[key]
		if(!term.get_page("my_messages")) continue
		var/datum/terminal_page/my_messages/msgs = term.get_page("my_messages")
		display[msgs.account_name] = term



	terminal = input(usr, "Which terminal?", "By username, of course.") as anything in display
	terminal = display[terminal]

	if(!istype(terminal))
		alert("Nope. Can't do it.")
		return
	if(!terminal.get_page("my_messages"))
		alert("Missing it's messages page.")
		return
	var/hide = FALSE
	if(alert("Should the name be REDACTED??",,"Yes","No") == "Yes")
		hide = TRUE
	var/username
	if(!hide)
		username = input(src, "What should the username be?")
		if(!username) return
	var/content = input("What should the contents of it be?", "The contents", null, null) as message
	if(!content) return
	var/datum/terminal_page/my_messages/msgs = terminal.get_page("my_messages")
	msgs.new_message(content, username, hide)
	log_and_message_admins("sent a terminal message to [terminal], content: \"[content]\", username: [hide ? "REDACTED" : username]")
	feedback_add_details("admin_verb","TERMINAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!