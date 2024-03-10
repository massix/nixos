{ pkgs, unstable, lib, config, ... }:
let
  cfg = config.my-modules.zellij;
  inherit (lib) mkEnableOption mkOption types mkIf;
  boolToStr = bool: if bool then "true" else "false";
in
{
  options.my-modules.zellij = {
    enable = mkEnableOption "Activate Zellij module";

    configuration = {
      unstable = mkEnableOption "Use unstable channel";
      enableFishIntegration = mkEnableOption "Fish integration";
      enableZshIntegration = mkEnableOption "Zsh integration";
      enableBashIntegration = mkEnableOption "Bash integration";
      autoAttach = mkEnableOption "Auto-attach to a session";
      autoExit = mkEnableOption "Auto-exit on exit";
      theme = mkOption {
        type = types.str;
        default = "catppuccin-mocha";
        description = "Theme to use for Zellij";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      package = if cfg.configuration.unstable then unstable.zellij else pkgs.zellij;
      inherit (cfg.configuration) enableFishIntegration enableZshIntegration enableBashIntegration;
    };

    home.sessionVariables = {
      ZELLIJ_AUTO_ATTACH = boolToStr cfg.configuration.autoAttach;
      ZELLIJ_AUTO_EXIT = boolToStr cfg.configuration.autoExit;
    };

    home.file =
      let configDir = ".config/zellij";
      in
      {
        "${configDir}/config.kdl".text = ''

          // Zellij Configuration
          keybinds clear-defaults=true {
            normal {
            }

            locked {
              bind "Ctrl g" { SwitchToMode "Normal"; }
            }
            resize {
              bind "Ctrl n" { SwitchToMode "Normal"; }
              bind "h" "Left" { Resize "Increase Left"; }
              bind "j" "Down" { Resize "Increase Down"; }
              bind "k" "Up" { Resize "Increase Up"; }
              bind "l" "Right" { Resize "Increase Right"; }
              bind "H" { Resize "Decrease Left"; }
              bind "J" { Resize "Decrease Down"; }
              bind "K" { Resize "Decrease Up"; }
              bind "L" { Resize "Decrease Right"; }
              bind "=" "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
            }
            pane {
              bind "Ctrl p" { SwitchToMode "Normal"; }
              bind "h" "Left" { MoveFocus "Left"; }
              bind "l" "Right" { MoveFocus "Right"; }
              bind "j" "Down" { MoveFocus "Down"; }
              bind "k" "Up" { MoveFocus "Up"; }
              bind "p" { SwitchFocus; }
              bind "n" { NewPane; SwitchToMode "Normal"; }
              bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "x" { CloseFocus; SwitchToMode "Normal"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
              bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
              bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
              bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
              bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0;}
            }
            move {
              bind "Ctrl v" { SwitchToMode "Normal"; }
              bind "n" "Tab" { MovePane; }
              bind "p" { MovePaneBackwards; }
              bind "h" "Left" { MovePane "Left"; }
              bind "j" "Down" { MovePane "Down"; }
              bind "k" "Up" { MovePane "Up"; }
              bind "l" "Right" { MovePane "Right"; }
            }
            tab {
              bind "Ctrl t" { SwitchToMode "Normal"; }
              bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
              bind "h" "Left" "Up" "k" { GoToPreviousTab; }
              bind "l" "Right" "Down" "j" { GoToNextTab; }
              bind "n" { NewTab; SwitchToMode "Normal"; }
              bind "x" { CloseTab; SwitchToMode "Normal"; }
              bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
              bind "b" { BreakPane; SwitchToMode "Normal"; }
              bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
              bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
              bind "1" { GoToTab 1; SwitchToMode "Normal"; }
              bind "2" { GoToTab 2; SwitchToMode "Normal"; }
              bind "3" { GoToTab 3; SwitchToMode "Normal"; }
              bind "4" { GoToTab 4; SwitchToMode "Normal"; }
              bind "5" { GoToTab 5; SwitchToMode "Normal"; }
              bind "6" { GoToTab 6; SwitchToMode "Normal"; }
              bind "7" { GoToTab 7; SwitchToMode "Normal"; }
              bind "8" { GoToTab 8; SwitchToMode "Normal"; }
              bind "9" { GoToTab 9; SwitchToMode "Normal"; }
              bind "Tab" { ToggleTab; }
            }
            scroll {
              bind "Ctrl s" { SwitchToMode "Normal"; }
              bind "e" { EditScrollback; SwitchToMode "Normal"; }
              bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
              bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
            }
            search {
              bind "Ctrl s" { SwitchToMode "Normal"; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
              bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "n" { Search "down"; }
              bind "p" { Search "up"; }
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "w" { SearchToggleOption "Wrap"; }
              bind "o" { SearchToggleOption "WholeWord"; }
            }
            entersearch {
              bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
              bind "Enter" { SwitchToMode "Search"; }
            }
            renametab {
              bind "Ctrl c" { SwitchToMode "Normal"; }
              bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
            }
            renamepane {
              bind "Ctrl c" { SwitchToMode "Normal"; }
              bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
            }
            session {
              bind "Ctrl o" { SwitchToMode "Normal"; }
              bind "Ctrl s" { SwitchToMode "Scroll"; }
              bind "d" { Detach; }
              bind "w" {
                  LaunchOrFocusPlugin "zellij:session-manager" {
                      floating true
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal"
              }
            }
            shared_except "locked" {
              bind "Ctrl g" { SwitchToMode "Locked"; }
              bind "Ctrl q" { Quit; }
              bind "Alt n" { NewPane; }
              bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
              bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
              bind "Alt j" "Alt Down" { MoveFocus "Down"; }
              bind "Alt k" "Alt Up" { MoveFocus "Up"; }
              bind "Alt =" "Alt +" { Resize "Increase"; }
              bind "Alt -" { Resize "Decrease"; }
              bind "Alt [" { PreviousSwapLayout; }
              bind "Alt ]" { NextSwapLayout; }
            }
            shared_except "normal" "locked" {
              bind "Enter" "Esc" { SwitchToMode "Normal"; }
            }
            shared_except "pane" "locked" {
              bind "Ctrl p" { SwitchToMode "Pane"; }
            }
            shared_except "resize" "locked" {
              bind "Ctrl n" { SwitchToMode "Resize"; }
            }
            shared_except "scroll" "locked" {
              bind "Ctrl s" { SwitchToMode "Scroll"; }
            }
            shared_except "session" "locked" {
              bind "Ctrl o" { SwitchToMode "Session"; }
            }
            shared_except "tab" "locked" {
              bind "Ctrl t" { SwitchToMode "Tab"; }
            }
            shared_except "move" "locked" {
              bind "Ctrl v" { SwitchToMode "Move"; }
            }
          }

          plugins {
            tab-bar { path "tab-bar"; }
            status-bar { path "status-bar"; }
            strider { path "strider"; }
            compact-bar { path "compact-bar"; }
            session-manager { path "session-manager"; }
          }

          // Choose the theme that is specified in the themes section.
          // Default: default
          theme "${cfg.configuration.theme}"

          scroll_buffer_size 50000

          // Provide a command to execute when copying text. The text will be piped to
          // the stdin of the program to perform the copy. This can be used with
          // terminal emulators which do not support the OSC 52 ANSI control sequence
          // that will be used by default if this option is not set.
          // Examples:
          //
          // copy_command "xclip -selection clipboard" // x11
          // copy_command "wl-copy"                    // wayland
          // copy_command "pbcopy"                     // osx

          // Choose the destination for copied text
          // Allows using the primary selection buffer (on x11/wayland) instead of the system clipboard.
          // Does not apply when using copy_command.
          // Options:
          //   - system (default)
          //   - primary
          //
          // copy_clipboard "primary"

          // Enable or disable automatic copy (and clear) of selection when releasing mouse
          // Default: true
          //
          // copy_on_select false

          // mirror_session true
        '';
      };

  };
}
