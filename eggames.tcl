############################## C O N F I G ##############################

# Resets the bot games values
proc EggamesReset { gamename } {
	global Eggames

	array set Eggames {
		Attempts 				0 	# Number of attempts
		BonusLen 			0 	# Bonus added for longest word
		BonusVel 				"" 	# Bonus added for fastest correct answer
		Chan 					"" 	# Channel set for games
		Colors 					"" 	# Color set for bot messages (background, 
		Decors 				""	# Decors added to bot messages
		Debug 					0 	# Sets debug mode
		GameMode 			0 	# Sets game type
		GameName 			"" 	# Current game name
		HaveGaps 			0 	# Sets if current game uses pauses between bot messages
		HaveHints 			0 	# Sets if current game uses hints
		Hints 					0 	# Number of hints given by bot
		HintMax 				0 	# Maximum number of possible hints to get from bot
		Logo 					"" 	# Game name logo
		Manche 				0 	# Current round
		MancheNicks		"" 	# Nick player list in current round
		MancheHosts 		"" 	# Players host list in current round
		MancheScores 	"" 	# Players score list in current round
		MancheWords 		"" 	# Players answer list in current round
		Played 					0 	# Total matches played with current game
		PlayerNicks			"" 	# Current players nicknames
		PlayerHosts 			"" 	# Current players hostnames
		PlayerScores 		"" 	# Current players score
		TargetDef 			0 	# Default score to reach for current game
		TargetMin 			0 	# Minimum score to reach accepted by current game
		TargetMax 			0 	# Maximum score to reach accepted by current game
		TargetType 			0 	# 0 = Points (Default) 1 = Rounds
		TargetVal 				0 	# 
		TimeGap 				0 	# 
		TimeManche 		0 	# 
		TimeMsg 				1 	# 
		TmrGap 				"" 	# 
		TmrManche 			"" 	# 
		Winners 				0 	# 
		Word 					"" 	# 
		WordHint 				"" 	# 
		WordLen 				0 	# 
		WordLenMin 			0 	# 
		WordLenMax 		0 	# 
		UseColors 			0 	# 
		UseDecors 			0 	# 
	}
}

# The rest of valid variables accepted by this script. Here the main preferences to edit in eggames.[language to use].cfg before run it.
proc EggamesSetDefaults {} {
	global Eggames

	set Eggames(Chan) 				"" 				; # You can set many channels where to play, but only one a time can be used to play a game.
	set Eggames(Lang) 				"en" 			; # Language to use for entire system (debug, error messages as well games). Default: english.
	set Eggames(TrigPrefix) 			"!" 			; # Prefix to prepend to channel trigger commands below.
	set Eggames(TrigStop) 			"stop" 		; # Command trigger to stop the games.
	set Eggames(TrigList) 				"games" 	; # Command trigger to list available games in the channel.
	set Eggames(TrigHelp) 			"help" 		; # Command trigger to get help / info about current game.
	set Eggames(TrigHint) 			"hint" 		; # Command trigger to get a hint (where available) for current game.
	set Eggames(TrigTarget) 			"target" 	; # Command trigger to get/set the score (or round) to reach for current game.
	set Eggames(TrigValues) 		"values" 	; # Command trigger to get letters score values.
	set Eggames(CmdListFlag) 		"o|o" 		; # User permissions for TrigList command.
	set Eggames(CmdStartFlag) 	"o|o" 		; # User permissions for start game command.
	set Eggames(CmdStopFlag) 	"o|o" 		; # User permissions for stop game command.
	set Eggames(List) 					[list] 		; # List of available games enabled in bot (maybe for some reason you need to disable some of them).
}

# Saves general preferences
proc EggamesWriteCFG { name } {
	global Eggames

	set basedir [ file dirname [ info script ] ]/config
	if { ![ file exists $basedir ] } { putlog "\0034Eggames\003: Directory $basedir doesn't exists." ; return }
	set filecfg $basedir/config/$name.cfg
	set f [ open $filecfg w ]
	if { $name == "eggames" } {
		puts $f "Channel=$Eggames(Chan)"
		puts $f "Lang=$Eggames(Lang)"
		puts $f "TrigStart=$Eggames(TrigPrefix)"
		puts $f "TrigStop=$Eggames(TrigStop)"
		puts $f "TrigList=$Eggames(TrigList)"
		puts $f "TrigHelp=$Eggames(TrigHelp)"
		puts $f "TrigHint=$Eggames(TrigHint)"
		puts $f "TrigTarget=$Eggames(TrigTarget)"
		puts $f "TrigValues=$Eggames(TrigValues)"
		puts $f "CmdListFlag=$Eggames(CmdListFlag)"
		puts $f "CmdStartFlag=$Eggames(CmdStartFlag)"
		puts $f "CmdStopFlag=$Eggames(CmdStopFlag)"
		puts $f "Enable=$Eggames(List)"
	} else {
		
	}
	close $f
}

