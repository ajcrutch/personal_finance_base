# include: "datagroups.view.lkml"
# view: calendar {
#   derived_table: {
#     datagroup_trigger: calendar
#     sql: WITH
#
#             splitted AS (
#               SELECT
#                 *
#               FROM
#                 UNNEST( SPLIT(RPAD('',
#                       1 + DATE_DIFF(CURRENT_DATE(), DATE("2010-01-01"), DAY),
#                       '.'),''))),
#               with_row_numbers AS (
#               SELECT
#                 ROW_NUMBER() OVER() AS pos,
#                 *
#               FROM
#                 splitted),
#               calendar_day AS (
#               SELECT
#                 DATE_ADD(DATE("2010-01-01"), INTERVAL (pos - 1) DAY) AS day
#               FROM
#                 with_row_numbers)
#             SELECT
#               *
#             FROM
#               calendar_day
#             ORDER BY
#               day DESC
#              ;;
#   }
# #   Code from https://stackoverflow.com/questions/38694040/how-to-generate-date-series-to-occupy-absent-dates-in-google-biqquery
#
# dimension: pkey {
#   hidden: yes
#   primary_key: yes
#   sql: ${date_raw} ;;
# }
#
#   dimension_group: date {
#     view_label: "Mint Data"
#     label: "Calendar Table"
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     datatype: date
#     sql: ${TABLE}.day ;;
#     convert_tz: no
#   }
#
# #   measure: count_of_days {
# # #     hidden: yes
# #     type: count
# #   }
#
#   set: detail {
#     fields: [date_date]
#   }
# }
