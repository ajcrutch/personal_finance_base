connection: "personal_bq"

include: "*.view.lkml"         # include all views in this project
# include: "calendar.view.lkml"
explore: mint_base_explore {
  extension: required
  from: mint_base_view
  view_name: mint_data
  always_filter: {
    filters: {
      field: mint_data.obfuscate
      value: "yes"
    }
  }
  # join: budget {
  #   type: left_outer
  #   sql_on: ${mint_data.date_month}=${budget.budget_month} ;;
  #   relationship: many_to_many
  # }
}
