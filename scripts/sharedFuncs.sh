
#has tow mode [pkgName] [mode=summary]
function package_installed() {
    which $1 &> /dev/null
    local pkginstalled="$?"

    if [ "$2" == "summary" ];then
        if [ "$pkginstalled" -eq 0 ];then
            echo "true"
        else
            echo "false"
        fi
    else
        if [ "$pkginstalled" -eq 0 ];then
            show_message "package\033[1;36m $1\e[0m is installed..."
        else
            warning "package\033[1;33m $1\e[0m is not installed."
            ask_question "would you like to install it now?" "Y"
            if [ "$question_result" == "no" ];then
                echo "exit..."
                exit 5
            else
                declare -A osInfo;
                osInfo[/etc/redhat-release]=yum
                osInfo[/etc/SuSE-release]=zypper
                osInfo[/etc/debian_version]=apt-get

                for f in ${!osInfo[@]}
                do
                    if [[ -f $f ]];then
						sudo ${osInfo[$f]} update
						sudo ${osInfo[$f]} install $1
						return
                    fi
                done
                # setup for arch-based systems
            	sudo pacman -Syu
                sudo pacman -S coreutils
				sudo pacman -S $1
			fi
        fi
    fi
}

function setup_log() {
    echo -e "$(date) : $@" >> $SCR_PATH/setuplog.log
}

function show_message() {
    echo -e "$@"
    setup_log "$@"
}

function error() {
    echo -e "\033[1;31merror:\e[0m $@"
    setup_log "$@"
    exit 1
}

function error2() {
    echo -e "\033[1;31merror:\e[0m $@"
    exit 1
}

function warning() {
    echo -e "\033[1;33mWarning:\e[0m $@"
    setup_log "$@"
}

function warning2() {
    echo -e "\033[1;33mWarning:\e[0m $@"
}

function show_message2() {
    echo -e "$@"
}

function launcher() {
    
    #create launcher script
    local launcher_path="$PWD/launcher.sh"
    local launcher_dest="$SCR_PATH/launcher"
    rmdir_if_exist "$launcher_dest"


    if [ -f "$launcher_path" ];then
        show_message "launcher.sh detected..."
        
        cp "$launcher_path" "$launcher_dest" || error "can't copy launcher"
        
        sed -i "s|wapath|$SCR_PATH|g" "$launcher_dest/launcher.sh" && sed -i "s|wacache|$CACHE_PATH|g" "$launcher_dest/launcher.sh" || error "can't edit launcher script"
        
        chmod +x "$SCR_PATH/launcher/launcher.sh" || error "can't chmod launcher script"
    else
        error "launcher.sh Note Found"
    fi

    #create desktop entry
    local desktop_entry="$PWD/winamp.desktop"
    local desktop_entry_dest="/home/$USER/.local/share/applications/winamp.desktop"
    
    if [ -f "$desktop_entry" ];then
        show_message "desktop entry detected..."
       
        #delete desktop entry if exists
        if [ -f "$desktop_entry_dest" ];then
            show_message "desktop entry exist deleted..."
            rm "$desktop_entry_dest"
        fi
        cp "$desktop_entry" "$desktop_entry_dest" || error "can't copy desktop entry"
        sed -i "s|wapath|$SCR_PATH|g" "$desktop_entry_dest" || error "can't edit desktop entry"
    else
        error "desktop entry Not Found"
    fi

    #change winamp icon of desktop entry
    local entry_icon="../images/Winamp-icon.png"
    local launch_icon="$launcher_dest/Winamp-icon.png"

    cp "$entry_icon" "$launcher_dest" || error "can't copy icon image"
    sed -i "s|winampicon|$launch_icon|g" "$desktop_entry_dest" || error "can't edit desktop entry"
    sed -i "s|winamp
    icon|$launch_icon|g" "$launcher_dest/launcher.sh" || error "can't edit launcher script"
    
    #create winamp command
    show_message "creating winamp command..."
    if [ -f "/usr/local/bin/winamp" ];then
        show_message "winamp command exists, deleted..."
        sudo rm "/usr/local/bin/winamp"
    fi
    sudo ln -s "$SCR_PATH/launcher/launcher.sh" "/usr/local/bin/winamp" || error "can't create winamp command"

    unset desktop_entry desktop_entry_dest launcher_path launcher_dest
}



