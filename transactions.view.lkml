view: transactions {

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

  measure: total_income_amount{
    value_format_name:  usd
    type: sum
    sql: ${amount_unsigned_raw} *${obfuscate_amount} ;;
    filters: {
      field: transaction_type
      value: "credit"
    }
    drill_fields: [summary*]
  }

  measure: total_spend_amount {
    value_format_name:  usd
    type: sum
    sql: ${amount_unsigned_raw} *${obfuscate_amount} ;;
    filters: {
      field: transaction_type
      value: "debit"
    }
    drill_fields: [summary*]
  }

  measure: total_income_amount_drill{
    hidden: yes
    value_format_name:  usd
    type: sum
    sql: ${amount_unsigned_raw} *${obfuscate_amount} ;;
    filters: {
      field: transaction_type
      value: "credit"
    }
    drill_fields: [transactions*]
  }

  measure: total_spend_amount_drill {
    hidden: yes
    value_format_name:  usd
    type: sum
    sql: ${amount_unsigned_raw} *${obfuscate_amount} ;;
    filters: {
      field: transaction_type
      value: "debit"
    }
    drill_fields: [transactions*]
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
    hidden: yes
    type: number
    sql: date_diff({% date_end date_date %},{% date_start date_date %},day);;
  }

  measure: count_of_months {
    hidden: yes
    type: number
    sql: date_diff({% date_end date_date %},{% date_start date_date %},month);;
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
      year,
      week_of_year,
      month_num,
      day_of_week,
      day_of_week_index,
      day_of_year
    ]
    datatype: date
    convert_tz: no
    sql: ${TABLE}.date ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
    link: {
      label: "View Merchant Transactions in Mint"
      icon_url: "https://mint.intuit.com/favicon.ico"
      url: "https://mint.intuit.com/transaction.event#location:%7B%22query%22%3A%22description%3A%20{{value | uri_encode }}%22%2C%22offset%22%3A0%2C%22typeFilter%22%3A%22cash%22%2C%22typeSort%22%3A8%7D"
    }
    link: {
      label: "View Merchant Lookup Dashboard"
      icon_url: "http://looker.com/favicon.ico"
      url: "/dashboards/2?Merchant={{value | uri_encode }}"
    }
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
    label: "Full Transaction Code"
    type: string
    sql: ${TABLE}.original_description ;;
  }

  dimension: transaction_type {
    label: "Credit or Debit"
    type: string
    sql: ${TABLE}.transaction_type ;;
  }

  measure: average_transaction_amount {
    type: average
    sql: ${amount_signed}  ;;
    drill_fields: [transactions*]
    value_format_name: usd
  }

  measure: average_transaction_spend_amount {
    hidden: yes
    type: average
    sql: ${amount_signed} ;;
    drill_fields: [transactions*]
    filters: {
      field: transaction_type
      value: "debit"
    }
    value_format_name: usd
  }

  measure: average_monthly_spend_amount {
    type: number
    sql: ${total_spend_amount}/ ${count_of_months};;
    drill_fields: [transactions*]
    value_format_name: usd
  }

  measure: average_monthly_amount {
    description: "Intended for use with a pivot on credit/debit"
    type: number
    sql: ${total_amount}/ ${count_of_months};;
    drill_fields: [transactions*]
    value_format_name: usd
  }


  measure: count {
    type: count
#     approximate_threshold: 100000
    drill_fields: [transactions*]
  }


  dimension: is_expensable {
    type: yesno
    sql:  ${labels} = 'expensable' ;;
  }

  dimension: is_transfer {
    type: yesno
    sql: ${category_raw} in
          ('transfer',
           'transfer for cash spending',
          'withdrawal',
          'cash & atm',
          'financial','hide from budgets & trends','credit card payment')
      ;;
  }




  dimension: is_before_wtd {
    description: "Filter this on 'yes' to compare to same period in previous weeks"
    group_label: "1) Transaction Date"
    type: yesno
    sql:
      (EXTRACT(DOW FROM ${date_raw}) < EXTRACT(DOW FROM CURRENT_DATE)
        OR
        (
          EXTRACT(DOW FROM ${date_raw}) = EXTRACT(DOW FROM CURRENT_DATE) /*AND
          EXTRACT(HOUR FROM ${date_raw}) < EXTRACT(HOUR FROM CURRENT_DATE)*/
        )
        OR
        (
          EXTRACT(DOW FROM ${date_raw}) = EXTRACT(DOW FROM CURRENT_DATE) /*AND
          EXTRACT(HOUR FROM ${date_raw}) <= EXTRACT(HOUR FROM CURRENT_DATE) AND
          EXTRACT(MINUTE FROM ${date_raw}) < EXTRACT(MINUTE FROM CURRENT_DATE)*/
        )
      );;
  }

  dimension: is_before_mtd {
    description: "Filter this on 'yes' to compare to same period in previous months"
    group_label: "1) Transaction Date"
    type: yesno
    sql:
      (EXTRACT(DAY FROM ${date_raw}) < EXTRACT(DAY FROM CURRENT_DATE)
        OR
        (
          EXTRACT(DAY FROM ${date_raw}) = EXTRACT(DAY FROM CURRENT_DATE) /*AND
          EXTRACT(HOUR FROM ${date_raw}) < EXTRACT(HOUR FROM CURRENT_DATE)*/
        )
        OR
        (
          EXTRACT(DAY FROM ${date_raw}) = EXTRACT(DAY FROM CURRENT_DATE) /*AND
          EXTRACT(HOUR FROM ${date_raw}) <= EXTRACT(HOUR FROM CURRENT_DATE) AND
          EXTRACT(MINUTE FROM ${date_raw}) < EXTRACT(MINUTE FROM CURRENT_DATE)*/
        )
      );;
  }

  dimension: is_before_ytd {
    description: "Filter this on 'yes' to compare to same period in previous years"
    group_label: "1) Transaction Date"
    type: yesno
    sql:
      (EXTRACT(DOY FROM ${date_raw}) < EXTRACT(DOY FROM CURRENT_DATE)
        OR
        (
          EXTRACT(DOY FROM ${date_raw}) = EXTRACT(DOY FROM CURRENT_DATE) /*AND
          EXTRACT(HOUR FROM ${date_raw}) < EXTRACT(HOUR FROM CURRENT_DATE)*/
        )
        OR
        (
          EXTRACT(DOY FROM ${date_raw}) = EXTRACT(DOY FROM CURRENT_DATE) /*AND
          EXTRACT(HOUR FROM ${date_raw}) <= EXTRACT(HOUR FROM CURRENT_DATE) AND
          EXTRACT(MINUTE FROM ${date_raw}) < EXTRACT(MINUTE FROM CURRENT_DATE)*/
        )
      );;
  }

  set: transactions {
    fields: [date_date,description,transaction_type,original_description,total_amount,account_name, total_income_amount, total_spend_amount]
  }
  set: summary {
    fields: [account_name,total_income_amount_drill,total_spend_amount_drill]
  }


}
