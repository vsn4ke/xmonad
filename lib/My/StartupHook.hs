module My.StartupHook where

import My.Globals
import XMonad
import XMonad.Util.SpawnOnce

myStartupHook :: X ()
myStartupHook = do
    spawn "killall conky"
    spawn "killall trayer"
    spawnOnce "picom --backend glx --vsync"
    spawnOnce "nm-applet"
    spawnOnce "pasystray"
    spawnOnce "xmodmap -e \"pointer = 1 2 3\""
    spawn ("xmobar -x 1 " ++ xmobarCfgPath ++ "1")
    spawn ("sleep 2 && conky -c " ++ xmonadCfgPath ++ "/01.conkyrc")
    spawn "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34 --height 22"
    spawnOnce "feh --randomize --bg-fill ~/Images/wallpaper/*"
