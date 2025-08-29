#!/usr/bin/env fish

set -x KUBECONFIG_FOLDER $HOME/kconfigs

# Small helper function to switch to a given kubeconfig file, residing in the folder ~/kconfigs
function kcon --description "Switch to a given kubeconfig file in $KUBECONFIG_FOLDER" --argument-names cluster
    echo -e "Switching to $KUBECONFIG_FOLDER/$(set_color --bold green)$cluster$(set_color normal)"
    set -gx KUBECONFIG $KUBECONFIG_FOLDER/$cluster
end

# And of course the complete function has more lines than the function itself.
function _complete_kcon --description "Tab completion for kcon"
    for f in (command find $KUBECONFIG_FOLDER -type f)
        set dir_name (dirname $f | sed 's@'"$KUBECONFIG_FOLDER/"'@@')
        set cluster_name (basename $f)
        echo $dir_name/$cluster_name
    end
end

complete --command kcon --no-files --arguments "$(_complete_kcon)"