function export_var() {
    export WINEPREFIX="$WINE_PREFIX"
    show_message "wine variables exported..."
}

#parameters is [PATH] [CheckSum] [URL] [FILE NAME]
function download_component() {
    local tout=0
    while true;do
        if [ $tout -ge 3 ];then
            error "sorry something went wrong during download $4"
        fi
        if [ -f $1 ];then
            local FILE_ID=$(md5sum $1 | cut -d" " -f1)
            if [ "$FILE_ID" == $2 ];then
                show_message "\033[1;36m$4\e[0m detected"
                return 0
            else
                show_message "md5 is not match"
                rm $1 
            fi
        else   
            show_message "downloading $4 ..."
            ariapkg=$(package_installed aria2c "summary")
            curlpkg=$(package_installed curl "summary")
            
            if [ "$ariapkg" == "true" ];then
                show_message "using aria2c to download $4"
                aria2c -c -x 8 -d "$CACHE_PATH" -o $4 $3
                
                if [ $? -eq 0 ];then
                    notify-send "WinampLinux" "$4 download completed" -i "download"
                fi

            elif [ "$curlpkg" == "true" ];then
                show_message "using curl to download $4"
                curl $3 -o $1
            else
                show_message "using wget to download $4"
                wget "$3" -P "$CACHE_PATH"
                
                if [ $? -eq 0 ];then
                    notify-send "WinampLinux" "$4 download completed" -i "download"
                fi
            fi
            ((tout++))
        fi
    done
}

function rmdir_if_exist() {
    if [ -d "$1" ];then
        rm -rf "$1"
        show_message "\033[0;36m$1\e[0m directory exists deleting it..."
    fi
    mkdir "$1"
    show_message "create\033[0;36m $1\e[0m directory..."
}

function check_arg() {
    while getopts "hd:c:" OPTION; do
        case $OPTION in
        d)
            PARAMd="$OPTARG"
            SCR_PATH=$(readlink -f "$PARAMd")
            
            dashd=1
            echo "install path is $SCR_PATH"
            ;;
        c)
            PARAMc="$OPTARG"
            CACHE_PATH=$(readlink -f "$PARAMc")
            dashc=1
            echo "cahce is $CACHE_PATH"
            ;;
        h)
            usage
            ;; 
        *)
            echo "wrong argument"
            exit 1
            ;;
        esac
    done
    shift $(($OPTIND - 1))

    if [[ $# != 0 ]];then
        usage
        error2 "unknown argument"
    fi

    if [[ $dashd != 1 ]] ;then
        echo "-d not define default directory used..."
        SCR_PATH="$HOME/.WinampLinux"
    fi

    if [[ $dashc != 1 ]];then
        echo "-c not define default directory used..."
        CACHE_PATH="$HOME/.cache/WinampLinux"
    fi
}

function is64() {
    local arch=$(uname -m)
    if [ $arch != "x86_64"  ];then
        warning "your distro is not 64 bit"
        read -r -p "Would you continue? [N/y] " response
        if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]];then
           echo "Good Bye!"
           exit 0
        fi
    fi
   show_message "is64 checked..."
}

#parameters [Message] [default flag [Y/N]]
function ask_question() {
    question_result=""
    if [ "$2" == "Y" ];then
        read -r -p "$1 [Y/n] " response
        if [[ "$response" =~ $(locale noexpr) ]];then
            question_result="no"
        else
            question_result="yes"
        fi
    elif [ "$2" == "N" ];then
        read -r -p "$1 [N/y] " response
        if [[ "$response" =~ $(locale yesexpr) ]];then
            question_result="yes"
        else
            question_result="no"
        fi
    fi
}

function usage() {
    echo "USAGE: [-c cache directory] [-d installation directory]"
}

function save_paths() {
    local datafile="$HOME/.wadata.txt"
    echo "$SCR_PATH" > "$datafile"
    echo "$CACHE_PATH" >> "$datafile"
    unset datafile
}

function load_paths() {
    local datafile="$HOME/.wadata.txt"
    SCR_PATH=$(head -n 1 "$datafile")
    CACHE_PATH=$(tail -n 1 "$datafile")
    unset datafile
}
