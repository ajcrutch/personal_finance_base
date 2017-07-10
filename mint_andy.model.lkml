connection: "personal_bq"

# include all the views
include: "*.view"

explore: mint_andy {
  extends: [mint_block_andy]
  view_label: "Mint Data"
  view_name: mint_data
}
