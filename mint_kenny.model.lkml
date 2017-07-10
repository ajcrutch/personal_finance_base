connection: "personal_bq"

# include some the views
include: "mint_base.view"
include: "mint_block_kenny.view"

explore: mint_kenny {
  extends: [mint_block_kenny]
  view_label: "Mint Data"
  view_name: mint_data
}
