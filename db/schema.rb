# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_06_15_174125) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aisles", force: :cascade do |t|
    t.string "aislenum"
    t.integer "aislestart"
    t.integer "aisleend"
    t.integer "aisledepth"
    t.integer "aisleheight"
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_aisles_on_store_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "HFB"
    t.string "PA"
    t.string "SALESMETHOD"
    t.integer "BASEONHAND"
    t.string "ARTNO"
    t.string "ARTNAME_UNICODE"
    t.integer "CP_LENGTH"
    t.integer "CP_WIDTH"
    t.integer "CP_HEIGHT"
    t.integer "WEIGHT_G"
    t.string "SLID_H"
    t.integer "MPQ"
    t.integer "PALQ"
    t.string "SSD"
    t.string "EDS"
    t.integer "UL_HEIGHT_GROSS"
    t.integer "UL_LENGTH_GROSS"
    t.integer "UL_WIDTH_GROSS"
    t.string "new_slid"
    t.integer "new_assq"
    t.integer "DTFP"
    t.integer "DTFP_PLUS"
    t.integer "RSSQ"
    t.boolean "planned"
    t.bigint "store_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_articles_on_store_id"
  end

  create_table "articles_levels", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "level_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_articles_levels_on_article_id"
    t.index ["level_id"], name: "index_articles_levels_on_level_id"
  end

  create_table "levels", force: :cascade do |t|
    t.integer "level_height"
    t.integer "level_depth"
    t.bigint "section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "level_num"
    t.index ["section_id"], name: "index_levels_on_section_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "sectionnum"
    t.integer "sec_depth"
    t.integer "sec_height"
    t.bigint "aisle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aisle_id"], name: "index_sections_on_aisle_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "storename"
    t.string "storenum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "aisles", "stores"
  add_foreign_key "articles", "stores"
  add_foreign_key "articles_levels", "articles"
  add_foreign_key "articles_levels", "levels"
  add_foreign_key "levels", "sections"
  add_foreign_key "sections", "aisles"
end
