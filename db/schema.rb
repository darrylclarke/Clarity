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

ActiveRecord::Schema.define(version: 20151007165422) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "code_classes", force: :cascade do |t|
    t.string   "name"
    t.string   "ancestors"
    t.integer  "code_file_id"
    t.integer  "line"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "code_namespace_id"
    t.integer  "project_id"
  end

  add_index "code_classes", ["code_file_id"], name: "index_code_classes_on_code_file_id", using: :btree
  add_index "code_classes", ["code_namespace_id"], name: "index_code_classes_on_code_namespace_id", using: :btree
  add_index "code_classes", ["project_id"], name: "index_code_classes_on_project_id", using: :btree

  create_table "code_files", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "folder_id"
  end

  add_index "code_files", ["folder_id"], name: "index_code_files_on_folder_id", using: :btree
  add_index "code_files", ["project_id"], name: "index_code_files_on_project_id", using: :btree

  create_table "code_methods", force: :cascade do |t|
    t.string   "name"
    t.string   "return_type"
    t.string   "arguments"
    t.integer  "code_file_id"
    t.integer  "code_class_id"
    t.integer  "impl_start"
    t.integer  "impl_end"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "specified_class_name"
    t.integer  "signature_line"
    t.integer  "code_namespace_id"
    t.integer  "project_id"
  end

  add_index "code_methods", ["code_class_id"], name: "index_code_methods_on_code_class_id", using: :btree
  add_index "code_methods", ["code_file_id"], name: "index_code_methods_on_code_file_id", using: :btree
  add_index "code_methods", ["code_namespace_id"], name: "index_code_methods_on_code_namespace_id", using: :btree
  add_index "code_methods", ["project_id"], name: "index_code_methods_on_project_id", using: :btree

  create_table "code_namespaces", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "project_id"
  end

  add_index "code_namespaces", ["project_id"], name: "index_code_namespaces_on_project_id", using: :btree

  create_table "display_box_lines", force: :cascade do |t|
    t.integer  "display_box_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "parent_id"
  end

  add_index "display_box_lines", ["display_box_id"], name: "index_display_box_lines_on_display_box_id", using: :btree

  create_table "display_box_links", force: :cascade do |t|
    t.integer  "from"
    t.integer  "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "project_id"
  end

  create_table "display_boxes", force: :cascade do |t|
    t.string   "project_id"
    t.string   "text"
    t.integer  "x_pos"
    t.integer  "y_pos"
    t.integer  "height"
    t.integer  "width"
    t.integer  "folder_id"
    t.integer  "num_code_files"
    t.integer  "notes_flags"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "display_id"
  end

  add_index "display_boxes", ["folder_id"], name: "index_display_boxes_on_folder_id", using: :btree

  create_table "folders", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "num_code_files"
    t.integer  "project_id"
  end

  add_index "folders", ["project_id"], name: "index_folders_on_project_id", using: :btree

  create_table "impl_calls", force: :cascade do |t|
    t.integer  "caller_id"
    t.integer  "called_id"
    t.string   "external_call"
    t.integer  "line"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "preprocessor_lines", force: :cascade do |t|
    t.string   "text"
    t.integer  "code_file_id"
    t.integer  "line"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "preprocessor_lines", ["code_file_id"], name: "index_preprocessor_lines_on_code_file_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.string   "root_path"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

  create_table "structures", force: :cascade do |t|
    t.string   "name"
    t.string   "type_of"
    t.integer  "code_file_id"
    t.integer  "line"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "structures", ["code_file_id"], name: "index_structures_on_code_file_id", using: :btree

  create_table "sub_folders", force: :cascade do |t|
    t.integer  "folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "parent_id"
  end

  add_index "sub_folders", ["folder_id"], name: "index_sub_folders_on_folder_id", using: :btree

  create_table "user_projects", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_projects", ["project_id"], name: "index_user_projects_on_project_id", using: :btree
  add_index "user_projects", ["user_id"], name: "index_user_projects_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "admin"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "variables", force: :cascade do |t|
    t.string   "name"
    t.string   "var_type"
    t.integer  "code_file_id"
    t.integer  "code_class_id"
    t.integer  "line"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "code_namespace_id"
    t.integer  "project_id"
  end

  add_index "variables", ["code_class_id"], name: "index_variables_on_code_class_id", using: :btree
  add_index "variables", ["code_file_id"], name: "index_variables_on_code_file_id", using: :btree
  add_index "variables", ["code_namespace_id"], name: "index_variables_on_code_namespace_id", using: :btree
  add_index "variables", ["project_id"], name: "index_variables_on_project_id", using: :btree

  add_foreign_key "code_classes", "code_files"
  add_foreign_key "code_classes", "code_namespaces"
  add_foreign_key "code_classes", "projects"
  add_foreign_key "code_files", "folders"
  add_foreign_key "code_files", "projects"
  add_foreign_key "code_methods", "code_classes"
  add_foreign_key "code_methods", "code_files"
  add_foreign_key "code_methods", "code_namespaces"
  add_foreign_key "code_methods", "projects"
  add_foreign_key "code_namespaces", "projects"
  add_foreign_key "display_box_lines", "display_boxes"
  add_foreign_key "display_boxes", "folders"
  add_foreign_key "folders", "projects"
  add_foreign_key "preprocessor_lines", "code_files"
  add_foreign_key "projects", "users"
  add_foreign_key "structures", "code_files"
  add_foreign_key "sub_folders", "folders"
  add_foreign_key "user_projects", "projects"
  add_foreign_key "user_projects", "users"
  add_foreign_key "variables", "code_classes"
  add_foreign_key "variables", "code_files"
  add_foreign_key "variables", "code_namespaces"
  add_foreign_key "variables", "projects"
end
