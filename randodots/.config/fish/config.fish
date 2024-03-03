function fish_prompt -d "Write out the prompt"
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    set fish_greeting

end

starship init fish | source
zoxide init fish | source
if test -f ~/.cache/ags/user/colorschemes/sequences
    cat ~/.cache/ags/user/colorschemes/sequences
end

function __apx_debug
    set -l file "$BASH_COMP_DEBUG_FILE"
    if test -n "$file"
        echo "$argv" >> $file
    end
end

function __apx_perform_completion
    __apx_debug "Starting __apx_perform_completion"

    # Extract all args except the last one
    set -l args (commandline -opc)
    # Extract the last arg and escape it in case it is a space
    set -l lastArg (string escape -- (commandline -ct))

    __apx_debug "args: $args"
    __apx_debug "last arg: $lastArg"

    # Disable ActiveHelp which is not supported for fish shell
    set -l requestComp "APX_ACTIVE_HELP=0 $args[1] __complete $args[2..-1] $lastArg"

    __apx_debug "Calling $requestComp"
    set -l results (eval $requestComp 2> /dev/null)

    set -g __fish_git_prompt_show_informative_status 1
    set -g __fish_git_prompt_showupstream informative
    set -g __fish_git_prompt_showdirtystate yes
    set -g __fish_git_prompt_char_stateseparator ' '
    set -g __fish_git_prompt_char_cleanstate '✔'
    set -g __fish_git_prompt_char_dirtystate '✚'
    set -g __fish_git_prompt_char_invalidstate '✖'
    set -g __fish_git_prompt_char_stagedstate '●'
    set -g __fish_git_prompt_char_stashstate '⚑'
    set -g __fish_git_prompt_char_untrackedfiles '?'
    set -g __fish_git_prompt_char_upstream_ahead ''
    set -g __fish_git_prompt_char_upstream_behind ''
    set -g __fish_git_prompt_char_upstream_diverged 'ﱟ'
    set -g __fish_git_prompt_char_upstream_equal ''
    set -g __fish_git_prompt_char_upstream_prefix ''''

    set TERM_EMULATOR (ps -aux | grep (ps -p $fish_pid -o ppid=) | awk 'NR==1{print $11}')

    set TERM_EMULATOR (ps -aux | grep (ps -p $fish_pid -o ppid=) | awk 'NR==1{print $11}')

    abbr -a -g ytmp3 'youtube-dl --extract-audio --audio-format mp3'
    abbr -a -g cls 'clear'
    abbr -a -g h 'history'
    abbr -a -g upd 'paru -Syu --noconfirm'
    abbr -a -g please 'sudo'
    abbr -a -g fucking 'sudo'
    abbr -a -g sayonara 'shutdown now'
    abbr -a -g stahp 'shutdown now'
    abbr -a -g shinei 'kill -9'
    abbr -a -g kv 'kill -9 (pgrep vlc)'
    abbr -a -g priv 'fish --private'
    abbr -a -g sshon 'sudo systemctl start sshd.service'
    abbr -a -g sshoff 'sudo systemctl stop sshd.service'
    abbr -a -g untar 'tar -zxvf'
    abbr -a -g genpass 'openssl rand -base64 20'
    abbr -a -g sha 'shasum -a 256'
    abbr -a -g cn 'ping -c 5 8.8.8.8'
    abbr -a -g ipe 'curl ifconfig.co'
    abbr -a -g ips 'ip link show'
    abbr -a -g wloff 'rfkill block wlan'
    abbr -a -g wlon 'rfkill unblock wlan'

    # Some programs may output extra empty lines after the directive.
    # Let's ignore them or else it will break completion.
    # Ref: https://github.com/spf13/cobra/issues/1279
    for line in $results[-1..1]
        if test (string trim -- $line) = ""
            # Found an empty line, remove it
            set results $results[1..-2]
        else
            # Found non-empty line, we have our proper output
            break
        end
    end

    set -l comps $results[1..-2]
    set -l directiveLine $results[-1]

    # For Fish, when completing a flag with an = (e.g., <program> -n=<TAB>)
    # completions must be prefixed with the flag
    set -l flagPrefix (string match -r -- '-.*=' "$lastArg")

    __apx_debug "Comps: $comps"
    __apx_debug "DirectiveLine: $directiveLine"
    __apx_debug "flagPrefix: $flagPrefix"

    for comp in $comps
        printf "%s%s\n" "$flagPrefix" "$comp"
    end

    printf "%s\n" "$directiveLine"
end

# This function does two things:
# - Obtain the completions and store them in the global __apx_comp_results
# - Return false if file completion should be performed
function __apx_prepare_completions
    __apx_debug ""
    __apx_debug "========= starting completion logic =========="

    # Start fresh
    set --erase __apx_comp_results

    set -l results (__apx_perform_completion)
    __apx_debug "Completion results: $results"

    if test -z "$results"
        __apx_debug "No completion, probably due to a failure"
        # Might as well do file completion, in case it helps
        return 1
    end

    set -l directive (string sub --start 2 $results[-1])
    set --global __apx_comp_results $results[1..-2]

    __apx_debug "Completions are: $__apx_comp_results"
    __apx_debug "Directive is: $directive"

    set -l shellCompDirectiveError 1
    set -l shellCompDirectiveNoSpace 2
    set -l shellCompDirectiveNoFileComp 4
    set -l shellCompDirectiveFilterFileExt 8
    set -l shellCompDirectiveFilterDirs 16

    if test -z "$directive"
        set directive 0
    end

    set -l compErr (math (math --scale 0 $directive / $shellCompDirectiveError) % 2)
    if test $compErr -eq 1
        __apx_debug "Received error directive: aborting."
        # Might as well do file completion, in case it helps
        return 1
    end

    set -l filefilter (math (math --scale 0 $directive / $shellCompDirectiveFilterFileExt) % 2)
    set -l dirfilter (math (math --scale 0 $directive / $shellCompDirectiveFilterDirs) % 2)
    if test $filefilter -eq 1; or test $dirfilter -eq 1
        __apx_debug "File extension filtering or directory filtering not supported"
        # Do full file completion instead
        return 1
    end

    set -l nospace (math (math --scale 0 $directive / $shellCompDirectiveNoSpace) % 2)
    set -l nofiles (math (math --scale 0 $directive / $shellCompDirectiveNoFileComp) % 2)

    __apx_debug "nospace: $nospace, nofiles: $nofiles"

    # If we want to prevent a space, or if file completion is NOT disabled,
    # we need to count the number of valid completions.
    # To do so, we will filter on prefix as the completions we have received
    # may not already be filtered so as to allow fish to match on different
    # criteria than the prefix.
    if test $nospace -ne 0; or test $nofiles -eq 0
        set -l prefix (commandline -t | string escape --style=regex)
        __apx_debug "prefix: $prefix"

        set -l completions (string match -r -- "^$prefix.*" $__apx_comp_results)
        set --global __apx_comp_results $completions
        __apx_debug "Filtered completions are: $__apx_comp_results"

        # Important not to quote the variable for count to work
        set -l numComps (count $__apx_comp_results)
        __apx_debug "numComps: $numComps"

        if test $numComps -eq 1; and test $nospace -ne 0
            # We must first split on \t to get rid of the descriptions to be
            # able to check what the actual completion will be.
            # We don't need descriptions anyway since there is only a single
            # real completion which the shell will expand immediately.
            set -l split (string split --max 1 \t $__apx_comp_results[1])

            # Fish won't add a space if the completion ends with any
            # of the following characters: @=/:.,
            set -l lastChar (string sub -s -1 -- $split)
            if not string match -r -q "[@=/:.,]" -- "$lastChar"
                # In other cases, to support the "nospace" directive we trick the shell
                # by outputting an extra, longer completion.
                __apx_debug "Adding second completion to perform nospace directive"
                set --global __apx_comp_results $split[1] $split[1].
                __apx_debug "Completions are now: $__apx_comp_results"
            end
        end

        if test $numComps -eq 0; and test $nofiles -eq 0
            # To be consistent with bash and zsh, we only trigger file
            # completion when there are no other completions
            __apx_debug "Requesting file completion"
            return 1
        end
    end

    return 0
end

if type -q "apx"
    complete --do-complete "apx " > /dev/null 2>&1
end

complete -c apx -e

complete -c apx -n '__apx_prepare_completions' -f -a '$__apx_comp_results'
