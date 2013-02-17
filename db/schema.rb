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

ActiveRecord::Schema.define(:version => 20130217210024) do

  create_table "issues", :force => true do |t|
    t.integer  "api_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "petition_issues", :force => true do |t|
    t.integer  "petition_id"
    t.integer  "issue_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "petition_issues", ["issue_id"], :name => "index_petition_issues_on_issue_id"
  add_index "petition_issues", ["petition_id"], :name => "index_petition_issues_on_petition_id"

  create_table "petitions", :force => true do |t|
    t.string   "api_id"
    t.string   "petition_type"
    t.text     "url"
    t.string   "title"
    t.text     "body"
    t.integer  "signature_threshold"
    t.integer  "signature_count"
    t.integer  "signatures_needed"
    t.integer  "deadline"
    t.string   "status"
    t.integer  "petition_created_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "petitions", ["api_id"], :name => "index_petitions_on_api_id", :unique => true

end
