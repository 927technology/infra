#!/bin/bash

# variables
local _exitcrit=2
local _exitok=0
local _exitunkn=3
local _exitwarn=1

local _count=0
local _crit=${1}
local _crit_count=0
local _exit_code=${_exitunkn}
local _exit_string=
local _percent=
local _source=
local _warn=${1}
local _warn_count=0

# main
for line in $( df --output=source,pcent ); do
  # scrape percent
  _percent=$( echo ${line} | awk '{print $2}' | sed 's/%//g' )

  # scrape source
  _source=$( echo ${line} | awk '{print $1}' )

  # add newline to exit string on all lines after the 1st
  [[ ${_count} > 0 ]] && _exit_string=+"\n"

  

  if [[ ${_percent} >= ${_crit} ]]; then
    $(( _crit_count++ ))
    _exit_string=+"(CRITICAL) ${_percent}% ${_source}"
    
  elif [[ ${_percent} >= ${_warn} ]]; then
    $(( _warn_count++ ))
    _exit_string=+"(WARNING) ${_percent}% ${_source}"
  fi
  

  # add newline to exit string on all lines after the 1st
  [[ ${_count} > 0 ]] && _exit_string=+"\n"

  $(( _count++ ))

done

# determine exit code
if [[ ${_crit_count} > 0 ]]; then
  _exit_code=${_exitcrit}
elif [[ ${_warn_count} > 0 ]]; then
  _exit_code=${_exitwarn}
else
  _exit_code=${_exitok}
fi

echo ${_exit_string}
exit ${_exit_code}