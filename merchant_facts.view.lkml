view: merchant_facts {
  label: "Merchant"

  derived_table: {
    datagroup_trigger: manual_load
    sql:
      SELECT
         transactions.description
        ,SUM(transactions.amount)                                              AS total_amount
        ,COUNT(DISTINCT concat(cast(date as string),cast(amount as string),account_name,original_description))
                                                                     AS volume
        ,AVG(transactions.amount)                                              AS avg_amount
        ,MAX(transactions.amount)                                              AS max_amount
        ,COUNT(DISTINCT concat(cast(date as string),cast(amount as string),account_name,original_description)
            )*1.0/NULLIF(date_diff(MAX(transactions.date),MIN(transactions.date),day),0)              AS frequency
        ,MIN(transactions.date)                                                AS first_transaction
        ,MAX(transactions.date)                                                AS last_transaction
        ,date_diff(MAX(transactions.date),MIN(transactions.date),day)                                  AS duration
        ,ROW_NUMBER() OVER (ORDER BY SUM(transactions.amount) DESC)            AS rank_by_amount
        ,ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT concat(cast(date as string),cast(amount as string),account_name,original_description)
            ) DESC)                                               AS rank_by_number
        ,ROW_NUMBER() OVER (ORDER BY AVG(transactions.amount) DESC)            AS rank_by_avg
      FROM
        mint_andy transactions
      WHERE
        1=1
        AND {% condition transactions.transaction_type %}   transactions.transaction_type     {% endcondition %}
        AND {% condition transactions.category %}           transactions.category             {% endcondition %}
        AND {% condition transactions.notes %}              transactions.notes                {% endcondition %}
        AND {% condition transactions.labels %}             transactions.labels               {% endcondition %}
        AND {% condition transactions.description %}        transactions.description          {% endcondition %}
        AND {% condition transactions.account_name %}       transactions.account_name         {% endcondition %}
        AND {% condition transactions.date_date %}          transactions.date                 {% endcondition %}
        AND {% condition transactions.date_month %}         transactions.date                 {% endcondition %}
        AND {% condition transactions.date_quarter %}       transactions.date                 {% endcondition %}
        AND {% condition transactions.date_year %}          transactions.date                 {% endcondition %}
        AND {% condition transactions.date_week %}          transactions.date                 {% endcondition %}
        AND {% condition transactions.date_week_of_year %}  transactions.date                 {% endcondition %}
        AND {% condition transactions.date_month_num %}     transactions.date                 {% endcondition %}
        AND {% condition transactions.date_day_of_year %}   transactions.date                 {% endcondition %}
        AND {% condition transactions.date_day_of_week %}   transactions.date                 {% endcondition %}
        AND {% condition transactions.date_day_of_week_index %} transactions.date             {% endcondition %}
        AND {% condition transactions.is_transfer %}        1=1                      {% endcondition %}
        AND {% condition transactions.is_expensable %}      1=1                      {% endcondition %}
      GROUP BY
        1
       ;;
  }

  filter: tail {
    type: number
    label: "Other Threshold"
    description: "Ordinal rank at which merchants will be grouped into an other bucket..."
  }

  dimension: merchant {
    type: string
    sql: ${TABLE}.description ;;
    hidden: yes
  }

  dimension: max_amount {
    type: number
    group_label: "Facts"
    label: "Max Amount"
    sql: ${TABLE}.max_amount ;;
  }
  dimension: first_transaction {
    type: date
    group_label: "Facts"
    label: "First Transaction"
    sql: ${TABLE}.first_transaction ;;
  }
  dimension: last_transaction {
    type: date
    group_label: "Facts"
    label: "Last Transaction"
    sql: ${TABLE}.last_transaction ;;
  }
  dimension: duration_between_first_and_last_transaction {
    type: number
    group_label: "Facts"
    label: "Duration between first and last"
    sql: ${TABLE}.duration ;;
  }
  dimension: frequency {
    type: number
    group_label: "Facts"
    label: "Charge Regularity"
    sql: ${TABLE}.frequency ;;
    value_format_name: decimal_3
  }
  dimension: days_since_last_charge {
    type: number
    group_label: "Facts"
    label: "Days Since Last"
    sql: date_diff(current_date,${last_transaction},day) ;;
  }

  dimension: days_a_customer {
    type: number
    group_label: "Facts"
    label: "Days since start"
    sql: date_diff(current_date,${first_transaction},day) ;;
  }

