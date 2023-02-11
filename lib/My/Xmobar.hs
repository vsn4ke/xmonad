module My.Xmobar where
import Data.List (intersperse)
import My.Globals (scriptPath)
import Text.ParserCombinators.ReadP (sepBy)
import XMonad.Hooks.DynamicLog (wrap, xmobarColor)
import XMonad.Util.Run (spawnPipe)

colorLow, colorNorm, colorHigh, thresholdHigh, thresholdLow, thresholdNetHigh, thresholdNetLow, cpu, mem, diskU, dynNetwork :: String
colorLow = "\"--low\", \"green\""
colorNorm = "\"--normal\", \"darkorange\""
colorHigh = "\"--high\", \"darkred\""
thresholdLow = "\"--Low\", \"60\""
thresholdHigh = "\"--High\", \"80\""
thresholdNetLow = "\"--Low\", \"3000\""
thresholdNetHigh = "\"--High\", \"5000\""
cpu = "\"-t\", \"Cpu <bar>\""
mem = "\"-t\",\"Mem <usedbar>\""
diskU = "(\"/home\", \"Hdd <usedbar>\")"
dynNetwork = "\"-t\", \"D:<rx>Kb/s Up:<tx>Kb/s\""

myTemplates :: Int -> (String, String)
myTemplates s
  | s == 0 = leftTmpl
  | s == 1 = rightTmpl
  where
    leftTmpl =
      ( "| %StdinReader% |",
        "| %date% |"
      )
    rightTmpl =
      ( "| %cpu% | %memory% | %disku% |",
        "| %dynnetwork% | %w% |%trayerpad%"
      )

myCommands :: Int -> [String]
myCommands s
  | s == 0 = leftCmds
  | s == 1 = rightCmds
  where
    leftCmds =
      [ "Run StdinReader",
        "Run Date \"%a %d-%m-%Y %H:%M\" \"date\" 600"
      ]
    rightCmds =
      [ runCpu [cpu, thresholdLow, thresholdHigh, colorLow, colorNorm, colorHigh],
        runMem [mem, thresholdLow, thresholdHigh, colorLow, colorNorm, colorHigh],
        runDiskU [thresholdHigh, colorHigh],
        runDynNetwork [dynNetwork],
        "Run Com \"/bin/sh\" [\"-c\",\"" ++ scriptPath ++ "/padding\"] \"trayerpad\" 100",
        "Run Com \"/bin/sh\" [\"-c\", \"" ++ scriptPath ++ "/xb_weather\"] \"w\" 36000"
      ]
      where
        runCpu = sepByComma "Run Cpu [" "] 30"
        runMem = sepByComma "Run Memory [" "] 30"
        runDiskU = sepByComma ("Run DiskU [" ++ diskU ++ "][") "] 600"
        runDynNetwork = sepByComma "Run DynNetwork [" "] 30"

sepByComma :: String -> String -> [String] -> String
sepByComma f s x = wrap f s $ unwords $ intersperse "," x

spawnBar s = spawnPipe cmd
  where
    cmd =
      unwords
        [ "xmobar",
          "-f 'Mononoki Nerd Font Regular 16'",
          "-B '#282c34'",
          "-F '#55aaaa'",
          "-o",
          "-a '}{'",
          "-s '%'",
          "-t",
          fmtt $ myTemplates s,
          "-c",
          fmtc $ myCommands s,
          "-x",
          show s
        ]
      where
        fmtt (l, r) = wrap "'" "'" $ l ++ "}{" ++ r
        fmtc x = wrap "'[ " " ]'" $ unwords $ intersperse "," x
