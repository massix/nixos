{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf splitString;
  cfg = config.my-modules.taskwarrior;
  orEmpty = bool: val: if bool then val else [ ];
  hooksHome = "${config.xdg.dataHome}/task/hooks";
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
      colorTheme = "dark-16";
      config = {
        confirmation = true;
        weekstart = "monday";
        calendar.details = "sparse";
        calendar.holidays = "full";
        news.version = "3.4.1";

        journal.time = true;
        journal.info = true;

        holiday = {
          labourday.name = "Labour Day";
          labourday.date = "20250501";

          victoire.name = "Victoire 1945";
          victoire.date = "20250508";

          ascension.name = "Ascension";
          ascension.date = "20250529";

          pentecote.name = "Pentecôte";
          pentecote.date = "20250609";

          fetenationale.name = "Fête Nationale";
          fetenationale.date = "20250714";

          assomption.name = "Assomption";
          assomption.date = "20250815";

          toussaint.name = "Toussaint";
          toussaint.date = "20251101";

          armistice.name = "Armistice 1918";
          armistice.date = "20251111";

          noel.name = "Noël";
          noel.date = "20251225";
        };

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

            delegated = mkReport "Delegated tasks" "delegated.not: +PENDING" [
              "id:ID"
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

            completed-yesterday = (mkReport "Tasks completed yesterday" "status:completed end:yesterday -WAITING" [
              "uuid:UUID"
              "end.relative:Completed"
              "priority:P"
              "project:Project"
              "depends.list:Deps"
              (if cfg.withJira then "jira:Jira" else "")
              (if cfg.withJira then "sprint:Sprint" else "")
              "description.desc:Description"
            ]) // { sort = "project+,end+"; };
          };

        # User-defined attributes
        uda = {
          jira = mkIf cfg.withJira {
            type = "string";
            label = "Jira";
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
    };
  };
}



