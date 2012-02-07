SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY="${bold_red}✖${normal}"
SCM_THEME_PROMPT_CLEAN="${bold_green}✔${normal}"

SCM_GIT_CHAR="${green}${SCM_GIT_CHAR}${normal}"
SCM_SVN_CHAR="${cyan}${SCM_SVN_CHAR}${normal}"
SCM_HG_CHAR="${red}${SCM_HG_CHAR}${normal}"

#Mysql Prompt
export MYSQL_PS1="(\u@\h) [\d]> "

case $TERM in
        xterm*)
        TITLEBAR="\[\033]0;\w\007\]"
        ;;
        *)
        TITLEBAR=""
        ;;
esac

PS3=""

modern_scm_prompt() {
    scm_prompt_vars
    [[ $SCM == $SCM_NONE ]] && return
    echo -e "⇅$(color underline)${SCM_STATE}${underline_blue}${SCM_BRANCH}${SCM_CHAR}${normal}"
}

prompt() {
    my_ps_host="${green}\h${normal}";
    my_ps_user="${orange}\u${normal}";
    my_ps_root="$(color rgb 255 0 0 negative bold)☢\u☢${normal}";
    my_ps_path="${cyan}\w${normal}";

    # nice prompt
    case "`id -u`" in
        0) PS1="${TITLEBAR}$my_ps_root⌁$my_ps_host⎓$my_ps_path$(modern_scm_prompt)⚡ "
        ;;
        *) PS1="${TITLEBAR}$my_ps_user⌁$my_ps_host⎓$my_ps_path$(modern_scm_prompt)⚡ "
        ;;
    esac
}
PS2=""



PROMPT_COMMAND=prompt
