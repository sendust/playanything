;  Play anything by sendust
;  Play All kind of media file
;  Support Decklini output
; 
;
;

/*
[decklink @ 00000000027c26c0] Blackmagic DeckLink input devices:
[decklink @ 00000000027c26c0]   'DeckLink Duo (1)'
[decklink @ 00000000027c26c0]   'DeckLink Duo (2)'
[decklink @ 00000000027c26c0]   'DeckLink Duo (3)'
[decklink @ 00000000027c26c0]   'DeckLink Duo (4)'
[decklink @ 00000000027c26c0]   'DeckLink Studio 4K'
*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Ignore
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include Socket_nonblock.ahk
#include mediainfo.ahk
#include param_processor.ahk
logfile := A_ScriptDir . "\log\all_player.log"


Gui, Margin, 10, 10
Gui, add, Edit, xm ym w430 h160 hwndhinfo , Information
Gui, add, Button, xp+440 yp w100 h40 hwndhpreview gpreview, Preview
Gui, add, Button, xp  yp+50 w100 h30 hwndhadd gaddlist, ADD ▼
Gui, add, Text, xm yp+130 w250 h40 hwndhtc Border 0x200  Center, --:--:--.---
Gui, add, Text, xp+260  yp+5 w120 h40 hwndhmarkinout center  , --:--:--.---`r`n--:--:--.---
Gui, add, Text, xp+130 yp-5  w150 h40 hwndhtcrem Border 0x200  Center, --:--:--.---
Gui, add, Button, xm yp+60 w100 h30 gload hwndhload , CUE
Gui, add, Button, xp+120 yp  w100 h30 gplay hwndhplay , PLAY
Gui, add, Button, xp+120 yp  w100 h30 gstop hwndhstop , STOP
Gui, add, Text,  xp+150 yp  w150 h30 hwndhlistrem Border 0x200  Center, -/--  --:--:--.---

Gui, add, Edit, xm yp+40 w430 h30 hwndhtitle vtitle_clip, TITLE
Gui, add, Button, xp+440  yp  w100 h30 hwndhaddtitle gaddtitle , TITLE ▼

Gui, add, ListView, xm yp+40 w550 h200 hwndhplist glvclick  ReadOnly -LV0x10
Gui, add, Button,xm  yp+210  w100 h30 hwndhplay_list glistplay, PLAY_LIST
Gui, add, Button,xp+120  yp  w80 h30 hwndhedit_list gsavedit, SAVE`r`nEDIT
Gui, add, Button,xp+100  yp  w80 h30 hwndhload_list glistload, LOAD
Gui, add, Button, xp+110 yp  w80 h30 gmovedown , ▼
Gui, add, Button, xp+100 yp  w80 h30 gmoveup , ▲
Gui, add, Button, xm  yp+45  w100 h30 glvdelete , Delete
Gui, add, Edit, xp+120 yp w280 h30 vytburl, Youtube URL
Gui, add, Button, xp+310 yp  w80 h30 gytbdownload, Download
Gui, add, StatusBar, hwndhstatus, Application Start
Gui, show,, Play Anything !  by sendust 2021/4/24

Gui, font, s23
GuiControl, font, %htc%

Gui, font, s12
GuiControl, font, %hmarkinout%
GuiControl, font, %htcrem%

;ffmpeg := new FFMPEG_CLASS
;ffmpeg.start(" -f lavfi -re -i testsrc=size=1920x1080:r=30000/1001 -top 1 -pix_fmt uyvy422 -an  -progress udp://127.0.0.1:8888 -f decklink ""DeckLink Duo (1)""")

media := new MEDIA_CLASS()
media_frame1 := new MEDIA_CLASS()
ffmpeg := new FFMPEG_CLASS()
mpv := new MPV_CLASS()
mpv_sdipreview := new MPV_CLASS()
parameter := new param_processor()
youtube := new YOUTUBE_DL_CLASS(A_ScriptFullPath)
long_waiting_job := new LONG_JOB()
button_control := new BUTTONS_CONTROL([hload, hplay, hplay_list])
button_preview_control := new BUTTONS_CONTROL([hpreview])
rtsp := new RTSP_SERVER()
print("RTSP server started with pid " . rtsp.start())
;media.fullpath := "D:\capture\drama mxf test_VTR1_20210302_110209.mxf"
;analyse_media(media)
;printobjectlist(media)


status := Object()
	status.listplay := 0
	status.pbindex := 0

listv := new listviewclass(["NO", "CLIP", "IN", "OUT", "DURATION", "PROPERTY"])

ffmpeg.setport(get_ffmpegport(A_ScriptDir . "\playanything.ini"))				; Setup ffmpeg progress report port
ffmpeg.udp_start()																								; Start udp listen

print("Youtube download folder is " . youtube.read_ini(A_ScriptDir . "\playanything.ini"))

return

load:
button_control.btns_disable()
long_waiting_job.start()
play_media_firstframe(media)
long_waiting_job.end()
return

play:
print("play button Pressed")
status.listplay := 0
button_control.btns_disable()
play_media(media)
return


play_media(media)				;read any  media and sink to decklink			HD Version
{
	global parameter, ffmpeg
	duration := media.mark_out - media.mark_in
	if duration < 0
		duration := ""
	else
		duration := " -t " . duration
	IniRead, sdi_preview, playanything.ini, general, sdi_preview,  "rtsp://127.0.0.1:8854/anything1"
	streaming := " -map [vo2] -pix_fmt yuv420p  -r 30000/1001 -c:v mpeg2video -b:v 8000k -an " . duration . "   -f rtsp -rtsp_transport udp " . sdi_preview
	IniRead, outputvar, playanything.ini, general, decklink
	param := parameter.get_decklink_filter(media) . "  -map [vo1]  -max_muxing_queue_size 1024  -top 1 -pix_fmt uyvy422 -c:a pcm_s16le  -f decklink """ .  outputvar . """" . streaming
	print(param)
	ffmpeg.start(param)	
}


play_media_uhd(media)				;read any  media and sink to decklink		UHD Version
{
	global parameter, ffmpeg
	duration := media.mark_out - media.mark_in
	if duration < 0
		duration := ""
	else
		duration := " -t " . duration
	IniRead, sdi_preview, playanything.ini, general, sdi_preview,  "rtsp://127.0.0.1:8854/anything1"
	streaming := " -map [vo2] -pix_fmt yuv420p  -r 60000/1001 -c:v nvenc -preset:v ll -tune ll -b:v 8000k -an -bf 0 " . duration . "   -f rtsp -rtsp_transport udp " . sdi_preview
	IniRead, outputvar, playanything.ini, general, decklink
	param := parameter.get_decklink_filter_uhd(media) . "  -max_muxing_queue_size 1024  -pix_fmt uyvy422 -c:a pcm_s16le  -f decklink """ .  outputvar . """"
	print(param)
	ffmpeg.start(param)	
}




play_title(text)					; Create title picture and play it
{
	global ffmpeg
	fontfile := A_ScriptDir . "\naverdic.ttf"
	fontfile := StrReplace(fontfile, "\", "/")
	outputfile := A_ScriptDir . "\title.jpg"
	runstring =  -f lavfi -i color=black:size=1920x1080 -filter_complex drawtext=text="%text%":fontfile="%fontfile%":fontcolor=white:x=100:y=100:fontsize=30 -y -vframes 1 "%outputfile%"
	print(runstring)
	ffmpeg.start_simple(runstring)
	
}




play_media_firstframe(media)
{
	global parameter, ffmpeg
	
	media_frame1 := new MEDIA_CLASS()				; Create new media object for first frame still image

	if media.width < 1
	{
		print("Source is not image")
		return 1
	}
	
	source := media.fullpath
	start := media.mark_in
	
	runstring = -ss %start% -i "%source%"    -pix_fmt yuvj420p -an  -vframes 1  -y "%A_ScriptDir%\firstframe.jpg"
	print("Extract first image with        [ffmpeg_binary]  " . runstring)
	ffmpeg.start_simple(runstring)													; Write first frame with ffmpeg

	media_frame1.fullpath := A_ScriptDir . "\firstframe.jpg"			; read first frame still image
	analyse_media(media_frame1)													; analysis produced still image and play it
	play_media(media_frame1)
}


stop:
print("Stop button Pressed")
status.listplay := 0
ffmpeg.stop()
mpv.stop()
mpv_sdipreview.stop()
button_control.btns_enable()
return

preview:
print("Preview button Pressed")
preview_file(media)
;mpv.start(media)
button_preview_control.btns_disable()
return



preview_file(media) 					;    --pause --keep-open --force-window=yes --window-scale=0.5 --hr-seek=yes --osd-level=3 --osd-fractions 
{
	global mpv
	media_fullpath := media.fullpath
	SplitPath, media_fullpath, outfilename, outdir, outextension, outnamenoext, outdrive
	title := "Edit play <-----------> " . outfilename
	width := Round(A_ScreenWidth / 2)
	height := Round(A_ScreenHeight / 2)
	geometry := "  --geometry=" . width . "x" . height . "  "
	script := " --script=mark_inout_file.lua "
	mpv.title := title
	runstring := mpv.binary . "  --title=""" . title  . """" .  geometry  . script  . " --pause --keep-open --force-window=yes  --osd-level=3 --osd-fractions """ . media_fullpath . """"
	print(runstring)
	mpv.start(runstring)
}





addlist:
listv.addlist(media)
return


addtitle:
GuiControlGet, title_clip
listv.addtitle(title_clip)
return



lvclick:
print(A_GuiEvent)
if (A_GuiEvent = "DoubleClick")
{
	print("LV Double click with row number " . LV_GetNext(0))
	if LV_GetNext(0)
	{
		listv.restore_lv(LV_GetNext(0), media)			; resotre media information from listview
		show_mediainfo(media)
		print("List clip loaded")
	}
}

return

savedit:
if (listv.write_file("list.txt") . "  data saved")
	Run, list.txt

return

listload:
listv.read_file("list.txt")

return




listplay:
print("LIST Play button Pressed")
if !LV_GetNext(0)
	return
button_control.btns_disable()
status.pbindex := LV_GetNext(0)
print("Start List play..... Selected row is " . status.pbindex)
listv.restore_lv(status.pbindex, media)			; resotre media information from listview
show_mediainfo(media)
play_media(media)
show_pbindex(listv)
status.listplay := 1
return



get_ffmpegport(path)
{
	IniRead, outputvar, path, general, ffmpeg_port, 8888
	return outputvar
}



playlist_continue()
{
	global Status, listv, media, button_control
	print("Checking playlist continue play")
	if !status.listplay														; normal play mode (not playlist)
	{
		button_control.btns_enable()
		print("This is not playlist play")
		return
	}
	
	;;----------   Below is playlist play condition   -------------------------------------------------
	if (status.pbindex = listv.get_row_max())				; It was last playlist item
	{
		button_control.btns_enable()
		print("Finish playlist play")
	}

	if (status.pbindex < listv.get_row_max())				; playlist play mode and there is remain item
	{
		status.pbindex += 1
		print("This is list play. continue next play   --- " . status.pbindex)
		listv.restore_lv(status.pbindex, media)
		show_mediainfo(media)
		play_media(media)
		show_pbindex(listv)
	}
}



activate_preview_button()			; Enable preview button
{
	global button_preview_control
	button_preview_control.btns_enable()
}


show_pbindex(listv)
{
	global status, hlistrem
	Loop, % listv.get_row_max()
	{
		LV_Modify(A_Index,, A_Index)
		if (status.pbindex = A_Index)
		{
			newindex := "■ " . A_Index . " ▶"
			LV_Modify(A_Index,, newindex)
			LV_Modify(A_Index, "Vis")
		}
	}
	LV_ModifyCol()
	listrem := status.pbindex . "/" . LV_GetCount() . "   " . secondtotc(listv.get_list_rem(status.pbindex))
	GuiControl,, %hlistrem%, %listrem%
	;ToolTip, % listv.get_list_rem(status.pbindex)
}



show_mediainfo(media)
{
	global hinfo, hmarkinout
	tc_in := secondtotc(media.mark_in)
	tc_out := secondtotc(media.mark_out)
	GuiControl,, %hmarkinout%, %tc_in%`r`n%tc_out%
	GuiControl,, %hinfo%, % printobjectlist(media)
}


lvdelete:
Loop, % LV_GetCount("S")
{
	LV_Delete(LV_GetNext("F"))
	
}

return


GuiContextMenu:
print(A_GuiControl)
if (A_GuiControl = "Delete")				; Delete all LV data
	LV_Delete()
return



moveup:
listv.moveup(LV_GetNext(0))
return

movedown:
listv.movedown(LV_GetNext(0))
return


ytbdownload:
print("Youtube Download button Pressed")
GuiControlGet, ytburl
youtube.start(ytburl)
return







GuiDropFiles:
button_control.btns_disable()
long_waiting_job.start()
Sleep, 100			; wait while disable some buttons
Loop, parse, A_GuiEvent, "`n", "`r"
{
	media.fullpath := A_LoopField
	print(media.fullpath)
	Sleep, -1
	analyse_media(media)
	show_mediainfo(media)
	if InStr(A_GuiEvent, "`n")							; multiple files are dropped
	{
		print("multiple file drop is detected, add file to playlist  [ " . media.fullpath . " ]")
		gosub, addlist
	}
}
long_waiting_job.end()
button_control.btns_enable()
return



set_mark:
mpv.get_markinout()
update_gui_mark(mpv, media)
return


esc::
GuiClose:
print("Closing GUI......................  STOP all ffmpeg, mpv object")
ffmpeg.stop()
mpv.stop()
mpv_sdipreview.stop()
ExitApp



print(text)
{
	global hstatus
	FormatTime, outputvar,, yyyy-MM-dd HH:mm:ss
	outputvar .= "." . A_MSec
	FileAppend, `r`n%outputvar%  %text%, *
	updatelog(text)
	GuiControl,, %hstatus%, %outputvar%  %text%
}

printstatus(text)
{
	global hstatus
	GuiControl,, %hstatus%, %text%
	
}

updatelog(text)
{
	global logfile
	FormatTime, time_log,, yyyy/MM/dd HH:mm.ss
	if checklogfile(logfile)
		FileAppend, [%time_log%_%A_MSec%]  - Backup old log file .................`r`n, %logfile%
	FileAppend, [%time_log%_%A_MSec%]  - %text%`r`n, %logfile%
}

checklogfile(chkfile)
{
	FileGetSize, size, %chkfile%
	if (size > 3000000)
	{
		SplitPath, chkfile, outfilename, outdir, outextension, outnamenoext, outdrive
		FormatTime, outputvar,, yyyyMMdd-HHmmss
		FileMove, %chkfile%, %outdir%\%outnamenoext%_%outputvar%.%A_MSec%.%outextension%, 0
		return 1
	}
	else
		return 0
		
}


processexist(pid)
{
	if !pid				; pid is null
		return 0
	Process, Exist, %pid%
	result := ErrorLevel
	;print("Proving Process pid " . pid . "   result is " . result)
	return result
}


printobjectlist(myobject)
{
	temp := "`r`n--------   Print object list  ---------`r`n"
	for key, val in myobject
		temp .= key . " ---->  " . val . "`r`n"
	FileAppend, %temp%, *
	return temp
}


analyse_media(ByRef media)			; new, 2019/4/3 from mediainfo.dll  ----> Improve 2021/4/7
{
	static picture_extension := "jpg,bmp,tga,gif,tiff,psd,ai,jpeg,jfif,png"
	o_mi := new mediainfo
	o_mi.open(media.fullpath)
	
	media.extension := o_mi.getgeneral("FileExtension")
	media.duration := o_mi.getvideo("Duration") / 1000
	if (media.duration =	"")																	; added 2020/3/6 (video first, general second)
	media.duration := o_mi.getgeneral("Duration") / 1000			; Modified 2019/7/11 for audio only media
	media.start := o_mi.gettimecode()
	
	media.width := 0
	media.height := 0
	
	if o_mi.getvideo("Width")
	{
		media.width := o_mi.getvideo("Width")
		media.height :=  o_mi.getvideo("Height")
	}
	if o_mi.getimage("Width")
	{
		media.width := o_mi.getimage("Width") 
		media.height := o_mi.getimage("Height") 
	}
	media.resolution := media.width . "x" . media.height

	media.framerate := o_mi.getvideo("FrameRate")
	media.audio_format := o_mi.getaudiocount()
	media.codecv := o_mi.getvideo("Format")
	media.durationframe :=  o_mi.getvideo("FrameCount")	
	media.scantype := o_mi.getvideo("ScanType")	
	media.scantypeo := o_mi.getvideo("ScanType_Original")		; update 2021/4/21  (For some adobe product)
	if media.scantypeo																		; update 2021/4/21  (For some adobe product)
		media.scantype := media.scantypeo
	if (media.scantype = "MBAFF")
		media.scantype := "Interlaced"
		
	
	if ((InStr(picture_extension, media.extension)))				; added 2020/3/16			for time lapse picture
	{
	media.codecv := "picture"
	media.duration := 1 / 29.97
	media.durationframe := 1
	}
	
	media.mark_in := 0			; New !!! 201/4/13
	media.mark_out := media.duration
}



secondtotc(sec)				; unit is milisecond
{
	sign := ""
	if (sec < 0)
	{
		sign := "-"
		sec := Abs(sec)
	}
	sec := format("{:10.3f}", sec)
	sec_out := Floor(sec)
	frame_out := format("{:0.3f}", sec - sec_out)
	hour_out := format("{:02d}", sec_out // 3600)
	minute_out := format("{:02d}",  Mod(sec_out // 60, 60))
	second_out := format("{:02d}", Mod(sec_out, 60))

	return % sign . hour_out . ":" . minute_out . ":" . second_out . "." . SubStr(frame_out, -2)
}




update_gui_mark(byref mpv, byref media)
{
	global hmarkinout
	mark := mpv.get_markinout()
	mark_in := mark["mark_in"]
	mark_out := mark["mark_out"]
	if (mark_out < mark_in)
		mark_out := media.duration
	
	tc_in := secondtotc(mark_in)
	tc_out := secondtotc(mark_out)
	media.mark_in := mark_in
	media.mark_out := mark_out
	GuiControl,, %hmarkinout%, %tc_in%`r`n%tc_out%
}


show_ffmpeg_progress(enc_progress)
{
	global htc, htcrem, media, mpv_sdipreview
	static sec_old := 999999999
	sec := enc_progress.second
	tc := secondtotc(sec)
	if (sec < sec_old)				; Start SDI Monitor window (one time)
	{
		IniRead, url, playanything.ini, general, sdi_preview, "rtsp://127.0.0.1:8554/anything1"
		IniRead, geometry, playanything.ini, general, sdi_geometry,  "  --geometry=640x480+10+20  "
		title_param := " --title=""" . url . "  ----  SDI Preview .... no control ----"""
		mpv_sdipreview.title :=  url . "  ----  SDI Preview .... no control ----"
		runstring := "  --profile=low-latency  --taskbar-progress=no  --force-seekable=no --input-cursor=no --deinterlace   --osd-level=3 --osd-fractions  --input-default-bindings=no  --loop-playlist=force  " .  geometry .  title_param   .  "   """ . url . """" 
		print("Start SDI Preview Monitor with pid " . mpv_sdipreview.start_simple(runstring))
	}
	sec_old := sec
	duration := (media.mark_out - media.mark_in)
	tc_rem := secondtotc(duration - sec)
	GuiControl,, %htc%, %tc%
	GuiControl,, %htcrem%, %tc_rem%
	
}





#IfWinActive, Edit play <----------->				; Creates context-sensitive hotkeys and hotstrings.
~i::
print("[i] button pressed while preview play")
if processexist(mpv.pid)
	SetTimer, set_mark, -100				; Wait until mpv finish writing mpvinout.txt
return

~o::
print("[o] button pressed while preview play")
if processexist(mpv.pid)
	SetTimer, set_mark, -100				; Wait until mpv finish writing mpvinout.txt
return


~enter::
print("[enter] button pressed while preview play")
if processexist(mpv.pid)
	listv.addlist(media)
return

class BUTTONS_CONTROL
{
	button_list := Object()
	__New(ary)
	{
		print("Create button control object ---------")
		for key, val in ary
			this.button_list.push(val)
	}

	btns_enable()
	{
		ary := this.button_list
		for key, val in ary
			GuiControl, Enable, %val%
	}

	btns_disable()
	{
		ary := this.button_list
		for key, val in ary
		GuiControl, Disable, %val%
	}
}


class RTSP_SERVER
{

	__New()
	{
		this.binary := A_ScriptDir . "\bin\rtsp-simple-server.exe"
		this.pid := -1
	}
	
	start()
	{
		image := this.binary
		SplitPath, image, outfilename, outdir
		Process, Exist, %outfilename%			
		if !ErrorLevel									; Check if server is running and start it
			Run, %image%, %outdir%, Minimize , pid
		else
			pid := ErrorLevel
		this.pid := pid
		return pid
	}
	
	stop()
	{
		image := this.binary
		SplitPath, image, outfilename, outd
		Process, close, %outfilename%
		return ErrorLevel
	}
	
}


class LONG_JOB
{
	tick_start := 0
	
	start()
	{
		this.tick_start := A_TickCount
		this.timer := Func("show_jobprogress").bind(this)
		timer := this.timer
		SetTimer, % timer, 100
	}
	
	get_duration()
	{
		duration := A_TickCount - this.tick_start
		return duration / 1000
	}
	
	end()
	{
		timer := this.timer
		SetTimer, % timer, Delete
	}
	
}

show_jobprogress(job)
{
	global hstatus
	text := "Job under progress .... " . job.get_duration()
	GuiControl,, %hstatus%, %text%
}


class MEDIA_CLASS
{
	__New()
	{
		this.mark_in := 0
		this.mark_out := 0
		print("Create [media] object  ----------------------------")
	}
	
	reset()
	{
		this.mark_in := 0
		this.mark_out := 0
		this.audio_format := ""
		this.codecv := ""
		this.duration := 0
		this.durationframe := 0
		this.extension := ""
		this.framerate := 1
		this.height := 0
		this.resolution := ""
		this.scantype := ""
		this.start := ""
		this.width := 0
	}
	
	__Delete()
	{
		print("Delete [media] object   ----------------------------")
	}
}


class MPV_CLASS
{
	__New()
	{
		print("Creating [MPV] object  ------------------------------- ")
		this.binary := A_WorkingDir . "\bin\mpv.exe"
		this.pid := -1
		this.title := "MPV Default Title ------------ 3.1415926535898!@#@#$%#$^%%^&^%&*^*&$%#$% "
	}
	
	start(runstring)		
	{
		if processexist(this.pid)
			return
		Run, %runstring% , ,, pid
		this.pid := pid
		this.tick_start := A_TickCount
		;this.timer_start_onetime()
		this.timer := this.check_first_window.bind(this)
		timer := this.timer
		SetTimer, % timer, 100								; Start First check time
		print("Check MPV timer [First window] started")
		print("MPV started with pid, title " . pid . "   " . this.title)
		return runstring
	}
	
	start_simple(param)			; for sdi preview window
	{
		if processexist(this.pid)
			return
		binary := this.binary
		Run, %binary% %param% , , , pid
		this.pid := pid
		return pid
	}
	
	/*
	timer_start_onetime()
	{
		this.timer := this.check_first_window.bind(this)
		timer := this.timer
		SetTimer, % timer, 100
		print("Check MPV timer [First window] started")
		
	}
	*/
	
	timer_pid_chk()
	{
		this.timer := this.check_pid.bind(this)
		timer := this.timer
		SetTimer, % timer, 500
		print("Check MPV timer [pid] started")
	}
	
	check_first_window()			; Wait for mpv main window
	{
		elapsed := (A_TickCount - this.tick_Start) / 1000
		printstatus(elapsed . "s  ----- wait for mpv player")
		if (elapsed > 30)
		{
			printstatus("Wait more than 30 second.... Abort mpv open")
			this.timer_stop()
		}
		if WinExist(this.title)
		{
			this.timer_stop()
			this.timer_pid_chk()						; Start new timer (check mpv pid)
			title := this.title
			print("MPV window Opened")
			WinSet, Style, -0x20000, %title%				; remove minimize button
			WinSet, Style, -0x30000, %title%					; remove maximize button
		}
	}
	
	stop()
	{
		print("Try to stop mpv process, title " . this.pid . "    " . this.title)
		pid := this.pid
		Process, close,  %pid%
		title := this.title
		WinClose, %title%
		print("Finish to stop MPV")
	}
	
	
	check_pid()		;	check if mpv pid running
	{
		handle := this.hstatus
		if !processexist(this.pid)
		{
			this.timer_stop()
			this.pid := -1
			activate_preview_button()
		}
		else
			print("MPV with title " . this.title . "    is running")
	}


	timer_stop()
	{
		try
		{
			timer := this.timer
			SetTimer, % timer, Delete
			this.timer := ""
			print("MPV Timer Stop and Destroyed")
		}
		catch, err
			print(err)
	}
	
	get_markinout()				; Read text file created by mpv script
	{
		count := 0
		mpv_text := Object()
		mpvout_file := A_Temp . "\mpvinout.txt"
		hfile := FileOpen(mpvout_file, "r", "UTF-8")				; add utf-8 option,  2020/7/9
		while(!hfile.AtEOF)
		{

			line1 := hfile.ReadLine()
			line2 := hfile.ReadLine()

			line1 := StrReplace(line1, "`r`n", "")
			line2 := StrReplace(line2, "`r`n", "")   
			mpv_text[line1] := line2	
			count += 1
		}
		hfile.close()
		printobjectlist(mpv_text)
		return mpv_text
	}

	__Delete()
	{
		print("Delete [MPV] object ---------------------------------------------")
	}
	
}



