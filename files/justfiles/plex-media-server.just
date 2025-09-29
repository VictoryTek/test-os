plex-media-server.just for Fedora Atomic  SecureBlue
# Usage
#   ujust -f plex-media-server.just install-pms   # layer Plex (reboot required)
#   ujust -f plex-media-server.just remove-pms    # remove Plex (reboot required)
# If you place this file as `justfile` you can omit -f.

PLEX_PACKAGE = plexmediaserver
PLEX_REPO_URL = httpsdownloads.plex.tvreporpmplex.repo

set shell = [usrbinbash, -eu, -o, pipefail, -c]

# Add Plex repo if missing (private)
_repo
	if [ ! -f etcyum.repos.dplex.repo ]; then 
		echo Adding Plex repo; 
		sudo curl -fsSL {{PLEX_REPO_URL}} -o etcyum.repos.dplex.repo; 
	else 
		echo Plex repo already present; 
	fi

# Install (layer) Plex Media Server via rpm-ostree
install-pms _repo
	if ! command -v rpm-ostree devnull 2&1; then echo rpm-ostree not found (this expects Fedora Atomic) &2; exit 1; fi
	if rpm -q {{PLEX_PACKAGE}} devnull 2&1; then echo {{PLEX_PACKAGE}} already installed; exit 0; fi
	echo Layering {{PLEX_PACKAGE}}...
	sudo rpm-ostree install {{PLEX_PACKAGE}}
	echo Install staged. Reboot to finalize (e.g. sudo systemctl reboot)

# Remove (un-layer) Plex Media Server
remove-pms
	if ! command -v rpm-ostree devnull 2&1; then echo rpm-ostree not found &2; exit 1; fi
	if ! rpm -q {{PLEX_PACKAGE}} devnull 2&1; then echo {{PLEX_PACKAGE}} not installed; exit 0; fi
	echo Removing {{PLEX_PACKAGE}} layering...
	sudo rpm-ostree uninstall {{PLEX_PACKAGE}}
	echo Removal staged. Reboot to finalize (e.g. sudo systemctl reboot)
