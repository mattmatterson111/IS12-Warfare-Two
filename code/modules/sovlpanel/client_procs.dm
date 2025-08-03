/client/Topic(href, href_list, hsrc)
	. = ..()
	if(href_list["_src_"] == "stat")
		if(href_list["spload"] == "1")
			statpanel_loaded = TRUE
			init_panel()
		if(href_list["modernbrowser"] == "1")
			statpanel_loaded = TRUE
		if(href_list["buttonpig"] == "1")
			src << 'sound/uibutton.ogg'
			who()
		if(href_list["buttonchrome"] == "1")
			src << 'sound/uibutton.ogg'
			if(current_button == "chrome")
				return
			current_button = "chrome"
			newtext(html_verbs[current_button])
		if(href_list["buttonoptions"] == "1")
			src << 'sound/uibutton.ogg'
			if(current_button == "options")
				return
			current_button = "options"
			newtext(html_verbs[current_button])
		if(href_list["exitpanel"] == "1")
			src << 'sound/uibutton.ogg'
			toggle_sovlpanel()
		if(href_list["buttonnote"] == "1")
			src << 'sound/uibutton.ogg'
			if(current_button == "note")
				return
			current_button = "note"
			newtext(mob.noteUpdate())
		if(href_list["buttondynamic"])
			src << 'sound/uibutton.ogg'
			if(current_button == href_list["buttondynamic"])
				return
			current_button = href_list["buttondynamic"]
			newtext(html_verbs[current_button])
		if(href_list["proc"])
			src << 'sound/uibutton.ogg'
			call(src, href_list["proc"])()




var/client/pigReady = FALSE