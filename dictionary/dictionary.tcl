set DictVer 1
set DictRev 0

# Per utilizzare questo script e' necessario impostare la variabile DictFileCFG col percorso del file di impostazioni
# prima del caricamento da qualche parte nel file eggdrop.conf
#
# Es.:
#
# set DictFileCFG "dictionary/dictionary.cfg"
# source dictionary/dictionary.tcl

setudef flag dictionary

proc DictReadCFG {} {
	global DictFileCFG DictLang DictDir DictLangDir DictFileLang DictLetters DictCmdFlag DictCmdAdd DictCmdDelete DictCmdVerify DictCmdSpeak

	if { [ file exist $DictFileCFG ] } {
		set f [ open $DictFileCFG r ]
		while { [ gets $f s ] != -1 } {
			set kkey 	[ string tolower [ lindex [ split $s "=" ] 0 ] ]
			set kval 	[ lindex [ split $s "=" ] 1 ]
			switch $kkey {
				dictlang 			{ set DictLang 			$kval }
				dictdir 				{ set DictDir 				$kval }
				dictlangdir 		{ set DictLangDir 		$kval }
				dictfilelang 		{ set DictFileLang 		$kval }
				dictletters 		{ set DictLetters 		$kval }
				dictcmdflag 		{ set DictCmdFlag 		$kval }
				dictcmdadd 		{ set DictCmdAdd 		$kval }
				dictcmddelete { set DictCmdDelete 	$kval }
				dictcmdverify 	{ set DictCmdVerify 	$kval }
				dictcmdspeak 	{ set DictCmdSpeak 	$kval }
			}
		}
		close $f
	} else {
		putlog "\0039Dictionary\003: File $DictFileCFG not found. Saving defaults."
		set DictLang 				"it"
		set DictDir 					"dictionary"
		set DictLangDir 			"$DictDir/$DictLang"
		set DictFileLang 			"$DictDir/dict.$DictLang.lang"
		set DictLetters 			"abcdefghijklmnopqrstuvwxyz"
		set DictCmdFlag 		"o|o"
		set DictCmdAdd 			"!aggiungi"
		set DictCmdDelete 	"!elimina"
		set DictCmdVerify 		"!verifica"
		set DictCmdSpeak 		"!speak"
		DictWriteCFG
	}
}

proc DictWriteCFG {} {
	global DictFileCFG DictLang DictDir DictLangDir DictFileLang DictLetters DictCmdFlag DictCmdAdd DictCmdDelete DictCmdVerify DictCmdSpeak

	set f [ open $DictFileCFG w ]
	puts $f "DictLang=$DictLang"
	puts $f "DictDir=$DictDir"
	puts $f "DictLangDir=$DictLangDir"
	puts $f "DictFileLang=$DictFileLang"
	puts $f "DictLetters=$DictLetters"
	puts $f "DictCmdFlag=$DictCmdFlag"
	puts $f "DictCmdAdd=$DictCmdAdd"
	puts $f "DictCmdDelete=$DictCmdDelete"
	puts $f "DictCmdVerify=$DictCmdVerify"
	puts $f "DictCmdSpeak=$DictCmdSpeak"
	close $f
}

proc DictReadLang {} {
	global DictFileLang DictMsg

	if { [ file exist $DictFileLang ] } {
		set f [ open $DictFileLang r ]
		while { [ gets $f s ] != -1} {
			set kkey 	[ string tolower [ lindex [ split $s "=" ] 0 ] ]
			set kval 	[ lindex [ split $s "=" ] 1 ]
			switch $kkey {
				msg1 { set DictMsg(0) $kval }
				msg2 { set DictMsg(1) $kval }
				msg3 { set DictMsg(2) $kval }
				msg4 { set DictMsg(3) $kval }
				msg5 { set DictMsg(4) $kval }
				msg6 { set DictMsg(5) $kval }
			}
		}
		close $f
		return 0
	}
	putlog "\0034Dictionary\003: DictReadLang - File $DictFileLang not found."
	return 1
}

# Cambia dizionario tramite comando in canale
proc DictSetLang {nick uhost hand chan txt} {
	global DictLang DictDir DictLangDir DictFileLang DictCmdSpeak

	set newlang [ lindex $txt 1 ]
	if { ![ channel get $chan dictionary ] || ( $newlang == $DictLang ) || ( [ lindex $txt 0 ] != $DictCmdSpeak ) } { return }
	switch [lindex $txt 1] {
		"en" { set tlang "en" 	; putquick "PRIVMSG $chan :Language changed in english" 	}
		"it" 	{ set tlang "it" 	; putquick "PRIVMSG $chan :La lingua corrente e' italiano" 	}
		"fr" 	{ set tlang "fr" 	; putquick "PRIVMSG $chan :Change' de langue en francaise" }
		default { return }
	}
	set filelang  "$DictDir/dict.$tlang.lang"
	if { [ file exists $filelang ] } {
		set DictLang 		$tlang
		set DictLangDir 	"$DictDir/$DictLang"
		set DictFileLang 	"$DictDir/dict.$DictLang.lang"
		DictReadLang
		return
	}
	putlog "\0034Dictionary\003: DictSetLang - File $filelang not found."
}

