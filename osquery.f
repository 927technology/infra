lfunction osquery.list {

  # variables
  local _filter=${false}
  local _filter_type=
  local _json="{}"
  local _json_output="{}"
  local _exit_code=${exit_crit}
  local _path=
  local _sane=${false}
  local _table=

  # main

  ## read args
  while [[ ${1} != "" ]]; do
    case ${1} in
      --path | --p )
        shift
        _path=${1}
        
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
    file )
      _filter=${true}
      _filter_type=path
      _type=file

      # check sanity

      if [[                         \
          ${_filter} == ${true}  && \
          ! -z ${filter_type}    && \   
      ]]                            \
      then
        _sane=${true}

      else

      fi
    ;;
    * )

    ;;
esac




## filter enabled
if [[ ${filter == ${true} && ${_sane} ]]; then
  _json_output=$(${cmd_osqueryi} --json "select * from ${type} where ${_filter_type}=${_path}")
  ${cmd_jq} ${_json_output} 2&>1 /dev/null   && _exit_code=${exit_ok} || _json_output="{}"

## filter disabled
elif if [[ ${filter == ${false} && ${_sane} ]]; then
  _json_output=$(${cmd_osqueryi} --json "select * from ${type}") 

${cmd_jq} ${_json_output} 2&>1 /dev/null   && _exit_code=${exit_ok} || _json_output="{}"
fi




## write status to json
_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.exit_code |+= '${_exit_code})

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.filter |+= '${_filter})

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.filter_type |+= '${_filter_type})

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.path |+= '${_path})

_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.status.args.table |+= '${_table})

## write output to json
_json=$( ${cmd_echo} ${_json}  | ${cmd_jq} '.data |+= '"${_json_output}")

${cmd_echo} ${_json}
exit ${_exit_code}