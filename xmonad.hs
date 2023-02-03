import XMonad
import XMonad.Config.Azerty
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.WindowSwallowing

import XMonad.Layout.LayoutHints
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig (mkNamedKeymap)
import XMonad.Util.Hacks qualified as H
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce

import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D (..), WSType (..), moveTo, nextScreen, prevScreen, shiftTo)
import XMonad.Actions.MouseResize

import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid (Grid))
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (decreaseLimit, increaseLimit, limitWindows)
import XMonad.Layout.MultiToggle (EOT (EOT), mkToggle, single, (??))
import XMonad.Layout.MultiToggle qualified as MT (Toggle (..))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.ToggleLayouts qualified as T (ToggleLayout (Toggle), toggleLayouts)
import XMonad.Layout.WindowArranger (WindowArrangerMsg (..), windowArrange)
import XMonad.Layout.WindowNavigation

import Data.Map qualified as M
import Data.Maybe (isJust)
import Data.Monoid
import Data.Ratio
import System.Exit
import System.IO
import XMonad.Hooks.StatusBar
import XMonad.StackSet qualified as W

xmonadCfgPath = "/home/vsn4ke/.config/xmonad"
xmobarCfgPath = xmonadCfgPath ++ "/xmobar/xmobarrc"

main = do
  xmproc0 <- spawnPipe ("xmobar -x 0 " ++ xmobarCfgPath ++ "0")
  xmonad $
    addDescrKeys ((mod4Mask, xK_F1), xMessage) myKeys . ewmh . docks $
      azertyConfig
        { terminal = myTerminal
        , modMask = mod4Mask
        , borderWidth = 2
        , workspaces = myWorkspaces
        , normalBorderColor = colorBack
        , focusedBorderColor = "#bbc2cf"
        , mouseBindings = myMouseBindings
        , manageHook = myManageHook <+> manageDocks
        , handleEventHook = H.windowedFullscreenFixEventHook <> swallowEventHook (className =? "Kitty" <||> className =? "XTerm") (return True)
        , layoutHook = myLayoutHook
        , logHook =
            dynamicLogWithPP $
              def
                { ppOutput = hPutStrLn xmproc0
                , ppCurrent = xmobarColor "#da8548" "" . wrap "[" "]"
                , ppHiddenNoWindows = xmobarColor color01 ""
                , ppVisible = xmobarColor "#ecbe7b" ""
                , ppHidden = xmobarColor color01 "" . wrap "(" ")"
                , ppTitle = xmobarColor color02 "" . shorten 60
                , ppUrgent = xmobarColor "#ff6c6b" "" . wrap "!" "!"
                }
        , startupHook = myStartupHook
        }

myTerminal = "kitty"
myWorkspaces = [" dev ", " www ", " video ", " discord "]

colorBack = "#282c34"
color01 = "#46d9ff"
color02 = "#dfdfdf"

myKeys :: XConfig l0 -> [((KeyMask, KeySym), NamedAction)]
myKeys c =
  let subKeys str ks = subtitle str : mkNamedKeymap c ks
   in subKeys
        "Xmonad Essentials"
        [ ("M-q", addName "Restart XMonad" $ spawn "xmonad --recompile; killall xmobar; xmonad --restart")
        , ("M-S-q", addName "Logout" $ spawn (xmonadCfgPath ++ "/script/dm_logout"))
        , ("M-S-c", addName "Kill focused window" kill1)
        , ("M-t l", addName "view trash" $ spawn "thunar ~/.local/share/Trash")
        , ("M-t c", addName "clear trash" $ spawn (myTerminal ++ " rm -rf ~/.local/share/Trash/*"))
        , ("M-p", addName "DMenu" $ spawn "dmenu_run")
        ]
        ^++^ subKeys
          "Workspace"
          [ ("M-&", addName "Switch to workspace 1" $ windows (W.greedyView $ head myWorkspaces))
          , ("M-é", addName "Switch to workspace 2" $ windows (W.greedyView $ myWorkspaces !! 1))
          , ("M-\"", addName "Switch to workspace 3" $ windows (W.greedyView $ myWorkspaces !! 2))
          , ("M-'", addName "Switch to workspace 4" $ windows (W.greedyView $ myWorkspaces !! 3))
          , ("M-S-&", addName "Send to workspace 1" $ windows (W.shift $ head myWorkspaces))
          , ("M-S-é", addName "Send to workspace 2" $ windows (W.shift $ myWorkspaces !! 1))
          , ("M-S-\"", addName "Send to workspace 3" $ windows (W.shift $ myWorkspaces !! 2))
          , ("M-S-'", addName "Send to workspace 4" $ windows (W.shift $ myWorkspaces !! 3))
          ]
        ^++^ subKeys
          "Favorite programs"
          [ ("M-<Return>", addName "Launch terminal" $ spawn myTerminal)
          , ("M-w", addName "Launch terminal" $ spawn myTerminal)
          , ("M-b", addName "Launch web browser" $ spawn "firefox")
          , ("M-c c", addName "Launch codium" $ spawn "codium")
          , ("M-c d", addName "Launch discord" $ spawn "Discord")
          , ("M-c t", addName "Launch thunar" $ spawn "thunar")
          , ("M-c h", addName "Launch htop" $ spawn (myTerminal ++ " -e htop"))
          ]
        ^++^ subKeys
          "Mocp music player"
          [ ("M-x p", addName "mocp play" $ spawn "mocp --play")
          , ("M-x l", addName "mocp next" $ spawn "mocp --next")
          , ("M-x h", addName "mocp prev" $ spawn "mocp --previous")
          , ("M-x <KP_Add>", addName "mocp vol up" $ spawn "mocp --volume +5")
          , ("M-x <KP_Subtract>", addName "mocp vol down" $ spawn "mocp --volume -5")
          , ("M-x v", addName "mocp vol 5" $ spawn "mocp --volume 5")
          , ("M-x <Space>", addName "mocp toggle pause" $ spawn "mocp --toggle-pause")
          ]
        ^++^ subKeys
          "Scratchpads"
          [ ("M-s t", addName "Toggle scratchpad terminal" $ namedScratchpadAction myScratchPads "terminal")
          , ("M-s m", addName "Toggle scratchpad mocp" $ namedScratchpadAction myScratchPads "mocp")
          , ("M-s c", addName "Toggle scratchpad calculator" $ namedScratchpadAction myScratchPads "calculator")
          ]
 where
  nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
  nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

