-- core
import XMonad

-- window stack manipulation and map creation
import Data.Tree
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Maybe (fromJust)

-- system
import System.Exit (exitSuccess)
import System.IO (hPutStrLn)

-- hooks
import XMonad.Hooks.ManageDocks(avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.DynamicLog(dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops

-- layout
import XMonad.Layout.Renamed
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.LayoutModifier(ModifiedLayout)
import XMonad.Layout.TwoPane

-- actions
import XMonad.Actions.CopyWindow(copy, kill1, copyToAll, killAllOtherCopies)
import XMonad.Actions.Submap(submap)
import XMonad.Actions.RotSlaves

-- utils
import XMonad.Util.Run (spawnPipe)

--import XMonad.Util.SpawnOnce
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce

-- keys
import Graphics.X11.ExtraTypes
import Graphics.X11.ExtraTypes.XF86

-- prompts
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Window
import XMonad.Prompt.ConfirmPrompt
import XMonad.Prompt.Shell
import XMonad.Prompt.FuzzyMatch

---------------------------------------------------------------------------------------------------------------
--colors
data ColorSchemes = ColorSchemes{black ,white ,gray ,yellow ,orange ,red ,purple ,blue ,cyan ,green :: String}

myGruvbox :: ColorSchemes
myGruvbox = ColorSchemes {
                              black   = "#262727",
                              white   = "#ddc7a1",
                              gray    = "#c9cbff",
                              yellow  = "#d8a657",
                              orange  = "#e78a4e",
                              red     = "#ea6962",
                              purple  = "#d3869b",
                              blue    = "#7daea3",
                              cyan    = "#8ec07c",
                              green   = "#a9b665"
                         }

myCatppuccin :: ColorSchemes
myCatppuccin = ColorSchemes {
                              black   = "#161320",
                              white   = "#d9e0ee",
                              gray    = "#988ba2",
                              yellow  = "#fae3b0",
                              orange  = "#f8bd96",
                              red     = "#f28fad",
                              purple  = "#ddb6f2",
                              blue    = "#96cdfb",
                              cyan    = "#89dceb",
                              green   = "#abe9b3"
                            }
colorTrayer :: String
colorTrayer = "--tint 0x262727"

---------------------------------------------------------------------------------------------------------------
-- user variables
myModMask              = mod4Mask                                                                :: KeyMask
myFocusFollowsMouse    = True                                                                    :: Bool
myClickJustFocuses     = False                                                                   :: Bool
myBorderWidth          = 4                                                                       :: Dimension
myWindowGap            = 12                                                                      :: Integer
myColor                = myCatppuccin                                                            :: ColorSchemes
myFocusedBorderColor   = white myColor                                                           :: String
myUnFocusedBorderColor = black myColor                                                           :: String
myFont                 = "xft:Ubuntu Mono:regular:pixelsize=15:antialias=true:hinting=true"      :: String
myXPFont    = "xft:Iosevka Nerd Font Mono:regular:pixelsize=15:antialias=true:hinting=true"      :: String      
myTerminal             = "alacritty"                                                             :: String
myFilemanager          = "nemo"                                                                  :: String
myFilemanagerAlt       = "pcmanfm"                                                               :: String
myAppLauncher = "dmenu_run -nb '#1e1e2e' -sf '#c9cbff' -sb '#988ba2' -nf '#c9cbff' -l 10 -bw 3"  :: String
myAppLauncherAlt       = "rofi -dpi 180 -show run"   :: String
myBrowser              = "firefox"                   :: String
myBrowserAlt           = "librewolf"                 :: String
myIDE                  = "alacritty nvim"            :: String

---------------------------------------------------------------------------------------------------------------
--Layouts
mySpacing :: Integer -> l a -> ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border 12 i 12 i) True (Border 12 i 12 i) True

tall =
  renamed [Replace "Tall"] $
    mySpacing myWindowGap $
        ResizableTall 1 (3/100) (1/2) []

wide =
  renamed [Replace "Wide"] $
    mySpacing myWindowGap $
        Mirror (Tall 1 (3 / 100) (1 / 2))

full =
  renamed [Replace "Full"] $
    mySpacing myWindowGap
        Full

tpane =
  renamed [Replace "TwoPane"] $
    mySpacing myWindowGap $
      TwoPane (3 / 100) (1 / 2)

myLayout =
  avoidStruts $ smartBorders myDefaultLayout
  where
    myDefaultLayout = full ||| tall ||| wide ||| tpane

---------------------------------------------------------------------------------------------------------------
-- Prompts
myXPromptConfig :: XPConfig
myXPromptConfig = def
    {
      bgColor = black myColor,
      fgColor = white myColor,
      bgHLight = cyan myColor,
      fgHLight = black myColor,
      position = CenteredAt 0.3 0.5 ,
      font = myXPFont,
      alwaysHighlight = True,
      height = 30,
      historySize = 256,
      maxComplColumns = Just 1,
      maxComplRows = Just 15,
      showCompletionOnTab = False,
      complCaseSensitivity = CaseInSensitive,
      searchPredicate = fuzzyMatch
    }
---------------------------------------------------------------------------------------------------------------
--managehook
myManageHook =
  composeAll
    [ manageDocks
    , className =? "Steam"               -->   doFloat
    , className =? "Pavucontrol"         -->   doFloat
    , className =? "mpv"                 -->   doFloat
    , className =? "pcmanfm"             -->   doFloat
    , className =? "lxqt-archiver"       -->   doFloat
    , className =? "Virt-manager"        -->   doShift   (myWorkspaces !! 4)
    , className =? "Virt-manager"        -->   doFloat
    , className =? "librewolf"           -->   doShift   (myWorkspaces !! 1)
    , className =? "firefox"             -->   doShift   (myWorkspaces !! 1)
    , className =? "Steam"               -->   doShift   (myWorkspaces !! 6)
    , className =? "steam_app_322170"    -->   doShift   (myWorkspaces !! 5)
    , className =? "libreoffice"         -->   doShift   (myWorkspaces !! 3)
    , className =? "libreoffice-writer"  -->   doShift   (myWorkspaces !! 3)
    , className =? "KeePassXC"           -->   doFloat
    , title     =? "Picture-in-Picture"  -->   doFloat
    ]

---------------------------------------------------------------------------------------------------------------
-- eventhook
myEventHook = mempty

---------------------------------------------------------------------------------------------------------------
--dynamicloghook
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myXmobarPP h =
  xmobarPP
    { ppCurrent         = xmobarColor (green myColor) "" . wrap "[" "]",
      ppVisible         = xmobarColor (white myColor) "" . wrap "" "" . clickable,
      ppHidden          = xmobarColor (purple myColor) "" . wrap "" "" . clickable,
      ppHiddenNoWindows = xmobarColor (white myColor) "" . clickable,
      ppSep             = " | ",
      ppTitle           = xmobarColor (white myColor) "" . shorten 60,
      ppLayout          = xmobarColor  (white myColor) "",
      ppOutput          = hPutStrLn h,
      --ppExtras          = [windowCount],
      ppOrder           = \(ws : l : t : ex) -> [ws, l, t]
    }

---------------------------------------------------------------------------------------------------------------
--startuphook
--myStartupHook :: X ()
--myStartupHook = do
    -- Set wallpaper.
    --spawnOnce "feh --bg-fill ~/.wallpapers/bg6.png &"
    -- Spawn the compositor, enable experimental backends
    -- for dual-kawase blur (pretty).
    --spawnOnce "picom --experimental-backends --backend glx &"
    -- Spawn flameshot as a daemon
    -- required for copying to clipboard, I guess...
    --spawnOnce "flameshot &"
    -- Spawn fcitx5, mostly for Mozc.
    --spawnOnce "fcitx5 &"
    -- Set background cursor
    -- There should be a better way, without a hard-coded path...
    --spawnOnce "xsetroot -xcf /nix/store/mk7ncjbnk9sngxps1nh6fk6c3jjfkzpx-phinger-cursors-1.1/share/icons/phinger-cursors/cursors/left_ptr 48 &"

    --spawn "killall trayer"  -- kill current trayer on each restart
    --spawn ("sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 " ++ colorTrayer ++ " --height 48")

---------------------------------------------------------------------------------------------------------------
-- keybindings and keychords
myKeys conf@XConfig {XMonad.modMask = modm} =
  M.fromList $
    [
      -- spawn applications
      ((modm, xK_t),                     spawn $ XMonad.terminal conf),
      ((modm, xK_f),                     spawn myFilemanager),
      ((modm .|. shiftMask, xK_f),       spawn myFilemanagerAlt),
      ((modm, xK_b),                     spawn myBrowser),
      ((modm, xK_e),                     spawn myIDE),

      -- prompts
      --((modm, xK_space),                  shellPrompt myXPromptConfig),
      --((modm, xK_Tab),                    windowPrompt myXPromptConfig Goto allWindows),
      --((modm .|. shiftMask, xK_space),    windowPrompt myXPromptConfig Bring allWindows),
      --((modm .|. controlMask, xK_Tab),    windowPrompt myXPromptConfig Goto wsWindows),
      ((modm, xK_space),                 spawn myAppLauncher),


      -- kill compile exit lock
      ((modm, xK_q),                     kill1),
      ((modm .|. shiftMask, xK_q),       kill),
      ((modm, xK_c),                     spawn "xmonad --recompile; xmonad --restart"),
      ((modm .|. shiftMask, xK_c),       confirmPrompt myXPromptConfig "Log out of Xmonad " (io exitSuccess)),

      -- layout change focus
      ((modm, xK_j),                     windows W.focusDown),
      ((modm, xK_k),                     windows W.focusUp),

      -- shift windows
      ((modm .|. shiftMask, xK_j),       windows W.swapDown),
      ((modm .|. shiftMask, xK_k),       windows W.swapUp),
      ((modm, xK_Return),                windows W.swapMaster),

      -- change layout
      ((modm, xK_n),                     sendMessage NextLayout),
      ((modm .|. shiftMask, xK_n),       setLayout $ XMonad.layoutHook conf),

      -- resize windows and float
      ((modm .|. controlMask, xK_j),     sendMessage MirrorShrink),
      ((modm .|. controlMask, xK_k),     sendMessage MirrorExpand),
      ((modm .|. controlMask, xK_h),     sendMessage Shrink),
      ((modm .|. controlMask, xK_l),     sendMessage Expand),
      ((modm .|. controlMask, xK_t),     withFocused $ windows . W.sink),

      -- copy window to all workspace
      ((modm, xK_0),                     windows copyToAll),
      ((modm .|. shiftMask, xK_0),       killAllOtherCopies),

      -- Rotate slave windows, keep master window the same
      -- and keep focus intact
      ((modm, xK_Tab),                  rotSlavesUp),
      ((modm .|. shiftMask, xK_Tab),    rotSlavesDown),

      -- gaps and struts and fullscreen
      --((modm, xK_equal),                  sequence_ [incWindowSpacing 2, incScreenSpacing 2]),
      --((modm, xK_minus),                  sequence_ [decWindowSpacing 2, decScreenSpacing 2]),
      ((modm, xK_plus),                     sequence_ [incWindowSpacing 2, incScreenSpacing 2]),
      ((modm, xK_minus),                    sequence_ [decWindowSpacing 2, decScreenSpacing 2]),
      ((modm .|. controlMask, xK_Return),   sequence_ [setWindowSpacing (Border 0 myWindowGap 0 myWindowGap), setScreenSpacing (Border 0 myWindowGap 0 myWindowGap)]),
      ((modm .|. controlMask, xK_f),        sequence_ [sendMessage ToggleStruts, toggleScreenSpacingEnabled, toggleWindowSpacingEnabled]),

      -- screenshots
      ((modm, xK_Print),                 spawn "flameshot screen -p ~/Pictures/screenshots/"),
      ((modm .|. shiftMask, xK_Print),   spawn "flameshot full -p ~/Pictures/screenshots/"),
      ((modm .|. controlMask, xK_Print), spawn "flameshot gui"),

      ((modm, xK_p),                     spawn "flameshot screen -p ~/Pictures/screenshots/"),
      ((modm .|. shiftMask, xK_p),       spawn "flameshot full -p ~/Pictures/screenshots/"),
      ((modm .|. controlMask, xK_p),     spawn "flameshot gui"),

      --volume and mic
      ((0, xF86XK_AudioMute),            spawn "amixer sset Master 'toggle'"),
      ((0, xF86XK_AudioMicMute),         spawn "amixer sset Capture 'toggle'"),
      ((0, xF86XK_AudioRaiseVolume),     spawn "amixer sset Master 2%+"),
      ((0, xF86XK_AudioLowerVolume),     spawn "amixer sset Master 2%-"),
      ((modm, xK_Up),                    spawn "amixer sset Master 2%+"),
      ((modm, xK_Down),                  spawn "amixer sset Master 2%-"),

      --screen brightness
      ((0, xF86XK_MonBrightnessUp),      spawn "brightnessctl s +5%"),
      ((0, xF86XK_MonBrightnessDown),    spawn "brightnessctl s 5%-"),

      --screen locking
      ((modm .|. shiftMask, xK_z),       spawn "betterlockscreen --lock blur")
    ]
      ++
      --change workspace
      [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      --move windows to workspaces
      [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip myWorkspaces [xK_1 ..],
          (f, m) <- [(W.view, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]
      ]

---------------------------------------------------------------------------------------------------------------
--mousebinding
myMouseBindings XConfig {XMonad.modMask = modm} =
  M.fromList
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster), -- mod-button1, Set the window to floating mode and move by dragging
      ((modm, button2), \w -> focus w >> windows W.shiftMaster), -- mod-button2, Raise the window to the top of the stack
      ((modm, button3), \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster) -- mod-button3, Set the window to floating mode and resize by dragging
    ]

--Workspaces
myWorkspaces = ["msg", "www", "ide", "doc", "vrt", "snd", "stm", "uwu", "msc"]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..]
clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices

---------------------------------------------------------------------------------------------------------------
--Main
main :: IO ()
main = do
  myXmobar <- spawnPipe "xmobar -x 0 /etc/nixos/modules/users/graphical/xmonad/xmobarrc"
  xmonad $ docks $ ewmh def
        { terminal           = myTerminal,
          focusFollowsMouse  = myFocusFollowsMouse,
          clickJustFocuses   = myClickJustFocuses,
          borderWidth        = myBorderWidth,
          modMask            = myModMask,
          workspaces         = myWorkspaces,
          focusedBorderColor = myFocusedBorderColor,
          normalBorderColor  = myUnFocusedBorderColor,
          keys               = myKeys,
          layoutHook         = myLayout,
          manageHook         = myManageHook,
          handleEventHook    = myEventHook,
          logHook            = dynamicLogWithPP $ myXmobarPP myXmobar,
          --startupHook        = myStartupHook
        }
