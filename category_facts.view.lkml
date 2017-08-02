view: category_facts {
  label: "Category"
  derived_table: {
    sql:
      SELECT
         T.category                                               AS t_category
        ,SUM(T.amount)                                          AS total_amount
        ,COUNT(DISTINCT concat(cast(date as string),cast(amount as string),account_name,original_description))
                                                                AS volume
        ,AVG(T.amount)                                          AS avg_amount
        ,MAX(T.amount)                                          AS max_amount
        ,ROW_NUMBER() OVER (ORDER BY SUM(T.amount) DESC)        AS rank_by_amount
        ,ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT concat(cast(date as string),cast(amount as string),account_name,original_description)) DESC)   AS rank_by_number
        , ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC)   AS s_rank_by_number
        ,ROW_NUMBER() OVER (ORDER BY AVG(T.amount) DESC)        AS rank_by_avg
      FROM
        mint_andy T
      WHERE
        1=1
        AND {% condition transactions.transaction_type %}   T.transaction_type     {% endcondition %}
        AND {% condition transactions.category %}           T.category             {% endcondition %}
        AND {% condition transactions.notes %}              T.notes                {% endcondition %}
        AND {% condition transactions.labels %}             T.labels               {% endcondition %}
        AND {% condition transactions.description %}        T.description          {% endcondition %}
        AND {% condition transactions.account_name %}       T.account_name         {% endcondition %}
        AND {% condition transactions.date_date %}          T.date                 {% endcondition %}
        AND {% condition transactions.date_month %}         T.date                 {% endcondition %}
        AND {% condition transactions.date_quarter %}       T.date                 {% endcondition %}
        AND {% condition transactions.date_year %}          T.date                 {% endcondition %}
        AND {% condition transactions.date_week %}          T.date                 {% endcondition %}
        AND {% condition transactions.date_week_of_year %}  T.date                 {% endcondition %}
        AND {% condition transactions.date_month_num %}     T.date                 {% endcondition %}
        AND {% condition transactions.date_day_of_year %}   T.date                 {% endcondition %}
        AND {% condition transactions.date_day_of_week %}   T.date                 {% endcondition %}
        AND {% condition transactions.date_day_of_week_index %} T.date             {% endcondition %}
        AND {% condition transactions.is_transfer %}        1=1                      {% endcondition %}
        AND {% condition transactions.is_expensable %}      1=1                      {% endcondition %}
      GROUP BY
        1
       ;;
  }

  filter: tail {
    type: number
    label: "Other Threshold"
    description: "Ordinal rank at which categories will be grouped into an other bucket..."
  }

  dimension: category {
    hidden: yes
    type: string
    sql: ${TABLE}.t_category ;;
  }

####### AMOUNT #######
  dimension: rank_by_amount {
    type: number
    sql: ${TABLE}.rank_by_amount ;;
  }
  dimension: category_by_amount {
    type: string
    sql:
          CASE
          WHEN ${rank_by_amount} < 10 THEN councat('00',${rank_by_amount},') ',${category})
          WHEN ${rank_by_amount} < 100 THEN concat('0',${rank_by_amount},') ',${category})
          ELSE                                     concat(${rank_by_amount},') ', ${category})
          END
    ;;
  }
  dimension: category_by_amount_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_amount} {% endcondition %} THEN ${category_by_amount}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: total_amount {
    type: number
    sql: ${TABLE}.total_amount ;;
    value_format_name: usd
  }
####### AMOUNT #######

####### NUMBER #######
  dimension: rank_by_number {
    type: number
    sql: ${TABLE}.rank_by_number ;;
  }
  dimension: category_by_number {
    type: string
    sql:
          CASE
          WHEN ${rank_by_number} < 10 THEN concat('00',${rank_by_number},') ',${category})
          WHEN ${rank_by_number} < 100 THEN concat('0',${rank_by_number},') ',${category})
          ELSE                                     concat(${rank_by_number},') ',${category})
          END
    ;;
  }
  dimension: category_by_number_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_number} {% endcondition %} THEN ${category_by_number}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: volume {
    type: number
    sql: ${TABLE}.volume ;;
  }
####### NUMBER #######

####### AVG #######
  dimension: rank_by_avg {
    type: number
    sql: ${TABLE}.rank_by_avg ;;
  }
  dimension: category_by_avg {
    type: string
    sql:
          CASE
          WHEN ${rank_by_avg} < 10 THEN concat('00',${rank_by_avg},') ',${category})
          WHEN ${rank_by_avg} < 100 THEN concat('0',${rank_by_avg},') ',${category})
          ELSE                                  concat(${rank_by_avg},') ',${category})
          END
    ;;
  }
  dimension: category_by_avg_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_avg} {% endcondition %} THEN ${category_by_avg}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: avg_amount {
    type: number
    sql: ${TABLE}.avg_amount ;;
    value_format_name: usd
  }
####### AVG #######
}