// GLOB.ENABLE_EXECUTION

// ^ Dictates whether the captains can even do it. Disabled by default.

/client/proc/toggle_executions()
	set name = "TOGGLE EXECUTION PRIVILEGE"
	set category = "roleplay"

	GLOB.ENABLE_EXECUTION = !GLOB.ENABLE_EXECUTION
	to_chat(src, "Executions are now : : : <b>[GLOB.ENABLE_EXECUTION ? "ENABLED" : "DISABLED"]</b>.")