#!/usr/bin/env fish

set -x KUBECONFIG_FOLDER $HOME/pinniped-kubeconfigs/

# Small helper function to switch to a given cluster's kubeconfig, residing in
# the folder ~/pinniped-kubeconfigs/. Files are named <tenant>__<cluster>-<variant>.yaml,
# where <variant> is one of admin, pinniped or plain (default: plain).
function kcon --description "Switch to a given kubeconfig file in $KUBECONFIG_FOLDER"
    argparse --exclusive a,t,p a/admin t/tanzu p/plain -- $argv
    or return

    if test (count $argv) -eq 0
        set -e KUBECONFIG
        echo -e "☸️ Removing $(set_color --bold red)\$KUBECONFIG$(set_color normal)"
        return
    end

    set -l variant plain
    if set -q _flag_admin
        set variant admin
    else if set -q _flag_tanzu
        set variant pinniped
    end

    set kpath ""
    for cluster in $argv
        set -l matches (command find $KUBECONFIG_FOLDER -type f -name "*__$cluster-$variant.yaml")
        if test (count $matches) -eq 0
            echo -e "☸️ $(set_color --bold red)No $variant kubeconfig found for $cluster$(set_color normal)" >&2
            continue
        end
        set kpath "$matches[1]:$kpath"
        echo -e "☸️ Cluster Active: $(set_color --bold green)$cluster$(set_color normal) ($variant)"
    end

    set -gx KUBECONFIG $kpath
end

function _complete_kcon --description "Tab completion for kcon"
    for f in (command find $KUBECONFIG_FOLDER -type f -name '*.yaml')
        set -l name (basename $f .yaml)
        set -l after (string replace -r '^[^_]*__' '' $name)
        string replace -r -- '-(admin|pinniped|plain)$' '' $after
    end | sort -u
end

complete --command kcon --no-files --arguments "(_complete_kcon)"
complete --command kcon -s a -l admin --description "Use the -admin.yaml kubeconfig"
complete --command kcon -s t -l tanzu --description "Use the -pinniped.yaml kubeconfig"
complete --command kcon -s p -l plain --description "Use the -plain.yaml kubeconfig (default)"