####### AMOUNT #######
  dimension: rank_by_amount {
    type: number
    sql: ${TABLE}.rank_by_amount ;;
    group_label: "Rankings"
    label: "By Total Amount"
    skip_drill_filter: yes
  }
  dimension: merchant_by_amount {
    type: string
    group_label: "Merchant with Ranks"
    hidden: yes
    sql:
          CASE
          WHEN ${rank_by_amount} < 10 THEN concat('00',cast(${rank_by_amount} as string),') ',${merchant})
          WHEN ${rank_by_amount} < 100 THEN concat('0',cast(${rank_by_amount} as string),') ',${merchant})
          ELSE                                     concat(cast(${rank_by_amount} as string),') ',${merchant})
          END
    ;;

    }
    dimension: merchant_by_amount_tail {
      group_label: "Ranked Names"
      label: "By Total Amount"
      type: string
      sql:
          CASE
          WHEN {% condition tail %} ${rank_by_amount} {% endcondition %} THEN ${merchant_by_amount}
          ELSE 'x) Other'
          END
    ;;
    }
    dimension: total_amount {
      group_label: "Facts"
      label: "Total Amount"
      type: number
      sql: ${TABLE}.total_amount ;;
      value_format_name: usd
    }
####### AMOUNT #######

####### NUMBER #######
    dimension: rank_by_number {
      group_label: "Rankings"
      label: "By Volume"
      type: number
      sql: ${TABLE}.rank_by_number ;;
      skip_drill_filter: yes
    }
    dimension: merchant_by_number {
      group_label: "Merchant with Ranks"
      hidden: yes
      type: string
      sql:
          CASE
          WHEN ${rank_by_number} < 10 THEN concat('00',cast(${rank_by_number} as string),') ',${merchant})
          WHEN ${rank_by_number} < 100 THEN concat('0',cast(${rank_by_number} as string),') ',${merchant})
          ELSE                                     concat(cast(${rank_by_number} as string),') ',${merchant})
          END
    ;;
    }
    dimension: merchant_by_number_tail {
      group_label: "Ranked Names"
      label: "By Volume"
      type: string
      sql:
          CASE
          WHEN {% condition tail %} ${rank_by_number} {% endcondition %} THEN ${merchant_by_number}
          ELSE 'x) Other'
          END
    ;;
    }
    dimension: volume {
      group_label: "Facts"
      label: "Transaction Volume"
      type: number
      sql: ${TABLE}.volume ;;
    }
####### NUMBER #######

####### AVG #######
    dimension: rank_by_avg {
      group_label: "Rankings"
      label: "By Avg Amount"
      type: number
      sql: ${TABLE}.rank_by_avg ;;
      skip_drill_filter: yes
    }
    dimension: merchant_by_avg {
      group_label: "Merchant with Ranks"
      hidden: yes
      type: string
      sql:
          CASE
          WHEN ${rank_by_avg} < 10 THEN concat('00',cast(${rank_by_avg} as string),') ',${merchant})
          WHEN ${rank_by_avg} < 100 THEN concat('0',cast(${rank_by_avg} as string),') ',${merchant})
          ELSE                                  concat(cast(${rank_by_avg} as string),') ',${merchant})
          END
    ;;
    }
    dimension: merchant_by_avg_tail {
      type: string
      group_label: "Ranked Names"
      label: "By Avg Amount"
      sql:
          CASE
          WHEN {% condition tail %} ${rank_by_avg} {% endcondition %} THEN ${merchant_by_avg}
          ELSE 'x) Other'
          END
    ;;
    }
    dimension: avg_amount {
      group_label: "Facts"
      label: "Avg Amount"
      type: number
      sql: ${TABLE}.avg_amount ;;
      value_format_name: usd
    }
####### AVG #######
  }