# Crea una parola casuale dal dizionario
# Ritorna :
# -1 - Dizionario non trovato
# Parola trovata
proc DictMakeRndWord {} {
	global DictLetters DictLangDir
# TODO: Contare le lettere dell'alfabeto corrente IE: il numero dei files contenuto nella directory del dizionario
	set letter [ string index $DictLetters [ rand 26 ] ]
	set dict_file_path $DictLangDir
	append dict_file_path "/" $letter ".txt"
	if { ![ file exist $dict_file_path ] } {
		putlog "\0034Dictionary\003: DictMakeRndWord - File $dict_file_path not found."
		return -1
	}
	set dict_file 				[ open $dict_file_path r ]
	set dict_words 		[ split [ read -nonewline $dict_file ] "\n" ]
	close $dict_file
	set dict_len 			[ llength $dict_words ]
	set rand_line_num 	[ rand $dict_len ]
	set find_word 			[ lindex $dict_words $rand_line_num ]
	unset dict_words
	return $find_word
}

# Verifica la presenza nel dizionario di una parola data
proc DictVerifyWord {nick mask hand chan txt} {
	global DictMsg

	if { ![ channel get $chan dictionary ] } { return }
	set word [ lindex $txt 0 ]
	if { [ DictCheck $word ]==0 } { set isok "$DictMsg(1)" } { set isok "$DictMsg(2)" }
	putquick "PRIVMSG $chan :\0030,2 $DictMsg(0)\0037,2\002 $word\002\0030,2 $isok $DictMsg(3) \003"
}

# Verifica la presenza nel dizionario di una parola data
# Ritorna:
# 0 - Ok
# 1 - Lettera iniziale non valida (non compresa nell'alfabeto)
# 2 - parola non trovata o inesistente
# 3 - Dizionario non trovato o inesistente
proc DictCheck { word } {
	global DictLetters DictLangDir

	set word 		[ string tolower $word ]
	set letter 	[ string index $word 0 ]
	if { ![ string match -nocase "*$letter*" $DictLetters ] } { return 1 }
	set dict_path "$DictLangDir/$letter.txt"
	if { ![ file exist $dict_path ] } { return 3 }
	set dict_file [ open $dict_path r ]
	while { ![ eof $dict_file ] } {
		set _word [ gets $dict_file ]
		if { [ string match -nocase "$word" $_word ] } {
			close $dict_file
			return 0
		}
	}
	return 2
}

# Aggiunge nel dizionario di una parola data
proc DictAddWord { nick mask hand chan txt } {
	global DictLetters DictLangDir DictMsg

	if { ![ channel get $chan dictionary ] } { return }
	set word 	[ lindex $txt 0 ]
	set letter [ string index $word 0 ]
	if {![string match -nocase "*$letter*" $DictLetters]} {return}
	set dict_path "$DictLangDir/$letter.txt"
	if { ![ file exist $dict_path ] } {
		putlog "\0034Dictionary\003: DictAddWord - File $dict_path not found."
		return
	}
	set dict_file [open $dict_path r+]
	while {![eof $dict_file]} {
		set _word [gets $dict_file]
		if {$word == $_word} {
			putlog "\0037Dictionary\003: DictAddWord - \($nick\): $word already exists."
			close $dict_file
			return
		}
	}
	puts $dict_file $word
	close $dict_file
	putquick "PRIVMSG $chan :\0030,2 $DictMsg(0)\0037,2\002 $word\002\0030,2 $DictMsg(1) $DictMsg(4) \003"
}

proc DictDelWord { nick mask hand chan txt } {
	global DictLetters DictLangDir DictMsg

	if { ![ channel get $chan dictionary ] } { return }
	set word [lindex $txt 0]
	set letter [string index $word 0]
	if { ![ string match -nocase "*$letter*" $DictLetters ] } { return }
	set dict_path "$DictLangDir/$letter.txt"
	if { ![ file exist $dict_path ] } {
		putlog "\0034Dictionary\003: DictDelWord - File $dict_path not found."
		return
	}
	set dict_file [ open $dict_path r ]
	set dict_list [ split [read -nonewline $dict_file ] "\n" ]
	set check [ lsearch $dict_list $word ]
	close $dict_file
	if { $check < 0 } {
		putlog "\0037Dictionary\003: DictDelWord - $word doesn't exists."
		return
	} else {
		set dict_list [ lreplace $dict_list $check $check ]
		file delete $dict_path
		set dict_file [ open $dict_path w ]
		foreach _word $dict_list {
			puts $dict_file $_word
		}
		close $dict_file
		putquick "PRIVMSG $chan :\0030,2 $DictMsg(0)\0037,2\002 $word\002\0030,2 $DictMsg(1) $DictMsg(5) \003"
	}
}

DictReadCFG
if { [ DictReadLang ] ==1} { return }

bind pubm 	$DictCmdFlag 	* 								DictSetLang
bind pub 		$DictCmdFlag 	$DictCmdAdd 		DictAddWord
bind pub 		$DictCmdFlag 	$DictCmdDelete 	DictDelWord
bind pub - 	$DictCmdVerify 								DictVerifyWord

putlog "Script caricato: Dizionario $DictVer.$DictRev"
