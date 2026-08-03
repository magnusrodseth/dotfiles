#!/usr/bin/env zsh
# Interactive Pi sessions start offline.
#
# PI_OFFLINE=1 suppresses Pi's startup version check, package-update check and
# install telemetry, which is what makes launching feel instant. Package
# freshness is owned by the scheduled updater instead (see
# Library/LaunchAgents/com.magnusrodseth.pi-extension-update.plist), so nothing
# goes stale as a result.
#
# Two classes of invocation deliberately keep normal network semantics:
#   - explicit maintenance subcommands, which exist to talk to the network;
#   - print/JSON/RPC modes, which are non-interactive and have no startup UI to
#     speed up in the first place.
#
# The scheduled updater calls the binary by absolute path, so it never reaches
# this function.

pi() {
	emulate -L zsh

	local bin=${commands[pi]}
	if [[ -z $bin ]]; then
		print -u2 "pi: command not found"
		return 127
	fi

	# Explicit maintenance subcommands: always online.
	case $1 in
	install | remove | uninstall | update | list | config | auth)
		"$bin" "$@"
		return $?
		;;
	esac

	local i
	for ((i = 1; i <= $#; i++)); do
		case ${argv[i]} in
		-p | --print | -v | --version | -h | --help | --list-models | --export)
			"$bin" "$@"
			return $?
			;;
		--mode)
			# No spaces inside the glob group: unlike `case`, whitespace in a
			# [[ ]] pattern alternation is matched literally.
			if [[ ${argv[i + 1]} == (json|rpc) ]]; then
				"$bin" "$@"
				return $?
			fi
			;;
		--mode=*)
			if [[ ${argv[i]#--mode=} == (json|rpc) ]]; then
				"$bin" "$@"
				return $?
			fi
			;;
		esac
	done

	PI_OFFLINE=1 "$bin" "$@"
}
