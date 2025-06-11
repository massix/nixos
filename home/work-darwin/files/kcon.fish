#!/usr/bin/env fish

set -x KUBECONFIG_FOLDER $HOME/kconfigs

# Small helper function to switch to a given kubeconfig file, residing in the folder ~/kconfigs
function kcon --description "Switch to a given kubeconfig file in $KUBECONFIG_FOLDER" --argument-names cluster
    echo -e "Switching to $KUBECONFIG_FOLDER/$(set_color --bold green)$cluster$(set_color normal)"
    set -gx KUBECONFIG $KUBECONFIG_FOLDER/$cluster
end

complete --command kcon --no-files --arguments "$(ls $KUBECONFIG_FOLDER)"
