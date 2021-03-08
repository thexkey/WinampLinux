#!/usr/bin/env bash
source "sharedFuncs.sh"

function main() {
    
    mkdir -p $SCR_PATH
    mkdir -p $CACHE_PATH
    
    setup_log "================| script executed |================"

    is64

    #make sure wine and winetricks package is already installed
    package_installed wine
    package_installed md5sum
    package_installed winetricks

    RESOURCES_PATH="$SCR_PATH/resources"
    WINE_PREFIX="$SCR_PATH/prefix"
    
    #create new wine prefix for Winamp
    rmdir_if_exist $WINE_PREFIX
    
    #export necessary variable for wine
    export_var
    
    #config wine prefix and install mono and gecko automatic
    echo -e "\033[1;93mplease install gecko package BUT DO NOT INSTALL MONO, then click on OK button\e[0m"
    WINEARCH=win32 winecfg 2> "$SCR_PATH/wine-error.log"
    if [ $? -eq 0 ];then
        show_message "prefix configured..."
        sleep 5
    else
        error "prefix config failed :("
    fi
    
    
   
    #create resources directory 
    rmdir_if_exist $RESOURCES_PATH

    # these might work, just commented out because of a x86 bug.
    #winetricks  fontsmooth=rgb vcrun2008 vcrun2010 vcrun2012 vcrun2013 atmlib msxml3 msxml6 dotnet456
    
    #install Winamp
    sleep 3
    install_Winamp
    sleep 5
    
    replacement

    if [ -d $RESOURCES_PATH ];then
        show_message "deleting resources folder"
        rm -rf $RESOURCES_PATH
    else
        error "resources folder Not Found"
    fi

    launcher
    show_message "\033[1;33mwhen you run winamp for the first time, it may take a while\e[0m"
    show_message "Almost finished installing..."
    sleep 30
}



function install_Winamp() {
    local filename="winamp58_3660_beta_full_en-us.exe"
    local filemd5="3017f921a6c42a267842cc8bae9384c1"
    local filelink="https://download.nullsoft.com/winamp/misc/winamp58_3660_beta_full_en-us.exe"
    
    local filepath="$CACHE_PATH/$filename"

    download_component $filepath $filemd5 $filelink $filename


    echo "===============| Winamp 5.8 |===============" >> "$SCR_PATH/wine-error.log"
    show_message "installing Winamp from internet..."
    show_message "\033[1;33mPlease don't change the default Destination Folder\e[0m"

    WINEARCH=win32 wine "$CACHE_PATH/winamp58_3660_beta_full_en-us.exe" &>> "$SCR_PATH/wine-error.log" || error "something went wrong during Winamp installation"
    
  

    notify-send "WinampLinux" "Winamp 5.8 installed successfully" -i "winamp"
    show_message "Winamp 5.8 x64 installed..."
    unset filename filemd5 filelink filepath
}

check_arg $@
save_paths
main
