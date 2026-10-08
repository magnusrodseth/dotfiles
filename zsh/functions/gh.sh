#!/bin/zsh

# GitHub CLI shortcuts.
#
# Issues and PRs share one number sequence per repo, so the browser verbs never
# need to know which kind you handed them: `gh browse 123` resolves either.
# In the terminal they diverge, because `gh pr view` refuses an issue number
# while `gh issue view` silently redirects a PR number (and then mislabels it
# "Issue"). `ghv` tries pr first for that reason.

# ghv [<n>]  view issue or PR in the terminal, whichever the number is.
#            No argument views the PR for the current branch.
ghv() {
  if [[ -z "$1" ]]; then
    gh pr view
    return
  fi
  gh pr view "$@" 2>/dev/null || gh issue view "$@"
}

# ghw [<n>]  open issue or PR in the browser. No argument opens the repo.
alias ghw='gh browse'

# Terminal views, when you already know the kind.
alias ghi='gh issue view'          # ghi 123
alias ghic='gh issue view --comments'
alias ghp='gh pr view'             # ghp 123, or bare for the current branch
alias ghpc='gh pr view --comments'
alias ghpw='gh pr view --web'      # current branch's PR in the browser

# Lists and the rest of the daily loop.
alias ghil='gh issue list'
alias ghpl='gh pr list'
alias ghpd='gh pr diff'
alias ghpk='gh pr checks'
alias ghco='gh pr checkout'        # same as the `gh co` gh-alias
alias ghs='gh pr status'
alias ghr='gh repo view --web'
