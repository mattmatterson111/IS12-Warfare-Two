//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "Wiki"
	set desc = "Visit the wiki."
	set hidden = 1
	if( config.wikiurl )
		if(alert("This will open the wiki in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.wikiurl)
	else
		to_chat(src, "<span class='warning'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/forum()
	set name = "Forum"
	set desc = "Visit the forum."
	set hidden = 1
	if( config.forumurl )
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(config.forumurl)
	else
		to_chat(src, "<span class='warning'>The forum URL is not set in the server configuration.</span>")
	return

#define RULES_FILE "config/rules.html"
/client/verb/rules()
	set name = "Rules"
	set category = "OOC"
	set desc = "Show Server Rules."
	src << browse(file(RULES_FILE), "window=rules;size=480x320")
#undef RULES_FILE

#define LORE_FILE "config/lore.html"
/client/verb/lore_splash()
	set name = "Lore"
	set desc = "Links to the beginner Lore wiki."
	set hidden = 1
	show_browser(src, file(LORE_FILE), "window=lore;size=480x320")
#undef LORE_FILE

/client/verb/hotkeys_help()
	set name = "View Controls"
	set category = "OOC"

	var/dat

	var/admin = {"Admin:
F5 = Aghost (admin-ghost)
F6 = player-panel-new
F7 = admin-pm
F8 = Invisimin
"}

	var/hotkey_mode = {"Hotkey-Mode: (hotkey-mode must be on)
TAB = Selects chat bar at bottom right
a = left
s = down
d = right
w = up
pgup = move-upwards
pgdown = move-down
q = drop
e = equip/draw gun from back
CTRL+e = Equip/Unequip From Feet slot (This can unequip boots if nothing is in them)
SHIFT+e = Click on Belt slot
CTRL+1 = Click on Left Pocket
CTRL+2 = Click on Right Pocket
CTRL+3 = Click on Chest Storage
b = resist
r = throw
t = say
g = toggle rest
o = OOC
x = swap-hand
z/y = activate held object (or y)
f = toggle fixeye
shift+f = look up
shift+x = wield weapon
shift+z = toggle safety/unjam gun
1 = help-intent
2 = disarm-intent
3 = grab-intent
4 = harm-intent
space OR v = crouch
Numpad 1 - Target Left Leg/Left Foot
Numpad 2 - Target Groin
Numpad 3 - Target Right leg/Right Foot
Numpad 4 - Target Left Arm/Hand
Numpad 5 - Target Body
Numpad 6 - Target Right Arm/Hand
Numpad 7 - Target Neck
Numpad 8 - Target Head/Neck/Eyes/Mouth
Numpad 9 - Target Mouth
_____________
"}

	var/other = {"Any-Mode: (hotkey doesn't need to be on)
Ctrl+a = left
Ctrl+s = down
Ctrl+d = right
Ctrl+w = up
Ctrl+q = drop
Ctrl+e = equip
Ctrl+r = throw
Ctrl+x or Middle Mouse (when jump or kick isn't selected) = swap-hand
Ctrl+z = activate held object (or Ctrl+y)
Ctrl+f = cycle-intents-left
Ctrl+g = cycle-intents-right
Ctrl+4 = harm-intent
F1 = adminhelp
F2 = ooc
F3 = say
F4 = emote
DEL = pull
INS = cycle-intents-right
HOME = drop
PGUP or Middle Mouse = swap-hand
PGDN = activate held object
END = throw
Ctrl + Click = drag/undrag
Shift + Click = examine
Alt + Click = show entities on turf
Ctrl + Alt + Click = interact with certain items
_____________
"}

	var/special_controls = {"Speacial Controls:
look up = RMB+Fixeye button OR Shift+F
look into distance = ALT+RMB
give = RMB+help intent
wave friendly = RMB+help intent at a distance
threaten = RMB+harm intent at a distance
crawl - When resting/prone click in a direction
toggle fullscreen = CTRL+ENTER
jump = select "jump" on the UI and middle click
kick = select "kick" on the UI and middle click
_____________
"}

	var/gun_controls = {"Weapon controls:
toggle safety = RMB on gun OR shift+z
do special attack = RMB + harm intent + combat mode
unload gun = click drag into empty hand
clean gun = ALT + Click on gun
unjam gun = RMB on gun when it's jammed
_____________
"}

	var/robot_hotkey_mode = {"<span class='interface'>
<h3>Hotkey-Mode: (hotkey-mode must be on)</h3>
<br>TAB = toggle hotkey-mode
<br>a = left
<br>s = down
<br>d = right
<br>w = up
<br>q = unequip active module
<br>t = say
<br>x = cycle active modules
<br>z = activate held object (or y)
<br>f = cycle-intents-left
<br>g = cycle-intents-right
<br>1 = activate module 1
<br>2 = activate module 2
<br>3 = activate module 3
<br>4 = toggle intents
<br>5 = emote
</span>"}

	var/robot_other = {"<span class='interface'>
<h3>Any-Mode: (hotkey doesn't need to be on)</h3>
<br>Ctrl+a = left
<br>Ctrl+s = down
<br>Ctrl+d = right
<br>Ctrl+w = up
<br>Ctrl+q = unequip active module
<br>Ctrl+x = cycle active modules
<br>Ctrl+z = activate held object (or Ctrl+y)
<br>Ctrl+f = cycle-intents-left
<br>Ctrl+g = cycle-intents-right
<br>Ctrl+1 = activate module 1
<br>Ctrl+2 = activate module 2
<br>Ctrl+3 = activate module 3
<br>Ctrl+4 = toggle intents
<br>F1 = adminhelp
<br>F2 = ooc
<br>F3 = say
<br>F4 = emote
<br>DEL = pull
<br>INS = toggle intents
<br>PGUP = cycle active modules
<br>PGDN = activate held object
<br>Ctrl + Click = drag or bolt doors
<br>Shift + Click = examine or open doors
<br>Alt + Click = show entities on turf
<br>Ctrl + Alt + Click = electrify doors
</span>"}

	if(isrobot(src.mob))
		dat += robot_hotkey_mode
		dat += robot_other
	else
		dat += hotkey_mode
		dat += other
		dat += special_controls
		dat += gun_controls
	if(holder)
		dat += admin
	src << browse(dat, "window=controls")
