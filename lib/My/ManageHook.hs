module My.ManageHook where

import My.Globals

import Data.Ratio
import My.Scratchpads
import XMonad
import XMonad.Hooks.ManageHelpers
import XMonad.StackSet qualified as W
import XMonad.Util.NamedScratchpad

myManageHook =
    composeAll
        [ className =? "Thunar" --> doRectFloat (W.RationalRect (1 % 8) (1 % 8) (3 % 4) (3 % 4))
        , className =? "confirm" --> doFloat
        , className =? "file_progress" --> doFloat
        , className =? "dialog" --> doFloat
        , className =? "error" --> doFloat
        , className =? "notification" --> doFloat
        , className =? "Xmessage" --> doFloat
        , title =? "Mozilla Firefox" --> doShift (myWorkspaces !! 1)
        , className =? "Brave-browser" --> doShift (myWorkspaces !! 2)
        , className =? "VSCodium" --> doShift (head myWorkspaces)
        , className =? "discord" --> doShift (myWorkspaces !! 3)
        , (className =? "Codium" <&&> resource =? "codium") --> doRectFloat (W.RationalRect (1 % 4) (1 % 4) (1 % 2) (1 % 2))
        ]
        <+> namedScratchpadManageHook myScratchPads