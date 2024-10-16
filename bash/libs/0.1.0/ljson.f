function json.validate {
  # dependancies
  ## bools.v
  ## cmd*.v

  # variables 
  local _json=${1}

  # main
  ${cmd_jq} ${_json} 2&>1 /dev/null
  if [[ ${?} == ${exitok} ]]; then
    ${cmd_echo} ${true}
    exit ${exitok}
  else
    ${cmd_echo} ${false}
    exit ${exitcrit}
  fi
}
