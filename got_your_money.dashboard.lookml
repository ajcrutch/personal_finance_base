- dashboard: got_your_money
  title: Got Your Money
  layout: newspaper
  elements:
  - name: Obfuscation Note
    type: text
    title_text: Obfuscation Note
    body_text: |-
      Due to bug <a href="https://github.com/looker/helltool/issues/26533" target="_new">26533</a>, this is a string filter and not a YesNo.  You must either write 'yes' or 'no' until this is fixed.  If it were a YesNo field, the filter would have suggestions.

      Also, in order to share this dashboard as a LookML dashboard, it might need to stay as a string even after that bug is fixed... since the field isn't defined in the dashboard model.
    row: 0
    col: 0
    width: 10
    height: 4
  - name: Spending Analysis Past 3 Months
    title: Spending Analysis Past 3 Months
    model: mint_data
    explore: transactions
    type: table
    fields:
    - transactions.category
    - transactions.transaction_type
    - transactions.average_monthly_amount
    pivots:
    - transactions.transaction_type
    filters:
      transactions.obfuscate: 'no'
      transactions.date_date: 3 months ago for 3 months
      transactions.category: "-Credit Card Payment"
    sorts:
    - transactions.average_monthly_amount 2
    - transactions.transaction_type desc 0
    limit: 500
    column_limit: 50
    total: true
    row_total: right
    dynamic_fields:
    - table_calculation: total_net_debits
      label: Total Net Debits
      expression: sum(if(${transactions.average_monthly_amount:row_total}<0,${transactions.average_monthly_amount:row_total},0))
      value_format:
      value_format_name: usd
      _kind_hint: supermeasure
    - table_calculation: total_net_credits
      label: Total Net Credits
      expression: sum(if(${transactions.average_monthly_amount:row_total}>0,${transactions.average_monthly_amount:row_total},0))
      value_format:
      value_format_name: usd
      _kind_hint: supermeasure
    listen:
      Obfuscate: transactions.obfuscate
    row: 15
    col: 0
    width: 17
    height: 7
  - name: Average Daily Credits/Debits Last 12 Weeks
    title: Average Daily Credits/Debits Last 12 Weeks
    model: mint_data
    explore: transactions
    type: table
    fields:
    - transactions.transaction_type
    - transactions.average_daily_amount
    filters:
      transactions.date_date: 84 days
    sorts:
    - transactions.transaction_type
    limit: 500
    column_limit: 50
    show_view_names: true
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: time
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    ordering: none
    show_null_labels: false
    series_types: {}
    reference_lines: []
    y_axes:
    - label: ''
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: mint_andy.credits
        name: Mint Data Credits
        __FILE: personal_finance/got_your_money.dashboard.lookml
        __LINE_NUM: 180
      - id: mint_andy.debits
        name: Mint Data Debits
        __FILE: personal_finance/got_your_money.dashboard.lookml
        __LINE_NUM: 182
      __FILE: personal_finance/got_your_money.dashboard.lookml
      __LINE_NUM: 168
    focus_on_hover: false
    series_colors:
      mint_andy.credits: "#90d462"
      mint_andy.debits: "#9e6d75"
    listen:
      Date: transactions.date_date
      Obfuscate: transactions.obfuscate
    row: 11
    col: 0
    width: 9
    height: 4
  - name: Debits
    title: Debits
    model: mint_data
    explore: transactions
    type: table
    fields:
    - transactions.total_amount
    - transactions.category
    filters:
      transactions.date_month: 6 months
      transactions.transaction_type: debit
    sorts:
    - transactions.total_amount
    limit: 500
    column_limit: 50
    show_view_names: true
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    stacking: normal
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    listen:
      Date: transactions.date_date
      Obfuscate: transactions.obfuscate
    row: 0
    col: 17
    width: 7
    height: 32
  - name: Credits
    title: Credits
    model: mint_data
    explore: transactions
    type: table
    fields:
    - transactions.total_amount
    - transactions.category
    filters:
      transactions.date_month: 6 months
      transactions.transaction_type: credit
    sorts:
    - transactions.total_amount desc
    limit: 500
    column_limit: 50
    show_view_names: true
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    stacking: normal
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    listen:
      Date: transactions.date_date
      Obfuscate: transactions.obfuscate
    row: 0
    col: 10
    width: 7
    height: 9
  - name: Monthly Spending
    title: Monthly Spending
    model: mint_data
    explore: transactions
    type: looker_line
    fields:
    - transactions.date_month
    - transactions.total_income_amount
    - transactions.total_spend_amount
    fill_fields:
    - transactions.date_month
    filters:
      transactions.date_month: 6 months
    sorts:
    - transactions.date_month
    limit: 500
    column_limit: 50
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: time
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    ordering: none
    show_null_labels: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    series_types: {}
    reference_lines: []
    y_axes:
    - label: ''
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: mint_andy.credits
        name: Mint Data Credits
      - id: mint_andy.debits
        name: Mint Data Debits
    focus_on_hover: false
    series_colors:
      mint_andy.credits: "#90d462"
      mint_andy.debits: "#9e6d75"
    listen:
      Date: transactions.date_date
      Obfuscate: transactions.obfuscate
    row: 4
    col: 0
    width: 10
    height: 7
  filters:
  - name: Date
    title: Date
    type: date_filter
    default_value: 6 months
    model:
    explore:
    field:
    listens_to_filters: []
    allow_multiple_values: true
    required: false
  - name: Obfuscate
    title: Obfuscate
    type: string_filter
    default_value: 'yes'
    model: mint_andy
    explore: mint_andy
    field: mint_data.obfuscate
    listens_to_filters: []
    allow_multiple_values: true
    required: false
