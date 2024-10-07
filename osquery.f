lfunction osquery.list {

  # variables
  local _filter=${false}
  local _filter_type=
  local _json="{}"
  local _exit_code=${exit_crit}
  local _path=
  local _sane=${false}
  local _type=

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
  _json=$(${cmd_osqueryi} --json "select * from ${type} where ${_filter_type}=${_path}")
  ${cmd_jq} ${_json} 2&>1 /dev/null   && _exit_code=${exit_ok} || _json="{}"

## filter disabled
elif if [[ ${filter == ${false} && ${_sane} ]]; then
  _json=$(${cmd_osqueryi} --json "select * from ${type}") 

${cmd_jq} ${_json} 2&>1 /dev/null   && _exit_code=${exit_ok} || _json="{}"
fi


${cmd_echo} ${_json}
exit ${_exit_code}