# Locale translation
proc EggamesReadLang { name } {
	global Eggames EggamesLang

	set basedir [ file dirname [ info script ] ]/locale
	if { ![ file exists $basedir ] } { putlog "\0034Eggames\003: Directory $basedir doesn't exists." ; return 1 }
	if { [ info exists Eggames(Lang) ] } { set lang $Eggames(Lang) } { set lang "en" }
	set filelang [ file dirname [ info script ] ]/locale/$lang/$name.lang
	if { [ file exist $filelang ] } {
		set f [ open $filelang r ]
		while { [ gets $f s ] != -1 } {
			set kkey 	[ string tolower [ lindex [ split $s "=" ] 0 ] ]
			set kval 	[ lindex [ split $s "=" ] 1 ]
			if { [ string is integer $kkey ] } { set EggamesLang($kkey) $kval }
		}
		close $f
		return 0
	}
	putlog "\0034Eggames\003: locale/$lang/$name.lang not found."
	return 1
}

# Reads specified configuration file name
proc EggamesReadCFG { name } {
	global Eggames EggamesLang

	set basedir [ file dirname [ info script ] ]/config
	if { ![ file exists $basedir ] } { putlog "\0034Eggames\003: Directory $basedir doesn't exists." ; return 1 }
	set filecfg $basedir/$name.cfg
	if { [ file exist $filecfg ] } {
		set f [ open $filecfg r ]
		while { [ gets $f s ] != -1 } {
			set kkey [ string tolower [ lindex [ split $s "=" ] 0 ] ]
			set kval [ lindex [ split $s "=" ] 1 ]
			if { $name == "eggames" } {
				switch $kkey {
					channel 			{ set Eggames(Chan) 					$kval }
					lang					{ set Eggames(Lang) 					$kval }
					cmdlistflag 		{ set Eggames(CmdListFlag) 		$kval }
					cmdstartflag 	{ set Eggames(CmdStartFlag) 	$kval }
					cmdstopflag 	{ set Eggames(CmdStopFlag) 	$kval }
					enable 				{ set Eggames(List) [ split 		$kval "," ] }
					trighelp 			{ set Eggames(TrigHelp) 			$kval }
					trighint 			{ set Eggames(TrigHint) 				$kval }
					triglist 				{ set Eggames(TrigList) 				$kval }
					trigprefix 			{ set Eggames(TrigPrefix) 			$kval }
					trigstop 			{ set Eggames(TrigStop) 			$kval }
					trigtarget 		{ set Eggames(TrigTarget) 			$kval }
					trigvalues 		{ set Eggames(TrigValues) 			$kval }
				}
			} else {
			
			}
		}
		close $f
		EggamesReadLang $name
		return
	}
	set msg [ append $EggamesLang(1) $EggamesLang(2) ]
	putlog "\0037Eggames\003: eggames.cfg $msg"
	EggamesSetDefaults
	EggamesWriteCFG $name
}

if { [ EggamesReadLang "eggames" ] == 1 } { return }
if { [ EggamesReadCFG "eggames" ] == 1 } { return }

#--- MAIN FUNCTIONS ---
proc GameReadLang { gamename } {

	set validlang 0
	switch $gamefilename {
		"finalize" - "inferno" - "miniquick" - "middlequick" - "maxxiquick" { set gamename "ScaraQuick" }
	}
	set f [open $langfile r]
	while {[gets $f s] != -1} {
		set kkey [string tolower [lindex [split $s "="] 0]]
		set kval [lindex [split $s "="] 1]
		if {[string is integer $kkey]} {
			GameFunc $gamename "SetLang" $kkey $kval
			set validlang 1
		}
	}
	close $f
	return $validlang
}

