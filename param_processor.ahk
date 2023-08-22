;  parameter processor for FFMPEG, MPV
;  Managed by sendust
;  Last edit : 2021/4/8
;
;



class param_processor
{
	mpv_filter := Object()
	audio_monitor := Object()
	ffmpeg_decklink := Object()
	ffmpeg_decklink_uhd := Object()


	__New()
	{
		this.mpv_filter["noaudio"] := ""
		this.mpv_filter["mono-1"] := "--lavfi-complex=[aid1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["mono-2"] := "--lavfi-complex=[aid1][aid2]amerge=inputs=2[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["mono-4"] := "--lavfi-complex=[aid1][aid2][aid3][aid4]amerge=inputs=4[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["mono-6"] := "--lavfi-complex=[aid1][aid2][aid3][aid4][aid5][aid6]amerge=inputs=6[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["mono-8"] := "--lavfi-complex=[aid1][aid2][aid3][aid4][aid5][aid6][aid7][aid8]amerge=inputs=8[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["stereo-1"] := "--lavfi-complex=[aid1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["stereo-2"] := "--lavfi-complex=[aid1][aid2]amerge=inputs=2[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["stereo-3"] := "--lavfi-complex=[aid1][aid2][aid3]amerge=inputs=3[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"
		this.mpv_filter["stereo-4"] := "--lavfi-complex=[aid1][aid2][aid3][aid4]amerge=inputs=4[a1];[a1]asplit[as1][as2];[as2]showvolume=r=29.97[vvolume];[vid1]format=pix_fmts=yuv420p[vf];[vf][vvolume]overlay=x=20:y=20[vo]"

		this.audio_monitor["CH1"] := "c0"
		this.audio_monitor["CH2"] := "c1"
		this.audio_monitor["CH3"] := "c2"
		this.audio_monitor["CH4"] := "c3"
		this.audio_monitor["CH5"] := "c4"
		this.audio_monitor["CH6"] := "c5"
		this.audio_monitor["CH7"] := "c6"
		this.audio_monitor["CH8"] := "c7"
		this.audio_monitor["CH1+CH3"] := "c0+c2"
		this.audio_monitor["CH2+CH4"] := "c1+c3"

		this.mpv_filter["stereo-4"] := mpv_filter["mono-4"]
		this.mpv_filter["5.1-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["7.1-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["8-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["16-1"] := mpv_filter["stereo-1"]

		this.mpv_filter["2 channels-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["2 channels-2"] := mpv_filter["stereo-2"]
		this.mpv_filter["2 channels-3"] := mpv_filter["stereo-3"]
		this.mpv_filter["2 channels-4"] := mpv_filter["stereo-4"]

		this.mpv_filter["4 channels-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["5 channels-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["6 channels-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["7 channels-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["8 channels-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["16 channels-1"] := mpv_filter["stereo-1"]
		this.mpv_filter["32 channels-1"] := mpv_filter["stereo-1"]

		;this.ffmpeg_decklink["HD"] := """[0:v]null"
		;this.ffmpeg_decklink["default_v"] := """[0:v]scale=1920x1080[vs];[vs]framerate=fps=60000/1001[vfps];[vfps]tinterlace=4"
		this.ffmpeg_decklink["default_v"] := " -filter_complex ""[0:v]scale=1920x1080:force_original_aspect_ratio=decrease[vs];[vs]pad=w=1920:h=1080:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vhd];[vhd]framerate=fps=60000/1001[vfps];[vfps]tinterlace=4[vout];[vout]split[vo1][vo2]"
		this.ffmpeg_decklink["interlace_2997_1920"] := " -filter_complex ""[0:v]split[vo1][vo2]"
		this.ffmpeg_decklink["interlace_5994_1920"] := " -filter_complex ""[0:v]split[vo1][vo2]"
		this.ffmpeg_decklink["interlace_2997_1440"] := " -filter_complex ""[0:v]scale=1920x1080:interl=1[vout];[vout]split[vo1][vo2]"
		this.ffmpeg_decklink["interlace"] := " -filter_complex ""[0:v]yadif=mode=send_frame:parity=1:deint=0[vdeint];[vdeint]scale=1920x1080:interl=1[vsize];[vsize]framerate=fps=60000/1001[vfps];[vfps]tinterlace=4[vout];[vout]split[vo1][vo2]"
		this.ffmpeg_decklink["picture"] := " -filter_complex ""[0:v]scale=1920x1080:force_original_aspect_ratio=decrease[vs];[vs]pad=w=1920:h=1080:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vhd];[vhd]loop=loop=-1:size=1:start=0[vout];[vout]split[vo1][vo2]"
		this.ffmpeg_decklink["only_audio"] := " -f lavfi -re -i testsrc=size=1920x1080:r=30000/1001 -filter_complex ""drawbox=color=black@0.4:y=80:width=iw:height=120:t=fill[vbox];[vbox]drawtext=text='SBS INGEST/AUDIO Playing':fontcolor=white:fontsize=100:x=200:y=100[vtitle];[vtitle]split[vo1][vo2]"

/*
		this.ffmpeg_decklink_uhd["default_v"] := " -filter_complex ""[0:v]scale=3840x2160:force_original_aspect_ratio=decrease[vs];[vs]pad=w=3840:h=2160:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vhd];[vhd]framerate=fps=60000/1001"
		this.ffmpeg_decklink_uhd["uhd_5994_3840"] := " -filter_complex ""[0:v]null"
		this.ffmpeg_decklink_uhd["interlace_2997_1920"] := " -filter_complex ""[0:v]yadif=mode=send_field[vdeint];[vdeint]scale=3840x2160[vs];[vs]fps=60000/1001"
		this.ffmpeg_decklink_uhd["interlace_5994_1920"] := this.ffmpeg_decklink_uhd["interlace_2997_1920"]
		this.ffmpeg_decklink_uhd["interlace_2997_1440"] := this.ffmpeg_decklink_uhd["interlace_2997_1920"]
		this.ffmpeg_decklink_uhd["interlace"] := " -filter_complex ""[0:v]yadif=mode=send_frame:parity=1:deint=0[vdeint];[vdeint]scale=3840x2160[vsize];[vsize]framerate=fps=60000/1001"
		this.ffmpeg_decklink_uhd["picture"] := " -filter_complex ""[0:v]scale=3840x2160:force_original_aspect_ratio=decrease[vs];[vs]pad=w=3840:h=2160:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vhd];[vhd]loop=loop=-1:size=1:start=0"
		this.ffmpeg_decklink_uhd["only_audio"] := " -f lavfi -re -i smptehdbars=size=3840x2160:r=60000/1001 -filter_complex ""null"
*/

		this.ffmpeg_decklink_uhd["default_v"] := " -filter_complex ""[0:v]split[v1][v2];[v1]scale=3840x2160:force_original_aspect_ratio=decrease[vs];[vs]pad=w=3840:h=2160:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vhd];[vhd]framerate=fps=60000/1001[vo1];[v2]fps=30000/1001[vfpspvw];[vfpspvw]scale=960x540:force_original_aspect_ratio=decrease[vspvw];[vspvw]pad=w=960:h=540:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vo2]"
		this.ffmpeg_decklink_uhd["uhd_5994_3840"] := " -filter_complex ""[0:v]split[vo1][v2];[v2]fps=30000/1001[vfpspvw];[vfpspvw]scale=iw/4:ih/4:flags=fast_bilinear[vo2]"
		this.ffmpeg_decklink_uhd["interlace_2997_1920"] := " -filter_complex ""[0:v]split[v1][v2];[v1]yadif=mode=send_field[vdeint];[vdeint]scale=3840x2160[vs];[vs]fps=60000/1001[vo1];[v2]fps=30000/1001[vfpspvw];[vfpspvw]scale=960x540:flags=fast_bilinear[vo2]"
		this.ffmpeg_decklink_uhd["interlace_5994_1920"] := this.ffmpeg_decklink_uhd["interlace_2997_1920"]
		this.ffmpeg_decklink_uhd["interlace_2997_1440"] := this.ffmpeg_decklink_uhd["interlace_2997_1920"]
		this.ffmpeg_decklink_uhd["interlace"] := " -filter_complex ""[0:v]split[v1][v2];[v1]yadif=mode=send_field:deint=0[vdeint];[vdeint]framerate=fps=60000/1001[vfps];[vfps]scale=3840x2160[vo1];[v2]fps=30000/1001[vfpspvw];[vfpspvw]scale=960x540:flags=fast_bilinear[vo2]"
		this.ffmpeg_decklink_uhd["picture"] := " -filter_complex ""[0:v]split[v1][v2];[v1]scale=3840x2160:force_original_aspect_ratio=decrease[vs];[vs]pad=w=3840:h=2160:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vhd];[vhd]loop=loop=-1:size=1:start=0[vo1];[v2]scale=960x540:force_original_aspect_ratio=decrease[vsize];[vsize]pad=w=960:h=540:x=(ow-iw)/2:y=(oh-ih)/2:color=black[vhd];[vhd]loop=loop=-1:size=1:start=0[vo2]"
		this.ffmpeg_decklink_uhd["only_audio"] := " -f lavfi -re -i testsrc=size=1920x1080:r=30000/1001 -filter_complex ""drawbox=color=black@0.4:y=80:width=iw:height=120:t=fill[vbox];[vbox]drawtext=text='SBS INGEST/AUDIO Playing':fontcolor=white:fontsize=100:x=200:y=100[vtitle];[vtitle]split[v1][vo2];[v1]scale=3840x2160[vscale];[vscale]fps=60000/1001[vo1]"


		;this.ffmpeg_decklink["noaudio"] := ";anullsrc[as];[as]aresample=48000[are];[are]pan=7.1"""		; depricated 2021/4/12
		this.ffmpeg_decklink["noaudio"] := """"
		this.ffmpeg_decklink["mono-1"] := ";[0:a]aresample=48000[are];[are]pan=7.1|c0=c0[apan];[apan]apad=pad_dur=1"""				; OSMO Camera
		this.ffmpeg_decklink["mono-2"] := ";amerge=inputs=2[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["mono-4"] := ";amerge=inputs=4[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["mono-8"] := ";amerge=inputs=8[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5|c6=c6|c7=c7[apan];[apan]apad=pad_dur=1"""			; MXF format
		this.ffmpeg_decklink["mono-16"] := ";amerge=inputs=16[am];[am]aresample=48000[are];[are]pan=hexadecagonal|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5|c6=c6|c7=c7|c8=c8|c9=c9|c10=c10|c11=c11|c12=c12|c13=c13|c14=c14|c15=c15[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["mono-32"] := this.ffmpeg_decklink["mono-16"]

		this.ffmpeg_decklink["2 channels-1"] := ";[0:a]aresample=48000[are];[are]apad=pad_dur=2[apd];[apd]pan=7.1|c0=c0|c1=c1[apan];[apan]apad=pad_dur=1"""			; Most ordinary media format
		this.ffmpeg_decklink["2 channels-2"] := ";amerge=inputs=2[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["2 channels-3"] := ";amerge=inputs=3[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["2 channels-4"] := ";amerge=inputs=4[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5|c6=c6|c7=c7[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["2 channels-8"] := ";amerge=inputs=8[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5|c6=c6|c7=c7|c8=c8|c9=c9|c10=c10|c11=c11|c12=c12|c13=c13|c14=c14|c15=c15[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["2 channels-16"] := ";amerge=inputs=16[am];[am]aresample=48000[are];[are]pan=hexadecagonal|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5|c6=c6|c7=c7|c8=c8|c9=c9|c10=c10|c11=c11|c12=c12|c13=c13|c14=c14|c15=c15[apan];[apan]apad=pad_dur=1"""

		this.ffmpeg_decklink["4 channels-1"] := ";[0:a]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["4 channels-2"] := ";amerge=inputs=2[am];[am]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5|c6=c6|c7=c7[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["5 channels-1"] := ";[0:a]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["6 channels-1"] := ";[0:a]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5[apan];[apan]apad=pad_dur=1"""					; MTS camera
		this.ffmpeg_decklink["6 channels-2"] := ";[0:a]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5[apan];[apan]apad=pad_dur=1"""					; DVD AC3
		this.ffmpeg_decklink["7 channels-1"] := ";[0:a]aresample=48000[are];[are]pan=7.1|c0=c0|c1=c1|c2=c2|c3=c3|c4=c4|c5=c5|c6=c6[apan];[apan]apad=pad_dur=1"""
		this.ffmpeg_decklink["8 channels-1"] := ";[0:a]aresample=48000[are];[are]apad=pad_dur=1"""					; SBS SD DAS Archived format  (Use Decklink 8 channel pure mapping)
		this.ffmpeg_decklink["16 channels-1"] := ";[0:a]aresample=48000[are];[are]apad=pad_dur=1"""				; Use Decklink 16 channel pure mapping
		this.ffmpeg_decklink["32 channels-1"] := this.ffmpeg_decklink["16 channels-1"]

		this.ffmpeg_decklink["default_a"] := this.ffmpeg_decklink["noaudio"]
	}

	get_mpv_filter(media_info, ch_l, ch_r)
	{


	}


	get_decklink_filter(media_info)
	{
		start_option := " -ss " . media_info.mark_in
		if !media_info.mark_in				; avoid unnecessary seek try
			start_option := ""

		input_option := ""
		if (media_info.codecv = "H.265") and (media_info.extension = "avi")		; Exception for CCTV H265 non standard avi format (2021/5/17)
		{
			input_option :=  " -f hevc "
		}

		start_option := start_option . input_option
		filter_audio := this.ffmpeg_decklink[media_info.audio_format]			; Decide Audio filter
		if (!media_info.codeca)							; No valid audio codec
			filter_audio := this.ffmpeg_decklink["NOAUDIO"]				; Exception for CCTV H265 non standard avi format  (2021/5/17)


		if ((media_info.scantype = "Interlaced") and (media_info.framerate = 29.97) and (media_info.width = 1920) and (media_info.height = 1080))
		{
			filter_video := this.ffmpeg_decklink["interlace_2997_1920"]
			param :=  start_option .  " -i "  . """" . media_info.fullpath  . """" . filter_video . filter_audio
			return param				; 29.97 HD standard, interlaced
		}

		if ((media_info.scantype = "Interlaced") and (media_info.framerate = 59.94) and (media_info.width = 1920) and (media_info.height = 1080))
		{
			filter_video := this.ffmpeg_decklink["interlace_5994_1920"]
			param :=  start_option .  " -i "  . """" . media_info.fullpath  . """" . filter_video . filter_audio
			return param				; 59.94 HD standard, interlaced (for some mp4, invalid metadata)
		}


		if ((media_info.scantype = "Interlaced") and (media_info.framerate = 29.97) and (media_info.width = 1440) and (media_info.height = 1080))
		{
			filter_video := this.ffmpeg_decklink["interlace_2997_1440"]
			param := start_option .  " -i "  . """" . media_info.fullpath  . """" . filter_video . filter_audio
			return param				; 29.97 HD HDV
		}

		if (media_info.scantype = "Interlaced")
		{
			filter_video := this.ffmpeg_decklink["interlace"]
			param :=  start_option .  " -i "  . """" . media_info.fullpath .  """" . filter_video . filter_audio
			return param
		}

		if ((media_info.width > 0) and !(media_info.framerate))				; Image (picture) source
		{
			filter_video := this.ffmpeg_decklink["picture"]
			filter_audio := """"
			param := "  -i "  . """" . media_info.fullpath . """" . filter_video . filter_audio
			return param
		}

	if ((!media_info.width) and media_info.duration)			; audio only source
	{
		filter_video := this.ffmpeg_decklink["only_audio"]
		param :=  start_option .  " -i "  . """" . media_info.fullpath . """" . filter_video . filter_audio
		return param
	}

		filter_video := this.ffmpeg_decklink["default_v"]			; Default parameter
		param :=  start_option .  " -i "  . """" . media_info.fullpath . """" . filter_video . filter_audio
		return param
	}


	get_decklink_filter_uhd(media_info)
	{
		start_option := " -ss " . media_info.mark_in
		if !media_info.mark_in				; avoid unnecessary seek try
			start_option := ""
		duration := media_info.mark_out - media_info.mark_in

		if ((media_info.scantype = "Progressive") and (media_info.framerate = 59.94) and (media_info.width = 3840) and( media_info.height = 2160))
		{
			filter_video := this.ffmpeg_decklink_uhd["uhd_5994_3840"]
			filter_audio := this.ffmpeg_decklink[media_info.audio_format]
			param :=  start_option .  " -i "  . """" . media_info.fullpath  . """" . filter_video . filter_audio
			return param				; 59.94 3840x2160 UHD Standard
		}

		if ((media_info.scantype = "Interlaced") and (media_info.framerate = 29.97) and (media_info.width = 1920) and (media_info.height = 1080))
		{
			filter_video := this.ffmpeg_decklink_uhd["interlace_2997_1920"]
			filter_audio := this.ffmpeg_decklink[media_info.audio_format]
			param :=  start_option .  " -i "  . """" . media_info.fullpath  . """" . filter_video . filter_audio
			return param				; 29.97 HD standard, interlaced
		}

		if ((media_info.scantype = "Interlaced") and (media_info.framerate = 59.94) and (media_info.width = 1920) and (media_info.height = 1080))
		{
			filter_video := this.ffmpeg_decklink_uhd["interlace_5994_1920"]
			filter_audio := this.ffmpeg_decklink[media_info.audio_format]
			param :=  start_option .  " -i "  . """" . media_info.fullpath  . """" . filter_video . filter_audio
			return param				; 59.94 HD standard, interlaced (for some mp4, invalid metadata)
		}


		if ((media_info.scantype = "Interlaced") and (media_info.framerate = 29.97) and (media_info.width = 1440) and (media_info.height = 1080))
		{
			filter_video := this.ffmpeg_decklink_uhd["interlace_2997_1440"]
			filter_audio := this.ffmpeg_decklink[media_info.audio_format]
			param := start_option .  " -i "  . """" . media_info.fullpath  . """" . filter_video . filter_audio
			return param				; 29.97 HD HDV
		}

		if (media_info.scantype = "Interlaced")
		{
			filter_video := this.ffmpeg_decklink_uhd["interlace"]
			filter_audio := this.ffmpeg_decklink[media_info.audio_format]
			param :=  start_option .  " -i "  . """" . media_info.fullpath .  """" . filter_video . filter_audio
			return param
		}

		if ((media_info.width > 0) and !(media_info.framerate))				; Image source
		{
			filter_video := this.ffmpeg_decklink_uhd["picture"]
			filter_audio := """"
			param := "  -i "  . """" . media_info.fullpath . """" . filter_video . filter_audio
			return param
		}

	if ((!media_info.width) and media_info.duration)			; audio only source
	{
		filter_video := this.ffmpeg_decklink_uhd["only_audio"]
		filter_audio := this.ffmpeg_decklink[media_info.audio_format]
		param :=  start_option .  " -i "  . """" . media_info.fullpath . """" . filter_video . filter_audio
		return param
	}

		filter_video := this.ffmpeg_decklink_uhd["default_v"]
		filter_audio := this.ffmpeg_decklink[media_info.audio_format]
		param :=  start_option .  " -i "  . """" . media_info.fullpath . """" . filter_video . filter_audio
		return param
	}
}

