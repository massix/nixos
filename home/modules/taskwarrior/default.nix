{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf splitString;
  inherit (pkgs) stdenv;
  cfg = config.my-modules.taskwarrior;
  orEmpty = bool: val: if bool then val else [ ];
  hooksHome = "${config.xdg.dataHome}/task/hooks";
  frenchHolidaysPackage = stdenv.mkDerivation {
    pname = "french-holidays-json";
    version = "2025";
    src = builtins.fetchurl {
      url = "https://holidata.net/fr-FR/2025.json";
      sha256 = "sha256:1lv2sk37inpvjg3snxz83a970xg601rh3vh2xishwwqc8il3aq05";
    };

    nativeBuildInputs = with pkgs; [ jq ];

    sourceRoot = ".";

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out
      cp -r $src $out/french-holidays.json
      cat $out/french-holidays.json | jq -r '.date |= gsub("-"; "") | "holiday.\(.date[4:6])\(.date[6:8]).date=\(.date)\nholiday.\(.date[4:6])-\(.date[6:8]).name=\(.description)"' > $out/french-holidays.rc
    '';
  };
in
{
  options.my-modules.taskwarrior = {
    enable = mkEnableOption "taskwarrior";
    withJira = mkEnableOption "Jira integration";
    withFish = mkEnableOption "fish configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tasksh
      taskwarrior-tui
    ] ++ (orEmpty cfg.withJira [
      bash
      jq
    ]);

    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
      colorTheme = "dark-256";
      extraConfig = ''
        include ${frenchHolidaysPackage}/french-holidays.rc
      '';
      config = {
        # I do not want *all* tagged tasks to look different
        color.tagged = "";
        confirmation = true;
        weekstart = "monday";
        calendar.details = "sparse";
        calendar.holidays = "full";
        news.version = "3.4.1";

        journal.time = true;
        journal.info = true;

        summary.all.projects = true;

        report =
          let
            split = splitString ":";
            mkReport = description: filter: attrs:
              let
                splitted = builtins.map split (builtins.filter (s: s != "") attrs);
              in
              {
                inherit filter description;
                columns = builtins.map (x: builtins.elemAt x 0) splitted;
                labels = builtins.map (x: builtins.elemAt x 1) splitted;
              };
          in
          {
            next = mkReport "Next tasks" "status:pending -WAITING limit:page delegated:" [
              "id:ID"
              "start.age:Active"
              "depends:Deps"
              "priority:P"
              "project:Project"
              "tags:Tag"
              "recur:Recur"
              (if cfg.withJira then "jira:Jira" else "")
              (if cfg.withJira then "sprint:Sprint" else "")
              "scheduled.countdown:S"
              "due.relative:Due"
              "until.remaining:Until"
              "size:TSZ"
              "description:Description"
              "urgency:Urg"
            ];

            delegated = mkReport "Delegated tasks" "delegated.not:" [
              "id:ID"
              "status.short:S"
              "project:Project"
              (if cfg.withJira then "jira:Jira" else "")
              (if cfg.withJira then "sprint:Sprint" else "")
              "delegated:Delegated to"
              "description:Description"
            ];

            ready = mkReport "Ready to be worked on" "status:pending -WAITING limit:page" [
              "id:ID"
              "start.age:Active"
              "depends:Deps"
              "priority:P"
              "project:Project"
              "tags:Tag"
              "recur:Recur"
              (if cfg.withJira then "jira:Jira" else "")
              (if cfg.withJira then "sprint:Sprint" else "")
              "scheduled.countdown:S"
              "due.relative:Due"
              "until.remaining:Until"
              "size:TSZ"
              "description:Description"
              "urgency:Urg"
            ];

            completed = (mkReport "Completed tasks" "status:completed -WAITING" [
              "uuid.short:UUID"
              "end.age:Completed"
              "depends.count:Dep"
              "tags:Tags"
              "priority:P"
              "size:TSZ"
              "project:Project"
              (if cfg.withJira then "jira:Jira" else "")
              (if cfg.withJira then "sprint:Sprint" else "")
              "description.desc:Description"
            ]) // { sort = "project+,end+"; };

            waiting = (mkReport "Waiting tasks" "status:waiting" [
              "id:ID"
              "depends.indicator:D"
              "priority:P"
              "project:Project"
              "recur.indicator:R"
              "delegated.indicator:@"
              "wait:Wait"
              "wait.remaining:Remaining"
              (if cfg.withJira then "jira:Jira" else "")
              (if cfg.withJira then "sprint:Sprint" else "")
              "scheduled:Sched"
              "due:Due"
              "until:Until"
              "description:Description"
              "urgency:Urg"
            ]) // { sort = "due+,wait+,urgency-"; };
          };

        # User-defined attributes
        uda = {
          jira = mkIf cfg.withJira {
            type = "string";
            label = "Jira";
            indicator = "J";
          };

          sprint = mkIf cfg.withJira {
            type = "string";
            label = "Sprint";
            values = [ "past" "current" "future" ];
            default = "current";
          };

          delegated = {
            type = "string";
            label = "Delegated to";
            default = "";
            indicator = "@";
          };

          priority = {
            type = "string";
            label = "Priority";
            values = [ "X" "H" "M" "L" ];
            default = "M";
          };

          size = {
            type = "string";
            label = "T-Shirt Size";
            values = [ "XS" "S" "M" "L" "XL" "XXL" "" ];
            default = "";
          };
        };

        urgency.uda = {
          sprint = {
            past.coefficient = 8.0;
            current.coefficient = 1.3;
            future.coefficient = -1.0;
          };

          priority = {
            X.coefficient = 10.0;
            H.coefficient = 6.0;
            M.coefficient = 3.9;
            L.coefficient = 1.3;
          };

          size = {
            XS.coefficient = 2.5;
            S.coefficient = 2.0;
            M.coefficient = 1.2;
            L.coefficient = -0.3;
            XL.coefficient = -0.6;
            XXL.coefficient = -1.0;
            "".coefficient = 1.0;
          };
        };

        # Color some common tags
        color.tag = {
          bug = "bold red on rgb000";
          meeting = "bold yellow on rgb000";
        };
      };
    };

    # Make sure we do not activate this
    services.taskwarrior-sync.enable = false;

    my-modules.fish.configuration.extraShellAbbrs = mkIf cfg.withFish {
      tt = "task";
      tn = "task next";
      ta = "task add";
      trm = "task rm";
      tm = "task modify";
      ts = "task sprint:current next";
    };

    programs.fish.interactiveShellInit = mkIf cfg.withFish ''
      ${lib.getExe pkgs.taskwarrior3} next
    '';

    home.file = {
      "${hooksHome}/on-add.add-jira-information.sh" = mkIf cfg.withJira {
        source = ./scripts/on-add.add-jira-information.sh;
        executable = true;
      };

      "${hooksHome}/on-modify.add-jira-information.sh" = mkIf cfg.withJira {
        source = ./scripts/on-modify.add-jira-information.sh;
        executable = true;
      };

      "${hooksHome}/on-add.delegate-someday.sh" = {
        source = ./scripts/on-add.delegate-someday.sh;
        executable = true;
      };
    };
  };
}



