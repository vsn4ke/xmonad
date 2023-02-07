module My.Keys where

import Data.Map (fromList)
import Data.Maybe (isJust)
import My.Globals
import My.Scratchpads
import XMonad
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (WSType (WSIs))
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (mkNamedKeymap)
import XMonad.Util.NamedActions (NamedAction, addName, subtitle, (^++^))
import XMonad.Util.NamedScratchpad (namedScratchpadAction)

myKeys :: XConfig l0 -> [((KeyMask, KeySym), NamedAction)]
myKeys c =
  let subKeys str ks = subtitle str : mkNamedKeymap c ks
   in subKeys
        "Xmonad Essentials"
        [ ("M-<F4>", addName "Restart XMonad" $ spawn "xmonad --recompile; killall xmobar; xmonad --restart"),
          ("M-S-q", addName "Logout" $ spawn (scriptPath ++ "/dm_logout")),
          ("M-q", addName "Kill focused window" kill1),
          ("M-t l", addName "view trash" $ spawn "thunar ~/.local/share/Trash"),
          ("M-t c", addName "clear trash" $ spawn (myTerminal ++ " rm -rf ~/.local/share/Trash/*")),
          ("M-p p", addName "DMenu" $ spawn "dmenu_run"),
          ("M-p m", addName "dm_man" $ spawn (scriptPath ++ "/dm_man"))
        ]
        ^++^ subKeys
          "Workspace"
          [ ("M-&", addName "Switch to workspace 1" $ windows (W.greedyView $ head myWorkspaces)),
            ("M-é", addName "Switch to workspace 2" $ windows (W.greedyView $ myWorkspaces !! 1)),
            ("M-\"", addName "Switch to workspace 3" $ windows (W.greedyView $ myWorkspaces !! 2)),
            ("M-'", addName "Switch to workspace 4" $ windows (W.greedyView $ myWorkspaces !! 3)),
            ("M-S-&", addName "Send to workspace 1" $ windows (W.shift $ head myWorkspaces)),
            ("M-S-é", addName "Send to workspace 2" $ windows (W.shift $ myWorkspaces !! 1)),
            ("M-S-\"", addName "Send to workspace 3" $ windows (W.shift $ myWorkspaces !! 2)),
            ("M-S-'", addName "Send to workspace 4" $ windows (W.shift $ myWorkspaces !! 3))
          ]
        ^++^ subKeys
          "Favorite programs"
          [ ("M-<Return>", addName "Launch terminal" $ spawn myTerminal),
            ("M-b", addName "Launch web browser" $ spawn "firefox"),
            ("M-c c", addName "Launch codium" $ spawn "codium"),
            ("M-c d", addName "Launch discord" $ spawn "Discord"),
            ("M-c t", addName "Launch thunar" $ spawn "thunar"),
            ("M-c h", addName "Launch htop" $ spawn (myTerminal ++ " -e htop"))
          ]
        ^++^ subKeys
          "Mocp music player"
          [ ("M-x p", addName "mocp play" $ spawn "mocp --play"),
            ("M-x l", addName "mocp next" $ spawn "mocp --next"),
            ("M-x h", addName "mocp prev" $ spawn "mocp --previous"),
            ("M-x <KP_Add>", addName "mocp vol up" $ spawn "mocp --volume +5"),
            ("M-x <KP_Subtract>", addName "mocp vol down" $ spawn "mocp --volume -5"),
            ("M-x v", addName "mocp vol 5" $ spawn "mocp --volume 5"),
            ("M-x <Space>", addName "mocp toggle pause" $ spawn "mocp --toggle-pause")
          ]
        ^++^ subKeys
          "Scratchpads"
          [ ("M-s m", addName "Toggle scratchpad mocp" $ namedScratchpadAction myScratchPads "mocp"),
            ("M-s c", addName "Toggle scratchpad calculator" $ namedScratchpadAction myScratchPads "calculator"),
            ("M-w", addName "Toggle scratchpad terminal" $ namedScratchpadAction myScratchPads "terminal")
          ]
  where
    nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
    nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

myMouseBindings (XConfig {XMonad.modMask = modMask}) =
  fromList
    [ ( (modMask, button1),
        \w ->
          focus w
            >> mouseMoveWindow w
            >> windows W.shiftMaster
      ),
      ((modMask, button2), \w -> focus w >> windows W.shiftMaster),
      ( (modMask, button3),
        \w ->
          focus w
            >> mouseResizeWindow w
            >> windows W.shiftMaster
      )
    ]
