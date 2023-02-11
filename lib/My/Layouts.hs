module My.Layouts where

import My.Globals
import XMonad
import XMonad.Actions.MouseResize
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Grid
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowArranger
import XMonad.Layout.WindowNavigation

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
                            mySpacing 8 Grid

tabs =
    renamed [Replace "tabs"] $
        tabbed shrinkText myTabTheme

myTabTheme =
    def
        { fontName = "Mononoki Nerd Font Regular 16"
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