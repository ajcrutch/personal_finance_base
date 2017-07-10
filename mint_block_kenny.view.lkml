include: "mint_base.view.lkml"

explore: mint_block_kenny {
  extends: [mint_base_explore]
  extension: required
  from: mint_block_kenny
}

# Didn't end up needing a calendar table!  Good thing, it's complex!
# explore: mint_block_kenny {
#   extension: required
#   from: calendar
#   view_name: calendar
#   join: mint_block_kenny {
#     type: left_outer
#     sql_on: ${mint_block_kenny.date_raw}=${calendar.date_raw} ;;
#     relationship: one_to_many
#   }
# }

view: mint_block_kenny {
  extends: [mint_base_view]
 ##CHANGE TO ACTUAL SQL TABLE NAME##
  sql_table_name: personal_finance.mint_kenny ;;

  dimension: category {
    type: string
    sql: ${category_raw} ;;
  }

}
