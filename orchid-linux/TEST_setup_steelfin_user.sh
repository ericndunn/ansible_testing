#!/bin/bash

cd $( dirname "$0" )
script_dir=$( pwd -P )
orchid_install_dir="${script_dir}/orchid_install_files"

if [[ ! -f ${script_dir}/steelfin_common.sh ]]; then
    echo "Failed to load steelfin_common.sh"
    exit 1
fi

source ${script_dir}/steelfin_common.sh

if [[ $USER == "root" ]]; then
    die_with_error "This script must NOT be run as root!"
fi

configure_gsettings() {
    # gsettings doesn't work unless there's an active X11 session.
    # If there isn't, we have to run it using dbus-launcher.
    gsettings_preamble=""
    if [[ -z ${DISPLAY} ]]; then
        gsettings_preamble="dbus-launch"
    fi
}

set_default_applications() {
    trap die_with_error ERR

    mkdir -p ~/.local/share/applications/

    if [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "16.04" ]]; then
        default_browser="google-chrome.desktop"
    elif [[ $distro_id == "Ubuntu" ]] && [[ $distro_release == "18.04" ]]; then 
        default_browser="google-chrome.desktop"
    elif [[ $distro_id == "CentOS" ]]; then 
        default_browser="google-chrome.desktop"              
    else
        default_browser="firefox-esr.desktop"
    fi

    # * Associate VLC with .mkv
    echo "[Default Applications]
    text/html=${default_browser}
    x-scheme-handler/http=${default_browser}
    x-scheme-handler/https=${default_browser}
    x-scheme-handler/about=${default_browser}
    x-scheme-handler/unknown=${default_browser}
    video/x-matroska=vlc.desktop
    video/quicktime=vlc.desktop

    [Added Associations]
    video/quicktime=vlc.desktop;
    video/x-matroska=vlc.desktop;" > ~/.local/share/applications/mimeapps.list

    # Add Teamviewer users's applications
    cp ${orchid_install_dir}/teamviewer.desktop ~/.local/share/applications/
}

lock_down_desktop_environment() {
    trap die_with_error ERR

    if [[ $distro_id == "Ubuntu" ]]; then
        ${gsettings_preamble} gsettings set com.canonical.Unity.Launcher favorites "['application://${default_browser}', 'application://firefox-esr.desktop', 'application://nautilus.desktop', 'application://vlc.desktop', 'application://teamviewer.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"

    elif [[ $distro_id == "CentOS" ]] || [[ $distro_id == "RedHatEnterpriseServer" ]]; then
        # Disable locking the screen 
        ${gsettings_preamble} gsettings set org.gnome.desktop.lockdown disable-lock-screen true

        # Don't show notifications when logged out
        ${gsettings_preamble} gsettings set org.gnome.desktop.notifications show-in-lock-screen false

        # Set login screen background 
        ${gsettings_preamble} gsettings set org.gnome.desktop.screensaver picture-uri "file:///home/orchid/.orchid/orchid_background.jpg"

        # Hide trash, home, and drives from Desktop
        ${gsettings_preamble} gsettings set org.gnome.nautilus.desktop trash-icon-visible false
        ${gsettings_preamble} gsettings set org.gnome.nautilus.desktop home-icon-visible false
        ${gsettings_preamble} gsettings set org.gnome.nautilus.desktop volumes-visible false

        # Put some links on the Desktop 
        # Nautilus link
        chmod 755 ~/Desktop
	
        if [[ -f /usr/share/applications/nautilus.desktop ]]; then
            cp /usr/share/applications/nautilus.desktop ~/Desktop 
        else
            cp ${orchid_install_dir}/nautilus.desktop ~/Desktop 
        fi
        sed -i "s/^NoDisplay=true/#NoDisplay=true/" ~/Desktop/nautilus.desktop
        sed -i "s/^OnlyShowIn=/#OnlyShowIn=/" ~/Desktop/nautilus.desktop
        chmod 755 ~/Desktop/nautilus.desktop
        
        # VLC link
        cp /usr/share/applications/vlc.desktop ~/Desktop 
        chmod 755 ~/Desktop/vlc.desktop

        # Chrome link
        cp /usr/share/applications/google-chrome.desktop ~/Desktop 
        sed -i "s/^Name=.*/Name=Launch Orchid VMS (Chrome browser)/" ~/Desktop/google-chrome.desktop
        chmod 755 ~/Desktop/google-chrome.desktop

        # Teamviewer Link
        cp ${orchid_install_dir}/teamviewer.desktop ~/Desktop
        chmod 755 ~/Desktop/teamviewer.desktop

        # maxView Storage Manager Link
        if [[ -f /usr/StorMan/StorMan.desktop ]]; then
            cp /usr/StorMan/StorMan.desktop ~/Desktop
            chmod 755 ~/Desktop/StorMan.desktop
        fi

        # Cleanup favorites list
        ${gsettings_preamble} gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'org.gnome.Nautilus.desktop', 'vlc.desktop']"

        # Only one workspcae
        ${gsettings_preamble} gsettings set org.gnome.desktop.wm.preferences num-workspaces 1

        # Show desktop icons
        ${gsettings_preamble} gsettings set org.gnome.desktop.background show-desktop-icons true
    fi

    # * Auto log-out, monitor sleep, screensaver disabled
    ${gsettings_preamble} gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    ${gsettings_preamble} gsettings set org.gnome.desktop.session idle-delay 0
    ${gsettings_preamble} gsettings set org.gnome.desktop.screensaver lock-enabled false
}

