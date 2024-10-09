function osquery.list {

  # variables
  local _filter=${false}
  local _filter_type=
  local _filter_string=
  local _json="{}"
  local _json_output="{}"
  local _exit_code=${exit_crit}
  local _sane=${false}
  local _table=

  # main
  ## read args
  while [[ ${1} != "" ]]; do
    case ${1} in
      --filter | --f )
        shift
        _filter_string=${1}
      ;;
      --table | --t )
        shift
        _table=$(text.lcase ${1})
      ;; 
      * | -h | --help )
        ${cmd_echo} need help dialog
        exit ${exit_crit}
      ;;
    esac

    shift
  done
  
  ## select table
  case ${_table} in
    file | files )
      _filter=${true}
      _filter_type=path
      _type=file

      # check sanity
      if [[                         \
          ${_filter}             && \
          ! -z ${filter_type}    && \   
      ]]                            \
      then
        _sane=${true}
      fi
    ;;
    listening_ports | listening_port )
      _filter=${false}
      _filter_type=
      _table=listening_ports

      # check sanity
      if [[                         \
          ! ${_filter}           && \
          -z ${filter_type}      && \   
      ]]                            \
      then
        _sane=${true}
      fi
    ;;
    processes | process )
      _filter=${false}
      _filter_type=
      _table=process 

      # check sanity
      if [[                         \
          ! ${_filter}           && \
          -z ${filter_type}      && \   
      ]]                            \
      then
        _sane=${true}
      fi
    ;;
    rpm_packages | rpm_package )
      _filter=${false}
      _filter_type=
      _table=rpm_packages

      # check sanity
      if [[                         \
          ! ${_filter}           && \
          -z ${filter_type}      && \   
      ]]                            \
      then
        _sane=${true}
      fi
    ;;
    startup_items | startup_item )
      _filter=${false}
      _filter_type=
      _table=user 

      # check sanity
      if [[                         \
          ! ${_filter}           && \
          -z ${filter_type}      && \   
      ]]                            \
      then
        _sane=${true}
      fi
    ;;
    users | user )
      _filter=${false}
      _filter_type=
      _table=user 

      # check sanity
      if [[                         \
          ! ${_filter}           && \
          -z ${filter_type}      && \   
      ]]                            \
      then
        _sane=${true}
      fi
    ;;
    * )
      _json_output="{}"
      _sane=${false}
    ;;
esac

## filter enabled
if [[ ${_filter == ${true} && ${_sane} ]]; then
  _json_output=$( ${cmd_osqueryi} --json "select * from ${_table} where ${_filter_type}=${_filter_string}" )
  ${cmd_jq} ${_json_output} 2&>1 /dev/null   && _exit_code=${exit_ok} || _json_output="{}"

## filter disabled
elif if [[ ${_filter == ${false} && ${_sane} ]]; then
  _json_output=$( ${cmd_osqueryi} --json "select * from ${_table}" ) 

# validate json schema
${cmd_jq} ${_json_output} 2&>1 /dev/null   && _exit_code=${exit_ok} || _json_output="{}"
fi

## write status to json
_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.exit_code |+= '${_exit_code})

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.filter.enable |+= '${_filter} )

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.filter.string |+= '${_filter_string} )

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.filter.type |+= '${_filter_type} )

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.path |+= '${_path} )

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.table |+= '${_table} )

## write output to json
_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.data |+= '"${_json_output}" )

# output json and exit
${cmd_echo} ${_json}
exit ${_exit_code}