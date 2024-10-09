function fs.ramdrv {

  # variables 
  local _gid=
  local _mount=
  local _sane=${false}
  local _uid=

  # main
  ## parse args
  while ${1} != ""; then
    case ${1} in
      --group | -g )
        shift
        _gid=${1}
      ;;
      --mount | -m )
        shift
        _mount=${1}
      ;;

      --user | -u )
        shift
        _uid=${1}
      ;;
    esac
    shift
  esac

  ## validate 
  [[ -z ${_gid} ]] && _gid=${cmd_whoami}
  [[ -z ${_uid} ]] && _gid=${cmd_whoami}
  [[ -z ${_mount} ]] && _gid=${cmd_whoami}

  ## create mount point
  [[ ! -d ${_mount} ]] && ${cmd_mkdir} ${mount}

  ${cmd_chown} ${_uid}:${_gid} ${_mount}
  ${cmd_mount} -t ramfs -o size=1g ramfsmount ${_mount}
}