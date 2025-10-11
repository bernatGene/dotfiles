function newnote --description 'create or open a note, then copy its contents'
    # determine if argv[1] is an existing file
    if test (count $argv) -eq 1; and test -f $argv[1]
        set file $argv[1]
    else
        # prefix from arg or cwd name
        if test (count $argv) -gt 0
            set prefix $argv[1]
        else
            set prefix (basename (pwd))"_"
        end
        set ts (date +%Y%m%d_%H%M%S)
        set file $prefix$ts.txt
    end

    vim $file

    if test $status -eq 0
        if type -q pbcopy
            pbcopy <$file
        else if type -q xclip
            xclip -selection clipboard <$file
        else if type -q wl-copy
            wl-copy <$file
        else
            echo "No clipboard utility found" >&2
            return 1
        end
        echo "✔  $file → clipboard"
    end
end

function newnote_last --description 'open latest note or fail'
    # prefix from arg or cwd name
    if test (count $argv) -gt 0
        set prefix $argv[1]
    else
        set prefix (basename (pwd))"_"
    end

    # find latest matching file
    set files (ls -1t $prefix*.txt 2>/dev/null)
    if test -z "$files"
        echo "No notes found with prefix '$prefix'" >&2
        return 1
    end
    # take first line
    set latest (string split "\n" $files)[1]
    newnote $latest
end

alias nn=newnote
alias nnl=newnote_last
