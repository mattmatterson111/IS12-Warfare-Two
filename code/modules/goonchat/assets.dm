/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/browserassets/js/jquery.min.js',
	)

/datum/asset/simple/goonchat
	verify = TRUE
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
		"browserOutput_white.css"  = 'code/modules/goonchat/browserassets/css/browserOutput_white.css',
		"browserOutput_override.css"  = 'code/modules/goonchat/browserassets/css/browserOutput_override.css',
		"background.png" = 'code/modules/goonchat/browserassets/img/bg.png',
		"chatbg-t.png" = 'code/modules/goonchat/browserassets/img/chatbg-t.png',
		"testbg.png" = 'code/modules/goonchat/browserassets/img/testbg.png',
		"chatbg-b.png" = 'code/modules/goonchat/browserassets/img/chatbg-b.png',
		"chatbg-w-ct.png" = 'code/modules/goonchat/browserassets/img/chatbg-w-ct.png',
		"chatbg-w-cb.png" = 'code/modules/goonchat/browserassets/img/chatbg-w-cb.png',
		"chatbg-w.png" = 'code/modules/goonchat/browserassets/img/chatbg-w.png',
		"chatbg-e-ct.png" = 'code/modules/goonchat/browserassets/img/chatbg-e-ct.png',
		"chatbg-e-cb.png" = 'code/modules/goonchat/browserassets/img/chatbg-e-cb.png',
		"chatbg-e.png" = 'code/modules/goonchat/browserassets/img/chatbg-e.png',
		"chatscrollbar-bg-t.png" = 'code/modules/goonchat/browserassets/img/chatscrollbar-bg-t.png',
		"chatscrollbar-bg.png" = 'code/modules/goonchat/browserassets/img/chatscrollbar-bg.png',
		"chatscrollbar-bg-b.png" = 'code/modules/goonchat/browserassets/img/chatscrollbar-bg-b.png',
		"chatscrollbar-scrolldown.png" = 'code/modules/goonchat/browserassets/img/chatscrollbar-scrolldown.png',
		"chatscrollbar-scrollup.png" = 'code/modules/goonchat/browserassets/img/chatscrollbar-scrollup.png',
		"chatscroller-b.png" = 'code/modules/goonchat/browserassets/img/chatscroller-b.png',
		"chatscroller-m.png" = 'code/modules/goonchat/browserassets/img/chatscroller-m.png',
		"chatscroller-t.png" = 'code/modules/goonchat/browserassets/img/chatscroller-t.png',
	)

/datum/asset/simple/fontawesome
	verify = FALSE
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css',
	)