proc GameReadCFG {gamename} {
	global Games GamesLang
# TODO Controllo sui valori
	set game [string tolower $gamename]
	switch $game {
		"finalize" - "inferno" - "miniquick" - "middlequick" - "maxxiquick" { set gamename "ScaraQuick" }
	}
	set gamefileconfig "$Games(DirConf)/$game.cfg"
	if {[file exist $gamefileconfig]} {
		set f [open $gamefileconfig r]
		while {[gets $f s] != -1} {
			set kkey [lindex [split $s "="] 0]
			set kval [lindex [split $s "="] 1]
			set gamecmd $gamename
			append gamecmd "Set" $kkey
			switch $kkey {
				Chan 			{$gamecmd $kval}
				Colors 			{$gamecmd $kval}
				Decors 		{$gamecmd $kval}
				Debug 			{$gamecmd $kval}
				HaveGaps 	{$gamecmd $kval}
				HintMax 		{$gamecmd $kval}
				Played 			{$gamecmd $kval}
				TargetDef 	{$gamecmd $kval}
				TargetMin 	{$gamecmd $kval}
				TargetMax 	{$gamecmd $kval}
				TargetType 	{$gamecmd $kval}
				TimeGap 		{$gamecmd $kval}
				TimeManche	{$gamecmd $kval}
				WordLenMin 	{$gamecmd $kval}
				WordLenMax {$gamecmd $kval}
				UseColors 	{$gamecmd $kval}
				UseDecors 	{$gamecmd $kval}
			}
		}
		close $f
		return 1
	}
	putlog "\0034$gamename\003: $gamefileconfig $GamesLang(1)"
	return 0
}

proc GameWriteCFG {gamename} {
	global Games
# TODO Controllo sui valori
	set game [string tolower $gamename]
	set gamefileconfig "$Games(DirConf)/$game.cfg"	
	set f [open $gamefileconfig w]
	set gamecmd $gamename
	for {set i 0} {$i<11} {incr i} {
		switch $i {
			0 { set gamecmd [append $gamename "GetChan"] ; puts $f "Chan=$gamecmd" }
			0 { set gamecmd [append $gamename "GetColors"] ; puts $f "Colors=$gamecmd" }
			0 { set gamecmd [append $gamename "GetDecors"] ; puts $f "Decors=$gamecmd" }
			1 { set gamecmd [append $gamename "GetDebug"] ; puts $f "Debug=$gamecmd" }
			2 { set gamecmd [append $gamename "GetHaveGaps"] ; puts $f "HaveGaps=$gamecmd" }
			2 { set gamecmd [append $gamename "GetHintMax"] ; puts $f "HintMax=$gamecmd" }
			3 { set gamecmd [append $gamename "GetPlayed"] ; puts $f "Played=$gamecmd" }
			4 { set gamecmd [append $gamename "GetTargetDef"] ; puts $f "TargetDef=$gamecmd" }
			5 { set gamecmd [append $gamename "GetTargetMin"] ; puts $f "TargetMin=$gamecmd" }
			6 { set gamecmd [append $gamename "GetTargetMax"] ; puts $f "TargetMax=$gamecmd" }
			7 { set gamecmd [append $gamename "GetTargetType"] ; puts $f "TargetType=$gamecmd" }
			8 { set gamecmd [append $gamename "GetTimeGap"] ; puts $f "TimeGap=$gamecmd" }
			9 { set gamecmd [append $gamename "GetTimeManche"] ; puts $f "TimeManche=$gamecmd" }
			10 { set gamecmd [append $gamename "GetWordLenMin"] ; puts $f "WordLenMin=$gamecmd" }
			11 { set gamecmd [append $gamename "GetWordLenMax"] ; puts $f "WordLenMax=$gamecmd" }
			11 { set gamecmd [append $gamename "GetUseColors"] ; puts $f "UseColors=$gamecmd" }
			11 { set gamecmd [append $gamename "GetUseDecors"] ; puts $f "UseDecors=$gamecmd" }
		}
	}
	close $f
}

proc GameHub { gamename gametarget gametopscore } {

	if { $gametopscore < $gametarget } {
		putlog "\0039$gamename\003GameHub: $gametopscore $gametarget"
		set gamehavegaps [GameFunc $gamename "GetHaveGaps"]
		if { $gamehavegaps } {
			set gametimegap [GameFunc $gamename "GetTimeGap"]
			set gametimemsg [GameFunc $gamename "GetTimeMsg"]
			GameFunc $gamename "Reset"
			utimer $gametimemsg [list GameFunc $gamename "Gap"]
			set gametimegap [expr $gametimegap + $gametimemsg]
			utimer $gametimegap [list GameManche $gamename]
		} else {
			GameFunc $gamename "Reset"
			GameManche $gamename
		}
	} else {
		GameFunc $gamename "ShowWinners"
		GameFunc $gamename "Stop"
		GameFunc $gamename "Unset"
	}
}

