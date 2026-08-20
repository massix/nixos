#!/usr/bin/env fish

set -g RAPID_LOG_DIR $HOME/rapid-log

# Resolves --year/--month/--day into a list of files to operate on plus an
# optional day filter, following a cascade: --day alone implies the current
# month; --month alone implies the current year; --year alone means every
# month in that year; nothing given means today only.
function _rlog_scope --description "Resolve rapid-log scope from --year/--month/--day"
    argparse 'y/year=' 'm/month=' 'd/day=' -- $argv

    set -g _rlog_scope_files
    set -g _rlog_scope_day ""

    set eff_year $_flag_year
    test -n "$eff_year"; or set eff_year (date +%Y)

    if test -n "$_flag_day" -a -z "$_flag_month"
        set eff_month (date +%m)
        set -g _rlog_scope_day (printf "%02d" $_flag_day)
        set -g _rlog_scope_files "$RAPID_LOG_DIR/$eff_year/$eff_month.md"
    else if test -n "$_flag_month"
        set eff_month (printf "%02d" $_flag_month)
        if test -n "$_flag_day"
            set -g _rlog_scope_day (printf "%02d" $_flag_day)
        end
        set -g _rlog_scope_files "$RAPID_LOG_DIR/$eff_year/$eff_month.md"
    else if test -n "$_flag_year"
        set -g _rlog_scope_files $RAPID_LOG_DIR/$eff_year/*.md
    else
        set eff_month (date +%m)
        set -g _rlog_scope_day (date +%d)
        set -g _rlog_scope_files "$RAPID_LOG_DIR/$eff_year/$eff_month.md"
    end
end

function rlog --description "Append a rapid log entry for today"
    set day (date +%d)
    set year (date +%Y)
    set month (date +%m)
    set time (date +%H:%M)
    set dir $RAPID_LOG_DIR/$year

    mkdir -p $dir
    echo "- $day $time $argv" >>$dir/$month.md
    echo -e "📝 Logged to $(set_color --bold green)$dir/$month.md$(set_color normal)"
end

function rsearch --description "Search rapid-log entries"
    argparse 'y/year=' 'm/month=' 'd/day=' -- $argv
    set term $argv[1]

    if test -z "$term"
        echo "Usage: rsearch [--year Y] [--month M] [--day D] <term>" >&2
        return 1
    end

    _rlog_scope --year "$_flag_year" --month "$_flag_month" --day "$_flag_day"

    set doc
    for f in $_rlog_scope_files
        test -f $f; or continue

        if test -n "$_rlog_scope_day"
            set matches (command grep -E -- "^- $_rlog_scope_day " $f | rg -i --no-heading --color never --replace '**$0**' -- "$term")
        else
            set matches (rg -i --no-heading --color never --replace '**$0**' -- "$term" $f)
        end

        if test -n "$matches"
            set -a doc "## $f" "" $matches ""
        end
    end

    if test -z "$doc"
        echo "No matches found." >&2
        return 1
    end

    printf '%s\n' $doc | glow -
end

function rshow --description "Show rapid-log entries"
    argparse 'y/year=' 'm/month=' 'd/day=' -- $argv

    _rlog_scope --year "$_flag_year" --month "$_flag_month" --day "$_flag_day"

    set doc
    for f in $_rlog_scope_files
        test -f $f; or continue

        if test -n "$_rlog_scope_day"
            set lines (command grep -E -- "^- $_rlog_scope_day " $f)
        else
            set lines (cat $f)
        end

        if test -n "$lines"
            set -a doc "## $f" "" $lines ""
        end
    end

    if test -z "$doc"
        echo "No rapid-log entries found." >&2
        return 1
    end

    printf '%s\n' $doc | glow -
end

function rdelete --description "Remove the last logged line from today's rapid-log file"
    set year (date +%Y)
    set month (date +%m)
    set file $RAPID_LOG_DIR/$year/$month.md

    if not test -f $file
        echo "No log file for $year/$month" >&2
        return 1
    end

    set last (tail -n 1 $file)
    set tmp (mktemp)
    sed '$d' $file >$tmp
    and mv $tmp $file
    echo -e "🗑️  $(set_color --bold red)Removed: $last$(set_color normal)"
end
