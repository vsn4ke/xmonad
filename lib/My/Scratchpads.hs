module My.Scratchpads where

import My.Globals
import XMonad (className, title, (=?))
import qualified XMonad.StackSet as W
import XMonad.Util.NamedScratchpad

myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "mocp" spawnMocp findMocp manageMocp,
    NS "calculator" spawnCalc findCalc manageCalc,
    NS "terminal" spawnTerm findTerm manageTerm
  ]
  where
    spawnMocp = "urxvt -e mocp -T nightly_theme"
    findMocp = className =? "URxvt"
    manageMocp = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnCalc = "speedcrunch"
    findCalc = className =? "SpeedCrunch"
    manageCalc = customFloating $ W.RationalRect l t w h
      where
        h = 0.5
        w = 0.4
        t = 0.75 - h
        l = 0.70 - w
    spawnTerm = "kitty -T scratchTerm"
    findTerm = title =? "scratchTerm"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