class FFMPEG_CLASS					; FFMPEG Object (Monitor progress UDP, check PID is running)
{
	
	tick_start := 0
	
	__New()
	{
		this.udp_port := 8888
		this.pid := -1
		print("Create [FFMPEG] object  -------------------------------")
		;this.binary := A_WorkingDir . "\bin\ffmpeg2020_11.5.1.exe"
		this.binary := A_WorkingDir . "\bin\ffmpeg.exe"
	}
	
	setport(port)
	{
		this.udp_port := port
	}
	
	
	start(param)
	{
		if processexist(this.pid)
			return
		this.param := param
		runstring := this.binary . "  " . param
		print(runstring)
		file_ffreport = start_normal[%A_Now%.%A_MSec%]_.log
		EnvSet, FFREPORT, file=%file_ffreport%:level=24				; error, 16 / warning, 24 / info, 32 
		port := this.udp_port
		Run, %runstring%  -progress udp://127.0.0.1:%port% , %A_WorkingDir%\log, Minimize, pid
		this.pid := pid
		this.timer_start()
		this.tick_start := A_TickCount
	}

	start_simple(param)
	{
		runstring := this.binary . "  " . param
		file_ffreport = start_simple_[%A_Now%.%A_MSec%]_.log
		EnvSet, FFREPORT, file=%file_ffreport%:level=24				; error, 16 / warning, 24 / info, 32 
		RunWait, %runstring% , %A_WorkingDir%\log, Minimize, pid
	}