myMouseBindings (XConfig{XMonad.modMask = modMask}) =
  M.fromList
    [
      ( (modMask, button1)
      , \w ->
          focus w
            >> mouseMoveWindow w
            >> windows W.shiftMaster
      )
    , ((modMask, button2), \w -> focus w >> kill1 >> windows W.shiftMaster)
    ,
      ( (modMask, button3)
      , \w ->
          focus w
            >> mouseResizeWindow w
            >> windows W.shiftMaster
      )
    ]

myStartupHook :: X ()
myStartupHook = do
  spawn "killall conky"
  spawn "killall trayer"
  spawnOnce "picom --backend glx --vsync"
  spawnOnce "nm-applet"
  spawnOnce "pasystray"
  spawnOnce "xmodmap -e \"pointer = 1 2 3\""
  spawn ("xmobar -x 1 " ++ xmobarCfgPath ++ "1")
  spawn ("conky -c " ++ xmonadCfgPath ++ "01.conkyrc")
  spawn "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34 --height 22"
  spawnOnce "feh --randomize --bg-fill ~/Images/wallpaper/*"

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

myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "terminal" spawnTerm findTerm manageTerm
  , NS "mocp" spawnMocp findMocp manageMocp
  , NS "calculator" spawnCalc findCalc manageCalc
  ]
 where
  spawnTerm = myTerminal ++ " -T scratchpad"
  findTerm = title =? "scratchpad"
  manageTerm = customFloating $ W.RationalRect l t w h
   where
    h = 0.9
    w = 0.9
    t = 0.95 - h
    l = 0.95 - w
  spawnMocp = myTerminal ++ " -T mocp -e mocp -T nightly_theme"
  findMocp = title =? "mocp"
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

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

tall =
  renamed [Replace "tall"] $
    limitWindows 5 $
      smartBorders $
        windowNavigation $
          addTabs shrinkText myTabTheme $
            subLayout [] (smartBorders Simplest) $
              mySpacing 8 $
                ResizableTall 1 (3 / 100) (1 / 2) []
monocle =
  renamed [Replace "monocle"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout
            []
            (smartBorders Simplest)
            Full
grid =
  renamed [Replace "grid"] $
    limitWindows 9 $
      smartBorders $
        windowNavigation $
          addTabs shrinkText myTabTheme $
            subLayout [] (smartBorders Simplest) $
              mySpacing 8 $
                mkToggle (single MIRROR) $
                  Grid (16 / 10)
tabs =
  renamed [Replace "tabs"] $
    tabbed shrinkText myTabTheme

myTabTheme =
  def
    { fontName = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"
    , activeColor = color01
    , inactiveColor = "#202328"
    , activeBorderColor = color01
    , inactiveBorderColor = colorBack
    , activeTextColor = colorBack
    , inactiveTextColor = color02
    }

myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
 where
  myDefaultLayout =
    withBorder 2 tall
      ||| noBorders monocle
      ||| noBorders tabs
      ||| grid