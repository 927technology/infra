function osquery.list {
  _filter=${false}
  _filter_type=
  _json="{}"
  _path=
  _sane=${false}
  _type=

  # read args
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
  
  # select table
  case ${_table} in
    file )
      filter=${true}
      type=file
    ;;
    * )

    ;;
esac

if [[ ${filter == ${true}; then
  _json=$(${cmd_osqueryi} --json "select * from ${type} where path=${_path}")
else
  _json=$(${cmd_osqueryi} --json "select * from ${type}")
fi