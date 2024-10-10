function fs.ramdrv {

  # dependencies
  ## bools.v
  ## cmd_*.v 
  ## json.f 

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
  if [[ ! -z ${_gid} ]]; then
    _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.validate.gid |+= '${true})
  else
    $(( _error_count++ ))
    _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.validate.gid |+= '${false})
  fi


  if [[ -z ${_uid} ]]; then
    _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.validate.uid |+= '${true})
  else
    $(( _error_count++ ))
    _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.validate.uid |+= '${false})
  fi


  if [[ -z ${_mount} ]]; then
    _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.validate.mount |+= '${true})
  else
    $(( _error_count++ ))
    _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.validate.mount |+= '${false})
  fi

  ## create mount point
  if [[ ! -d ${_mount} && ${_error_count} == 0 ]]; then 
    ${cmd_mkdir} ${mount} 2>&1 /dev/null 
    if [[ ${?} == ${exitok} ]]: then
      _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.ramfs.mkdir |+= '${true})
    else
      $(( _error_count++ ))
      _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.ramfs.mkdir |+= '${false})
    fi


    ## set permissions
    ${cmd_chown} ${_uid}:${_gid} ${_mount} 2>&1 /dev/null
    if [[ ${?} == ${exitok} ]]: then
      _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.ramfs.chown |+= '${true})
    else
      $(( _error_count++ ))
      _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.ramfs.chown |+= '${false})
    fi


    ## mount
    ${cmd_mount} -t ramfs -o size=1g  ramfsmount ${_mount} 2>&1 /dev/null
    if [[ ${?} == ${exitok} ]]; then
      _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.ramfs.mount |+= '${true})
    else
      $(( _error_count++ ))
      _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.ramfs.mount |+= '${false})
    fi

  fi

  ## validate json
  if [[ ! $( json.validate ${_json} ) == ${exitok} ]]; then
    $(( _error_count++ ))
    _json="{}"
  fi

  ## set exit code
  [[ ${_error_count} == 0 ]] && _exit_code=${exitok}

  ## exit
  ${cmd_echo} ${_json} | ${cmd_jq} -c
  exit ${_exit_code}

  
} 