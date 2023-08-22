@Echo off
Echo "Caution !! backup Local ------> Jungbi2 .. Press any key to continue !!"
pause
Echo "Are you shure ?   Local =====> Jungbi2"
pause

robocopy . \\jungbi2\jinsinwoo$\ahk\playanything /dcopy:t /mir
pause