proc GameManche { gamename } {

	set gameisset [GameFunc $gamename "IsSet"] ; if { !$gameisset } { return }
	set debug [GameFunc $gamename "GetDebug"]
	set gamemanche [GameFunc $gamename "GetManche"]
	incr gamemanche ; GameFunc $gamename "SetManche" $gamemanche
	set gamehintmax [GameFunc $gamename "GetHintMax"]
	if { $gamehintmax > 0 } {
		set gamewordlenmin [GameFunc $gamename "GetWordLenMin"]
		set gamewordlenmax [GameFunc $gamename "GetWordLenMax"]
		set gamewordlen [GameRND $gamewordlenmin $gamewordlenmax]
		set gameword ""
		set attempts 0
		while { $gamewordlen != [string length $gameword] } {
			set gameword [DictMakeRndWord]
			if { $gameword == -1 } { return }
			incr attempts
		}
		if { $debug } { putlog "\0039$gamename\003 -> GameManche: $gameword \($attempts attempts\)" }
		GameFunc $gamename "SetWord" $gameword
		GameFunc $gamename "SetWordLen" $gamewordlen
		GameFunc $gamename "Make" $gameword
	} else {
		GameFunc $gamename "Make"
	}
	GameFunc $gamename "Manche"
	set gametimemanche [GameFunc $gamename "GetTimeManche"]
	utimer $gametimemanche [list GameResults $gamename]
	set gametimemanche [expr $gametimemanche - 10]
	utimer $gametimemanche [list GameFunc $gamename "TimeLeft"]
}

proc GameResults { gamename } {
	global GameMancheScores

	set gameisset [GameFunc $gamename "IsSet"] ; if { !$gameisset } { return }
	set gamesgidx [GameFunc $gamename "Results"]
	if { $gamesgidx } {
		set debug [GameFunc $gamename "GetDebug"]
		set playernickslist [GameFunc $gamename "GetPlayerNicks"]
		set playerhostslist [GameFunc $gamename "GetPlayerHosts"]
		set playerscorelist [GameFunc $gamename "GetPlayerScores"]
		set manchenickslist [GameFunc $gamename "GetMancheNicks"]
		set manchehostslist [GameFunc $gamename "GetMancheHosts"]
		set manchescorelist [GameFunc $gamename "GetMancheScores"]
		set manchewordslist [GameFunc $gamename "GetMancheWords"]
		set bonusmsg ""
		set bonusvel [GameFunc $gamename "GetBonusVel"]
		set bonuslen [GameFunc $gamename "GetBonusLen"]
		set gamechan [GameFunc $gamename "GetChan"]
		array set playerbonus {}
		array set playershost {}
		array set playersword {}
		set idx 0
		foreach nick $manchenickslist {
			set playerbonus($nick) 0
			set playershost($nick) [lindex $manchehostslist $idx]
			set playersword($nick) [lindex $manchewordslist $idx]
			set score [lindex $manchescorelist $idx]
			if { $nick == $bonusvel } { set playerbonus($nick) 2 }
			if { [string length $playersword($nick)] == $bonuslen } { set playerbonus($nick) [expr $playerbonus($nick) + 4] }
			set total [expr $score + $playerbonus($nick)]
			if { $debug } { putlog "\0039$gamename\003 -> GameResults: $nick\!$playershost($nick) Word: $playersword($nick) Score: $score Bonus: $playerbonus($nick) Total: $total" }
			set GameMancheScores($nick) $total
			incr idx
		}
		set idx 0
		foreach player [lsort -command GameSortMancheScores [array names GameMancheScores]] {
			switch $playerbonus($player) {
				0 { set bonusmsg "-" }
				2 { set bonusmsg "\0038\002+Velocita\[2\]\002" }
				3 { set bonusmsg "\0038\002+Originalita\[3\]\002" }
				4 { set bonusmsg "\0038\002+Lunghezza\[4\]\002" }
				5 { set bonusmsg "\0038\002+Velocita\[2\]+Originalita\[3\]\002" }
				6 { set bonusmsg "\0038\002+Velocita\[2\]+Lunghezza\[4\]\002" }
				9 { set bonusmsg "\0038\002+Velocita\[2\]+Originalita\[3\]+Lunghezza\[4\]\002" }
				default { set bonusmsg " - \003" }
			}
			GameFunc $gamename "AddPlayerNick" $player
			GameFunc $gamename "AddPlayerHost" $playershost($player)
			GameFunc $gamename "AddPlayerScore" $player $GameMancheScores($player)
			set timeresults [GameFunc $gamename "GetTimeMsg"]
			GameFunc $gamename "ShowResults" $timeresults $player $playersword($player) $GameMancheScores($player) $bonusmsg
			incr gamesgidx
		}
		array unset GameMancheScores
		set timeclass [GameFunc $gamename "GetTimeMsg"]
		utimer $timeclass [list GameClass $gamename]
		return
	}
	GameHub $gamename 1 0
}