	stop()
	{
		pid := this.pid
		this.timer_stop()
		print("Try to stop ffmpeg")
		process, Close, %pid%
		print("Finish stop ffmpeg")
	}

	timer_start()
	{
		this.timer := this.ffmpeg_check.bind(this)
		timer := this.timer
		SetTimer, % timer, 1000
		print("Check timer started")
	}
	
	ffmpeg_check()
	{
		if processexist(this.pid)
		{
			duration := Floor((A_TickCount - this.tick_start) / 1000)
			if ((duration < 10) or (!mod(duration, 10)))
			print("FFMPEG is running with pid " . this.pid . "   running time " . duration . " sec")
		}
		else
		{
			print("FFMPEG stopped  //////////////////////////////////// ")
			this.timer_stop()
			this.pid := -1
			playlist_continue()
			;print("Restart FFMPEG ==========================")
			;this.start(this.param)
		}
	}
	
	timer_stop()
	{
		try
		{
			timer := this.timer
			SetTimer, % timer, Delete
			this.timer := ""
			print("FFMPEG Timer Stop and Destroyed")
		}
		catch, err
			print(err)
	}
	
	
	onudp()
	{
		string := this.RecvText(1000)
		;ToolTip %string%
		encoder_progress := Object()
		foundpos := RegExMatch(string, "out_time_ms=\d+", value)
		if foundpos
		{
			RegExMatch(value, "\d+", value)
			encoder_progress.second := value / 1000000				; microsecond to second
		}

		foundpos := RegExMatch(string, "speed=\d+.\d+", value)
		if foundpos
		{
			RegExMatch(value, "\d+.\d+", value)
			speed := value
			encoder_progress.speed := value							; speed
		}

		foundpos := RegExMatch(string, "fps=\d+.\d+", fps)				; ffmpeg2014ver does not report speed
		if foundpos
		{
			RegExMatch(fps, "\d+.\d+", fps)
			encoder_progress.fps := fps
		}
		
		foundpos := RegExMatch(string, "progress=\w+", prog)
		if foundpos
		{	
			new_progress := Object()
			new_progress := StrSplit(prog, "=")
			;ToolTip, % new_progress[2]
			encoder_progress.prog := new_progress[2]
			if (new_progress[2] = "end")
				print("Finish FFMPEG processing ..........  ")
		}
		;printobjectlist(encoder_progress)
		show_ffmpeg_progress(encoder_progress)
	}
	
