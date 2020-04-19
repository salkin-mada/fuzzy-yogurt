# fuzzy yogurt

a fuzzy yogurt that finds and selects packages for installation.

<3 fzf and <3 yay!

![fy example](./media/fy_use.gif)

by default supported repositories are core, extra, community and aur. 

it does not include development packages.

## installation

* assuming you have `git`

* install [yay](https://github.com/Jguer/yay)
    ```
    git clone https://github.com/Jguer/yay.git
    cd yay
    makepkg -si
    ```

* install [fzf](https://github.com/junegunn/fzf)
    ```
    yay -S fzf
    ```

* place `fy` and `fyinfo` in you $PATH
* make them executable. there are several ways of doing that. here is one for your user:
    ```
    chmod u+x fy fyinfo
    ```

## use the fuzzy yogurt

* simply just run `fy` to index all repositories.
    ```
    fy
    ```

* start a fuzzy yogurt with light colors and query alsa packages in the extra and aur repositories
    ```
    fy -q alsa -r extra aur -s l
    ```

* get some help
    ```
    fy -h
    ```
    
![<3](./media/ascii_wombat.png "arch")