proc GameClass { gamename } {
	global GameScores

  set gameisset [GameFunc $gamename "IsSet"] ; if { !$gameisset } { return }
	set playernickslist [GameFunc $gamename "GetPlayerNicks"]
	set gametopscore 0
  if {[llength $playernickslist] > 0} {
		set playerscorelist [GameFunc $gamename "GetPlayerScores"]
		set i 0
		foreach player $playernickslist {
			set GameScores($player) [lindex $playerscorelist $i]
			if { $i == 0 } { set gametopscore $GameScores($player) }
			incr i
		}
		GameFunc $gamename "MsgClass"
		set i 1
		foreach player [lsort -command GameSortScores [array names GameScores]] {
			GameFunc $gamename "MsgClassResult" $i $player $GameScores($player)
			incr i
		}
		array unset GameScores
		set gametarget [GameFunc $gamename "GetTargetVal"]
		utimer $i [list GameHub $gamename $gametarget $gametopscore]
  }
}

proc GameSortScores {a b} {
  global GameScores

  if {$GameScores($a) <  $GameScores($b)} {return 1}
  if {$GameScores($a) == $GameScores($b)} {return 0}
  if {$GameScores($a) >  $GameScores($b)} {return -1}
}

proc GameSortMancheScores {a b} {
  global GameMancheScores

  if {$GameMancheScores($a) <  $GameMancheScores($b)} {return -1}
  if {$GameMancheScores($a) == $GameMancheScores($b)} {return 0}
  if {$GameMancheScores($a) >  $GameMancheScores($b)} {return 1}  
}

proc GameCol { col { bgcol "" } } {

	set colorcode "\003"
	if { $bgcol == "" } { set colorcode [append colorcode $col] } { set colorcode [append colorcode $col "," $bgcol] }
	return $colorcode
}

proc GameMsg {secs chan msg} { utimer $secs [list putquick "PRIVMSG $chan :$msg"] }

proc GameRND {m M} { return [expr {$m+(int(rand()*($M-$m+1)))}] ;#return [expr {$m+(round(rand()*($M-$m)))}] }

proc GameLastMonthName {month} {
	switch $month {
		00 {return "dic"}
		01 {return "gen"}
		02 {return "feb"}
		03 {return "mar"}
		04 {return "apr"}
		05 {return "mag"}
		06 {return "giu"}
		07 {return "lug"}
		08 {return "ago"}
		09 {return "set"}
		10 {return "ott"}
		11 {return "nov"}
		default {return "???"}
	}
}

proc GameFunc {gamename funcname { arg1 "" } { arg2 "" } { arg3 "" } { arg4 "" } { arg5 "" } } {
	set gamefunc $gamename
	append gamefunc $funcname
	if { $arg1 == "" } {
		return [$gamefunc]
	} elseif { $arg2 == "" } {
		$gamefunc $arg1
		return $arg1
	} elseif { $arg3 == "" } {
		$gamefunc $arg1 $arg2
		return [list $arg1 $arg2]
	} elseif { $arg4 == "" } {
		$gamefunc $arg1 $arg2 $arg3
		return [list $arg1 $arg2 $arg3]
	} elseif { $arg5 == "" } {
		$gamefunc $arg1 $arg2 $arg3 $arg4
		return [list $arg1 $arg2 $arg3 $arg4]
	} else {
		$gamefunc $arg1 $arg2 $arg3 $arg4 $arg5
		return [list $arg1 $arg2 $arg3 $arg4 $arg5]
	}
}

putlog "$EggamesLang(3) eggames.tcl"

