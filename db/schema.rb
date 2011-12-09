# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111207073136) do

  create_table "arrondissements", :force => true do |t|
    t.string   "nom_arr"
    t.string   "cle"
    t.datetime "date_maj"
    t.text     "remarques"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "patinoires", :force => true do |t|
    t.string   "nom"
    t.string   "description"
    t.string   "genre"
    t.string   "disambiguation"
    t.boolean  "ouvert"
    t.boolean  "deblaye"
    t.boolean  "arrose"
    t.boolean  "resurface"
    t.string   "condition"
    t.string   "parc"
    t.string   "adresse"
    t.integer  "tel"
    t.integer  "ext"
    t.float    "lat"
    t.float    "lng"
    t.integer  "arrondissement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "patinoires", ["arrondissement_id"], :name => "index_patinoires_on_arrondissement_id"

end
