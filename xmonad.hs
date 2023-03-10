import My.Globals
import My.Keys
import My.Layouts
import My.ManageHook
import My.Scratchpads
import My.StartupHook
import My.Xmobar (spawnBar)
import XMonad
import XMonad.Config.Azerty
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.WindowSwallowing
import XMonad.Layout.MagicFocus
import XMonad.Util.Hacks
import XMonad.Util.NamedActions
import XMonad.Util.Run

main = do
  xmproc0 <- spawnBar 0
  xmproc1 <- spawnBar 1
  xmonad $
    addDescrKeys ((mod4Mask, xK_F1), xMessage) myKeys . ewmh . docks $
      azertyConfig
        { terminal = myTerminal,
          modMask = mod4Mask,
          borderWidth = 2,
          workspaces = myWorkspaces,
          normalBorderColor = colorBack,
          focusedBorderColor = "#bbc2cf",
          mouseBindings = myMouseBindings,
          manageHook = myManageHook <+> manageDocks,
          handleEventHook =
            windowedFullscreenFixEventHook
              <> swallowEventHook (className =? "Kitty" <||> className =? "XTerm") (return True),
          layoutHook = myLayoutHook,
          logHook =
            dynamicLogWithPP $
              def
                { ppOutput = hPutStrLn xmproc0,
                  ppCurrent = xmobarColor "#da8548" "" . wrap "[" "]",
                  ppHiddenNoWindows = xmobarColor color01 "",
                  ppVisible = xmobarColor "#ecbe7b" "",
                  ppHidden = xmobarColor color01 "" . wrap "(" ")",
                  ppTitle = xmobarColor color02 "" . shorten 60,
                  ppUrgent = xmobarColor "#ff6c6b" "" . wrap "!" "!"
                },
          startupHook = myStartupHook
        }