reset_chrome34_prefs() {
    trap die_with_error ERR

    # Reset Google Chrome prefs
    mkdir -p ~/.config
    pushd . > /dev/null
    cd ~/.config
    rm -rf google-chrome
    tar xvfz ${orchid_install_dir}/google-chrome-prefs.tar.gz
    popd > /dev/null

    # * Install/verify Oh No You Didn't
    if [[ ! -d $HOME/.config/google-chrome/Default/Extensions/acdablfhjbhkjbcifldncdkmlophfgda/1.0.2_0 ]]; then
        die_with_error "Oh No You Didn't! Extension Missing"
    fi

    # * Clear Chrome cache
    rm -rf ~/.cache/google-chrome/
    rm -f ~/.config/google-chrome/Default/History* 
    rm -f ~/.config/google-chrome/Default/Login*
    rm -f ~/.config/google-chrome/Default/Archived*
    rm -f ~/.config/google-chrome/Default/Cookies* 
    rm -f ~/.config/google-chrome/Default/Current*
    rm -f ~/.config/google-chrome/Default/Last* 
    rm -f ~/.config/google-chrome/Default/Local\ Storage/* 
    rm -rf ~/.config/google-chrome/Default/Application\ Cache/* 
    rm -f ~/.config/google-chrome/Default/Top* 
    rm -f ~/.config/google-chrome/Default/Visited*

    # * Set Chrome home page and disable popup blocker
    tmpfile=$( mktemp )
    prefs="$HOME/.config/google-chrome/Default/Preferences"
    cp $prefs $tmpfile
    cat $tmpfile | jq '.profile.default_content_settings.popups = 1 | .session.startup_urls = [ "http://localhost/" ]' > $prefs
    rm -f $tmpfile

    # Make Chrome start on login.
    mkdir -p ~/.config/autostart
    cp /usr/share/applications/google-chrome.desktop ~/.config/autostart/
}

reset_firefox_esr_prefs() {
    trap die_with_error ERR

    sudo sed -i '/.*("browser.startup.homepage", ".*");/d' /etc/firefox-esr/firefox-esr.js
    sudo sed -i '/.*("browser.startup.homepage_override.mstone", ".*");/d' /etc/firefox-esr/firefox-esr.js
    sudo sed -i '/.*("dom.disable_open_during_load",  .*);/d' /etc/firefox-esr/firefox-esr.js

    echo 'lockPref("browser.startup.homepage", "http://localhost");' | sudo tee -a /etc/firefox-esr/firefox-esr.js > /dev/null
    echo 'lockPref("browser.startup.homepage_override.mstone", "ignore");' | sudo tee -a /etc/firefox-esr/firefox-esr.js > /dev/null
    echo 'lockPref("dom.disable_open_during_load",  false);' | sudo tee -a /etc/firefox-esr/firefox-esr.js > /dev/null

    # Make Firefox ESR start on login.
    #mkdir -p ~/.config/autostart
    #cp /usr/share/applications/firefox-esr.desktop ~/.config/autostart/
}

firefox_esr_start_login() {
    trap die_with_error ERR

    # Make Firefox ESR start on login.
    mkdir -p ~/.config/autostart
    cp /usr/share/applications/firefox-esr.desktop ~/.config/autostart/
}

setup_desktop() {
    trap die_with_error ERR

    mkdir -p ~/Desktop
    chmod 755 ~/Desktop
    if [[ $distro_id == "Ubuntu" ]]; then
        rm -f ~/Desktop/*.pdf
    fi

    cp ${orchid_install_dir}/"Orchid Core VMS User Guide.pdf" ~/Desktop
    cp ${orchid_install_dir}/"Orchid Core VMS Administrator Guide.pdf" ~/Desktop
    cp ${orchid_install_dir}/"Orchid Core VMS Quick Start Key.pdf" ~/Desktop

    if /bin/ls ${script_dir}/agreements/*.pdf &> /dev/null; then
        cp  ${script_dir}/agreements/*.pdf ~/Desktop
    fi

    rm -f ~/Downloads/*
    rm -f ~/*.jpg ~/*.mkv ~/*.deb
    chmod 444 ~/Desktop/*.pdf
    chmod 555 ~/Desktop

    # Set background
    mkdir -p ~/.orchid
    cp ${orchid_install_dir}/orchid_background.jpg ~/.orchid

    if [[ $distro_id == "Ubuntu" ]]; then
        ${gsettings_preamble} gsettings set org.gnome.settings-daemon.plugins.background active true
    fi

    ${gsettings_preamble} gsettings set org.gnome.desktop.background picture-options stretched

    if [[ $distro_id == "Ubuntu" ]]; then
        ${gsettings_preamble} gsettings set org.gnome.desktop.background draw-background false 
    fi

    ${gsettings_preamble} gsettings set org.gnome.desktop.background picture-uri "file:///home/orchid/.orchid/orchid_background.jpg"    

    if [[ $distro_id == "Ubuntu" ]]; then
        ${gsettings_preamble} gsettings set org.gnome.desktop.background draw-background true
    fi
}

verify_steelfin_os
configure_gsettings
set_default_applications
lock_down_desktop_environment
if [[ $default_browser == "google-chrome.desktop" ]]; then
    reset_chrome34_prefs
    reset_firefox_esr_prefs
elif [[ $default_browser == "firefox-esr.desktop" ]]; then
    reset_firefox_esr_prefs
    firefox_esr_start_login
fi
setup_desktop
show_message "SUCCESSFULLY COMPLETED!"
