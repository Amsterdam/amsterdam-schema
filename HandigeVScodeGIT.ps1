#filenames too long
git config --global core.longpaths true

# Multi repo workspace
Git: Clone

#Rebase van Jamil / Cathy
git branch -a
git fetch origin
git checkout develop
    git rebase
git checkout powerbi/rebased_ont_jz
    git pull
git rebase develop
git push --force

#Branch local clean up
git branch
git branch -D docs/20250812_verkeersstroom_gasdnas
git branch | Select-String 'powerbi'
git branch | Select-String 'powerbi' | ForEach-Object { git branch -D $_.Line.Trim() }
git branch | Select-String 'feature'
git branch | Select-String 'feature' | ForEach-Object { git branch -D $_.Line.Trim() }

#copilot
git fetch origin
git checkout develop
git checkout main
git checkout powerbi/jeugdzorg01ontrebasetest
git rebase origin/develop
git rebase main
git rebase --continue
Remove-Item -Path .git/rebase-merge -Recurse -Force
Remove-Item -Path .git/rebase-apply -Recurse -Force
git push --force-with-lease

# Stash your unstaged changes
git stash
git fetch origin
git checkout main
git rebase --continue

# Reapply your stashed changes (if any)
git stash pop
# Reset your local branch to match the remote branch (origin)
git reset --hard origin/develop
# Force push your rebased branch to the remote repository
git push --force-with-lease

# harde reset
git fetch origin
git reset --hard origin/main

# Forceer verwijderen van alle blokkerende mappen
Get-ChildItem -Directory -Recurse | Where-Object { $_.FullName -like "*azure*" } | ForEach-Object {
    try {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "Kon $($_.FullName) niet verwijderen - overslaan"
    }
}

# github
git config --global user.email "d.lohn@amsterdam.nl"
git config --global user.name "Django Lohn"

git remote add upstream https://github.com/Amsterdam/amsterdam-schema.git
git fetch upstream
git checkout master
git fetch origin
git reset --hard upstream/master
git push origin master --force