#!/usr/bin/env fish

set -x KUBECONFIG_FOLDER $HOME/kconfigs

# Small helper function to switch to a given kubeconfig file, residing in the folder ~/kconfigs
function kcon --description "Switch to a given kubeconfig file in $KUBECONFIG_FOLDER"
    if test (count $argv) -eq 0
        set -e KUBECONFIG
        echo -e "☸️ Removing $(set_color --bold red)\$KUBECONFIG$(set_color normal)"
    end

    set kpath ""
    for cluster in $argv
        if test -d "$KUBECONFIG_FOLDER/$cluster"
            for kconf in (command find $KUBECONFIG_FOLDER/$cluster -type f)
                set kconf_relative (echo $kconf | sed 's@'"$KUBECONFIG_FOLDER/"'@@')
                set kpath "$KUBECONFIG_FOLDER/$kconf_relative:$kpath"
                echo -e "☸️ Cluster Active: $(set_color --bold green)$kconf_relative$(set_color normal)"
            end
        else
            set kpath "$KUBECONFIG_FOLDER/$cluster:$kpath"
            echo -e "☸️ Cluster Active: $(set_color --bold green)$cluster$(set_color normal)"
        end
    end

    set -gx KUBECONFIG $kpath
end

# And of course the complete function has more lines than the function itself.
function _complete_kcon --description "Tab completion for kcon"
    for f in (command find $KUBECONFIG_FOLDER -type f)
        set dir_name (dirname $f | sed 's@'"$KUBECONFIG_FOLDER/"'@@')
        set cluster_name (basename $f)
        echo $dir_name/$cluster_name
    end

    for f in (command find $KUBECONFIG_FOLDER -type d)
        echo $f | sed 's@'"$KUBECONFIG_FOLDER/"'@@'
    end
end

complete --command kcon --no-files --arguments "$(_complete_kcon)"
