connection: "personal_bq"

include: "*.view.lkml"         # include all views in this project
# include: "calendar.view.lkml"
explore: mint_base_explore {
  extension: required
  from: transactions
  view_name: transactions
  view_label: "Transactions"
  description: "Filtered to normal expenses by default"
  always_filter: {
    filters: {
      field: transactions.obfuscate
      value: "yes"
      }
#       filters: {
#         field: transactions.is_transfer
#         value: "No"
#       }
#       filters: {
#         field: transactions.is_expensable
#         value: "No"
#       }
#       filters: {
#         field: transactions.transaction_type
#         value: "debit"
#       }

    }
  join: merchant_facts {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${transactions.description} = ${merchant_facts.merchant}  ;;
  }
  join: category_facts {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${transactions.category} = ${category_facts.category}  ;;
  }
  # join: budget {
  #   type: left_outer
  #   sql_on: ${mint_data.date_month}=${budget.budget_month} ;;
  #   relationship: many_to_many
  # }
}
