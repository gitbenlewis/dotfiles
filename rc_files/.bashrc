############################################################################ BEN add start

#########################################################################

## terminal improvement
alias cp='cp -iv' #  cp implementation
alias mv='mv -iv' #  mv implementation
alias mkdir='mkdir -pv' #  mkdir implementation
alias ll='ls -FGlAhp' #  ls implementation
alias less='less -FSRXc' #  less implementation
cd() { builtin cd "$@"; ll; } #  list directory contents with cd
alias cd..='cd ../' #  back 1 directory level (for fast typers)
alias ..='cd ../' #  back 1 directory level
alias ...='cd ../../' #  go up 2 directory levels
alias .3='cd ../../../' #  back 3 directory levels
alias .4='cd ../../../../' #  back 4 directory levels
alias .5='cd ../../../../../' #  back 5 directory levels
alias .6='cd ../../../../../../' #  back 6 directory levels
alias edit='subl' # edit: Opens any file in sublime editor
alias f='open -a Finder ./' # f: Opens current directory in MacOS Finder
alias ~="cd ~" # ~: Go Home
alias c='clear' # c: Clear terminal display
alias which='type -all' # which: Find executables
alias path='echo -e ${PATH//:/\\n}' # path: Echo all executable Paths
alias cic='set completion-ignore-case On' # cic: Make tab-completion case-insensitive

# lr: Full Recursive Directory Listing

# ------------------------------------------

alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/ /'\'' -e '\''s/-/|/'\'' | less'

alias allsizes='du -h | sort -hr'
alias sizes0='du -h --max-depth=0 | sort -hr'
alias sizes='du -h --max-depth=1 | sort -hr'
alias sizes1='du -h --max-depth=1 | sort -hr'
alias sizes2='du -h --max-depth=2 | sort -hr'
alias mypaths='echo "${PATH//:/$'\n'}"'

alias gitcheck='git diff --cached --name-only | xargs du -h | sort -hr | head -n 10'

########################################################################

############################################################################# BEN add end
