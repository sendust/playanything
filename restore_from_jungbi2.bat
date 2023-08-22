@Echo off
Echo "Caution !!! Restore Jungbi2 --> Local folder ...  Press any key to continue"
pause
Echo "Are you shure ?   Jungbi2  =====> Local folder"
pause
robocopy \\jungbi2\jinsinwoo$\ahk\playanything . /dcopy:t /mir
pause