	udp_start()
	{
		this.udp := new SocketUDP
		this.udp.bind(["127.0.0.1", this.udp_port])
		this.udp.onRecv := this.onudp.bind()
		print("Start UDP listen with port " . this.udp_port)
	}
	
	udp_close()
	{
	try
	{
		this.udp.Disconnect()
		this.udp := ""
		print("Close UDP Listen")
	}
	catch, e
		printobjectlist(e)
	}
	
	__Delete()
	{
		print("Delete [FFMPEG] object -------------------------------")
	}
}

class YOUTUBE_DL_CLASS
{
	__New(fullpath)
	{
		SplitPath, fullpath, outfilename, outdir, outextension, outnamenoext, outdrive
		this.binary := outdir . "\bin\youtube-dl.exe"
		this.folder := outdir
	}
	
	read_ini(ini_file)
	{
		IniRead, path, %ini_File%, youtube, location, %A_Desktop%
		path := RegExReplace(path, "\\$")				; remove last \
		this.folder := path
		return path
	}
	
	start(url)
	{
		binary := this.binary
		outputfolder := this.folder
		Run, %binary% "%url%", %outputfolder%,, pid
		return pid
	}
	
	
}


class listviewclass
{
	column := Object()
	count_column := 0
	
	__New(column_array)
	{
		count_column := 0
		for key, val in column_array
		{
			this.column.push(val)
			count_column += 1
			LV_InsertCol(key,"60", val)			; add column Header with fixed width
		}
		this.count_column := count_column
		print("Total column is " . count_column)
	}
	
