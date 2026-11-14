GLOBAL_VAR_INIT(csfare_selected_map, null)

/proc/get_csfare_map_files()
	var/list/map_files = list()
	for(var/file_name in flist("maps/csfare/"))
		if(copytext(file_name, -4) == ".dmm")
			map_files += file_name
	return map_files
