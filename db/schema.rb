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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160716201323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "organizations", force: :cascade do |t|
    t.string  "name"
    t.boolean "active"
  end

  create_table "representatives", force: :cascade do |t|
    t.string   "name",            default: ""
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "organization_id"
  end

  add_index "representatives", ["organization_id"], name: "index_representatives_on_organization_id", using: :btree
  add_index "representatives", ["user_id"], name: "index_representatives_on_user_id", using: :btree

  create_table "reservations", force: :cascade do |t|
    t.string   "client",                            null: false
    t.integer  "user_id",                           null: false
    t.integer  "representative_id"
    t.integer  "quantity",          default: 1
    t.string   "comment",           default: ""
    t.datetime "date",                              null: false
    t.integer  "status",            default: 0
    t.boolean  "visible",           default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "organization_id"
  end

  add_index "reservations", ["organization_id"], name: "index_reservations_on_organization_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.integer  "coordinator_id",                                         null: false
    t.integer  "administrator_id",                                       null: false
    t.integer  "representative_id"
    t.integer  "reservation_id"
    t.string   "client",                                                 null: false
    t.string   "comment",                                   default: ""
    t.integer  "quantity",                                  default: 1,  null: false
    t.decimal  "ammount",           precision: 7, scale: 2
    t.datetime "date",                                                   null: false
    t.integer  "status",                                    default: 0
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "table_id",                                  default: 1,  null: false
    t.integer  "organization_id"
    t.datetime "seated_time"
    t.datetime "completed_time"
  end

  add_index "services", ["organization_id"], name: "index_services_on_organization_id", using: :btree
  add_index "services", ["table_id"], name: "index_services_on_table_id", using: :btree

  create_table "tables", force: :cascade do |t|
    t.string   "number",                      null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "organization_id"
    t.integer  "x",               default: 0, null: false
    t.integer  "y",               default: 0, null: false
  end

  add_index "tables", ["organization_id"], name: "index_tables_on_organization_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",          null: false
    t.string   "encrypted_password",     default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,           null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "auth_token",             default: ""
    t.integer  "credentials",            default: 0
    t.integer  "supervisor_id"
    t.string   "timezone",               default: "Monterrey", null: false
    t.string   "name",                   default: "",          null: false
    t.integer  "organization_id"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["organization_id"], name: "index_users_on_organization_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["supervisor_id"], name: "index_users_on_supervisor_id", using: :btree

end