	read_file(filename)
	{
		LV_Delete()
		count_delimiter := this.count_column - 1
		Loop, read, %filename%
		{
			print(A_LoopReadLine)
			RegExReplace(A_LoopReadLine, "##",,count)	; probe number of delimiter
			print("Delimiter number is " . count)
			if (count = count_delimiter)
			{
				str_array := StrSplit(A_LoopReadLine, "##", "`r`n")
				LV_Add(, str_array[1], str_array[2], str_array[3], str_array[4], str_array[5], str_array[6])
			}
			else
				print("listview read syntax error")
		}
		LV_ModifyCol()
	}
	
	addlist(media)
	{
		count := % LV_GetCount()
		count += 1
		fullpath := media.fullpath
		SplitPath, fullpath, outfilename
		media_property := media.fullpath . "|" . media.scantype . "|" media.width . "|" media.height . "|" media.audio_format . "|" media.codecv . "|" media.durationframe . "|" media.framerate
		LV_Add(, count, outfilename, media.mark_in, media.mark_out, (media.mark_out - media.mark_in), media_property)
		LV_ModifyCol()
		
	}
	
	addtitle(text)
	{
		title_show = <HEAD>  %text%
		count := % LV_GetCount()
		count += 1
		media_property :=  "<<TITLE>>|PROGRESSIVE|1920|1080|NOAUDIO|PICTURE|1|29.97"
		LV_Add(, count, title_show, 0, 0.034, 0.034, media_property)
		LV_ModifyCol()
	}
	
