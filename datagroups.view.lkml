  datagroup: calendar {
    max_cache_age: "876,000 hours" #100 years
  }

  datagroup: manual_load {
    sql_trigger: select max(date) from transactions ;;
  }
