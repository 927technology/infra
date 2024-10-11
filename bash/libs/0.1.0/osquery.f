function osquery.list {
  # dependencies 
  ## json.f

  # variables
  local _error_count=0
  local _json="{}"
  local _json_output="{}"
  local _exit_code=${exitcrit}
  local _path=
  local _query=
  local _table=

  # main
  ## read args
  while [[ ${1} != "" ]]; do
    case ${1} in
      --filter | --f )
        shift
        _filter_string=${1}
      ;;
      --path | --0 )
        shift
        _path=${1}
        [[ ! -d ${path} ]] && _path=
      ;; 
      --table | --t )
        shift
        _table=${1}
      ;;
      * | -h | --help )
        ${cmd_echo} need help dialog
        exit ${exitcrit}
      ;;
    esac

    shift
  done
  
  ## select table
  case ${_table} in
    disk_usage )
      _query="SELECT path, type, ROUND((blocks_available * blocks_size * 10e-10), 2) AS free_gb, ROUND ((blocks_available * 1.0 / blocks * 1.0) * 100, 2) AS free_perc FROM mounts;"

    ;;
    file | files )
      _query="select * from files where path=${_path};"
    ;;
    listening_ports | listening_port )
      _query="select * from listening_ports:"
    ;;
    processes | process )
      _query="select * from processes;"
    ;;
    rpm_packages | rpm_package)
      _query="select * from rpm_packages;"
    ;;
    startup_items | startup_item )
      _query="select * from startup_items;"
    ;;
    users | user )
      _query="select * from users;"
    ;;
    * )
      _query=
    ;;
esac

  ## get output
  if [[ ! -z ${_query}]]: then
    _json_output=$( ${cmd_osqueryi} --json "#{_query}" )
  else
    _json_output="{}"
  fi
 

  # validate json schema
  $( json.validate ${_json_output} ) && $(( _error_count++ )) || _json_output="{}"
fi

  ## write status to json
  _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.exit_code |+= '${_exit_code})


  _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.path |+= '${_path} )

  _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.table |+= '${_table} )

  ## write output to json
  _json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.data |+= '"${_json_output}" )

  $( json.validate ${_json} ) && $(( _error_count++ ))  || _json="{}"
fi

  # set exit code
  [[ ${_error_count} == 0 ]] && exit_code = ${exitok}
  # output json and exit
  ${cmd_echo} ${_json}
  exit ${_exit_code}
