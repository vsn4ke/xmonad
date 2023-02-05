module My.Xmobar where

import Data.List (intersperse)
import XMonad.Hooks.DynamicLog (wrap, xmobarColor)
import XMonad.Util.Run (spawnPipe)

myTemplates :: Int -> (String, String, String)
myTemplates s
  | s == 0 = leftTmpl
  | s == 1 = rightTmpl
 where
  leftTmpl =
    ( "| %StdinReader% |"
    , ""
    , "| <fc=#ee9a00>%date%</fc> |"
    )
  rightTmpl =
    ( "| %cpu% | %memory% | %disku% |"
    , ""
    , "| %dynnetwork% | %w% |%trayerpad%"
    )

myCommands :: Int -> [String]
myCommands s
  | s == 0 = leftCmds
  | s == 1 = rightCmds
 where
  leftCmds =
    [ "Run StdinReader"
    , "Run Date \"%a %Y-%m-%d %H:%M\" \"date\" 600"
    ]
  rightCmds =
    [ "Run Cpu [ \"-t\", \"CPU:<total>%\",\
      \ \"-p\", \"3\",\
      \ \"-H\", \"70\",\
      \ \"--normal\", \"green\",\
      \ \"--high\",\"red\"\
      \ ] 50"
    , "Run Memory   [\"-t\",\"MEM:<used>M used\"] 50"
    , "Run DiskU [(\"/home\", \"HDD:<used> used\")][] 600"
    , "Run DynNetwork [\"-t\", \"Down <rx>KB Up <tx>KB\"] 100"
    , "Run Com \"/bin/sh\" [\"-c\",\"/home/vsn4ke/.config/xmonad/script/trayer-padding-icon.sh\"] \"trayerpad\" 100"
    , "Run Com \"/bin/sh\" [\"-c\", \"/home/vsn4ke/.config/xmonad/script/xb_weather\"] \"w\" 36000"
    ]

spawnBar s = spawnPipe cmd
 where
  cmd =
    unwords
      [ "/usr/bin/xmobar"
      , "-f 'xft:Hack Nerd Font:style=Regular:pixelsize=16:antialias=true:hinting=light'"
      , "-B '#282c34'"
      , "-F '#55aaaa'"
      , "-o"
      , "-a '}{'"
      , "-s '%'"
      , "-t"
      , fmtt $ myTemplates s
      , "-c"
      , fmtc $ myCommands s
      , "-x"
      , show s
      ]
   where
    fmtt (l, c, r) = wrap "'" "'" $ l ++ "}" ++ c ++ "{" ++ r
    fmtc x = wrap "'[ " " ]'" $ unwords $ intersperse "," x