	get_list_rem(pbindex)
	{
		remain := 0
		Loop, % LV_GetCount()
		{
			if (A_Index > pbindex)
			{
				LV_GetText(outputvar, A_Index, 5)
				remain += outputvar
			}
		}
		return remain
	}
	
	
	get_all(rownumber)					; Retrieve single row data
	{
		result := Object()
		Loop, % this.count_column
		{
			LV_GetText(outputvar, rownumber, A_Index)
			result.push(outputvar)
		}
		printobjectlist(result)
		return result
	}
	
	put_all(rownumber, data)			; restore single row with data
	{
		LV_Modify(rownumber,, data[1], data[2], data[3], data[4], data[5], data[6])
	}
	
	renumber()
	{
		Loop, % LV_GetCount()
			LV_Modify(A_Index,, A_Index)
	}
	
	moveup(row)
	{
		row1 := Object()
		row2 := Object()
		if (row > 1)
		{
			row1 := this.get_all(row-1)
			row2 := this.get_all(row)
			this.put_all(row, row1)
			this.put_all(row-1, row2)
			this.sel_none()
			this.sel_row(row-1)
		}
	}
	
	movedown(row)
	{
		row1 := Object()
		row2 := Object()
		if (row < LV_GetCount())
		{
			row1 := this.get_all(row)
			row2 := this.get_all(row+1)
			this.put_all(row, row2)
			this.put_all(row+1, row1)
			this.sel_none()
			this.sel_row(row+1)
		}
	}
	
	
	
