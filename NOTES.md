## notes
* `yay -Qn` list "native" installed
* `yay -Qm`  list "foreign" installed
* `yay -Qs alsa` search for local install packages
* `pacman -Rs` remove dependencies
* `pacman -Rns` remove dependencies and pacsave-filer
* possibly the fuzzy yogurt could be made with `:reload` instead og `:execute`

* also note that 
    because I dont know how to get the field index 
    from the subshell command to the subshell preview 
    (when a fzf is called inside a fzf) 
    Therefore I have added a second script
    to list installed packages (`fyinfo`)
    which is being sourced from this script