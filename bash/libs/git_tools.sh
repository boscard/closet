function g_clone () {
        repo_link="$1"
        basePath="${HOME}/Workspace/src"
        repoPath="$(echo $repo_link | sed -e 's/^git@//' -e 's;^https://;;' -e 's/\.git$//' | tr ':' '/' )"
        git clone "${repo_link}" "${basePath}/${repoPath}" && cd "${basePath}/${repoPath}"
}

function g_ls () {
        provider="$1"
        if [ "$provider" == "" ]
        then
                provider="gh"
        fi
        code_path="$HOME/Workspace/src"
        case $provider in
                gh|github)
                        code_path="$code_path/github.com"
                        ;;
                gl|gitlab)
                        code_path="$code_path/gitlab.com"
                        ;;
                *)
                        code_path="$code_path/$provider"
                        ;;
        esac
        ls "$code_path"
}