	restore_lv(row, byref media)
	{
		media.reset()
		LV_GetText(outputvar, row, 3)
		media.mark_in := outputvar
		LV_GetText(outputvar, row, 4)
		media.mark_out := outputvar
		LV_GetText(outputvar, row, 5)
		media.duration := outputvar
		LV_GetText(outputvar, row, 6)
		array_split := StrSplit(outputvar, "|")			; Decode property columnn with delimiter
		media.fullpath := array_split[1]
		media.scantype := array_split[2]
		media.width := array_split[3]
		media.height := array_split[4]
		media.audio_format := array_split[5]
		media.codecv := array_split[6]
		media.durationframe := array_split[7]
		media.framerate := array_split[8]
		media.resolution := media.width . "x" . media.height
		printobjectlist(media)
	}
	
		
	write_file(filename)
	{
		this.renumber()
		count := 0
		FileDelete, %filename%			; Delete old file
		Loop, % LV_GetCount()
		{
			temp := Object()
			temp := this.get_all(A_Index)
			rowdata := ""
			for key, val in temp
				rowdata .= val . "##"
			rowdata := RegExReplace(rowdata, "##$", "")
			FileAppend, %rowdata%`r`n, %filename%
			count += 1
		}
		return count
	}


	sel_all()
	{
		Loop, % LV_GetCount()
			LV_Modify(A_Index, "Select")
	}
	
	sel_row(row)
	{
		LV_Modify(row, "Select")
		LV_Modify(row, "Vis")
	}
	
	sel_none()
	{
		Loop, % LV_GetCount()
			LV_Modify(A_Index, "-Select")
	}
	
	get_row_max()
	{
		return % LV_GetCount()
	}
}


