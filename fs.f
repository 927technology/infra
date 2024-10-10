function fs.ramdrv {

  # variables 
  local _error_count=0
  local _exit_code=${exitcrit}
  local _gid=${cmd_whoami}
  local _json="{}"
  local _mount=
  local _sane=${false}
  local _uid=${cmd_whoami}

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
  [[ -z ${_gid} ]]   && $(( _error_count++ ))
  [[ -z ${_uid} ]]   && $(( _error_count++ ))
  [[ -z ${_mount} ]] && $(( _error_count++ ))

  ## create mount point
  if [[ ! -d ${_mount} && ${_error_count} == 0 ]]; then 
    ${cmd_mkdir} ${mount} 2>&1 /dev/null 
    if [[ ${?} ]]: then
      $(( _error_count++ ))









    ${cmd_chown} ${_uid}:${_gid} ${_mount} 2>&1 /dev/null || $(( _error_count++ ))  

    ${cmd_mount} -t ramfs -o size=1g  ramfsmount ${_mount} 2>&1 /dev/null || $(( _error_count++ ))

  fi

  [[ ${_error_count} == 0 ]] && _exit_code=${exitok}

  
}