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

view: mint_base_view {

dimension: pkey {
  hidden: yes
  primary_key: yes
  sql: concat(cast(${date_raw} as string),cast(${amount_unsigned} as string),${account_name},${original_description}) ;;
}

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension: amount_unsigned_raw {
    type: number
    hidden: yes
    sql: ${TABLE}.amount;;
  }

  dimension: amount_signed_raw {
    hidden: yes
    type: number
    sql: case when ${transaction_type}='credit' then ${amount_unsigned_raw}
              when ${transaction_type}='debit' then ${amount_unsigned_raw}*-1
              else null end ;;
  }

  dimension: amount_unsigned {
    label: "Amount"
    description: "Debit and credit amounts are both positive. "
    type: number
    value_format_name: usd
    sql: ${amount_unsigned_raw} * ${obfuscate_amount};;
  }


  dimension: amount_signed {
    label: "Amount Signed"
    description: "Debit amounts are negative"
    type: number
    value_format_name:  usd
    sql: case when ${transaction_type}='credit' then ${amount_unsigned}
              when ${transaction_type}='debit' then ${amount_unsigned}*-1
              else null end ;;
  }

  measure: credits {
    value_format_name:  usd
    type: sum
    sql: ${amount_unsigned_raw} *${obfuscate_amount} ;;
    filters: {
      field: transaction_type
      value: "credit"
    }
  }

  measure: debits {
    value_format_name:  usd
    type: sum
    sql: ${amount_unsigned_raw} *${obfuscate_amount} ;;
    filters: {
      field: transaction_type
      value: "debit"
    }
  }

  dimension: amount_tier {
    type:  tier
    style: integer
    sql: ${amount_signed} ;;
    tiers: [-2000,-1500,-1000,-750,-500,-250,0,250,500,750,1000,1500,2000]
  }

  dimension: is_expensive {
    type: yesno
    sql: ${amount_signed}<-1000 ;;
  }

  measure:count_expensive {
    type: count
    filters: {
      field: is_expensive
      value: "yes"
    }
  }

  measure: percent_expensive {
    value_format: "0.00%"
    type: number
    sql: 1.0*${count_expensive}/nullif(${count},0) ;;
    drill_fields: [transactions*]
  }

  measure: total_amount {
    value_format_name:  usd
    type: sum
    sql: ${amount_signed_raw} *${obfuscate_amount} ;;
    drill_fields: [transactions*]
  }

  measure: count_of_days {
    type: number
    sql: date_diff({% date_end date_date %},{% date_start date_date %},day);;
  }

  measure: count_of_days_not_work {
    type: number
    sql: date_diff(max(${date_date}),min(${date_date}),day);;
  }

  measure: count_of_days_not_as_good {
    type: count_distinct
    sql: ${date_date};;
  }

  measure: average_daily_amount {
    value_format_name:  usd
    type: number
    sql: ${total_amount}/nullif(${count_of_days},0);;
  }

  filter: obfuscate {
    type: string
    suggestions: ["yes","no"]
  }

  dimension: obfuscate_amount {
    hidden: yes
    type: number
#     sql: case when {% condition obfuscate %}  then rand()*2 else 1 end ;;
    sql: if( {% condition obfuscate %} 'yes' {% endcondition %} , rand()*2,1) ;;
  }

  measure: total_amount_unsigned {
    label: "Total Amount Unsigned"
    value_format_name:  usd
    type: sum
    sql: ${amount_unsigned_raw} *${obfuscate_amount} ;;
    drill_fields: [transactions*]
  }

  dimension: category_raw {
    type: string
#     hidden: yes
    sql: ${TABLE}.category ;;
  }

  dimension_group: date {
#     hidden: yes
    label: ""
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    datatype: date
    convert_tz: no
    sql: ${TABLE}.date ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: labels {
    type: string
    sql: ${TABLE}.labels ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}.notes ;;
  }

  dimension: original_description {
    type: string
    sql: ${TABLE}.original_description ;;
  }

  dimension: transaction_type {
    label: "Credit or Debit"
    type: string
    sql: ${TABLE}.transaction_type ;;
  }

  measure: count {
    type: count
#     approximate_threshold: 100000
    drill_fields: [transactions*]
  }

  set: transactions {
    fields: [date_date,description,transaction_type,total_amount,account_name]
  }


}
